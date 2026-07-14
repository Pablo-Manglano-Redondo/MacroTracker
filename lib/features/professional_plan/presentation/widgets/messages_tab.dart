import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/core/domain/usecase/get_user_usecase.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_section_entities.dart';
import 'package:macrotracker/generated/l10n.dart';
import 'package:macrotracker/features/professional_plan/presentation/widgets/professional_ui_helpers.dart';

class MessagesTab extends StatefulWidget {
  final ProfessionalSectionSummaryEntity summary;
  final ProfessionalMessageThreadEntity messages;
  final ValueChanged<ProfessionalMessageEntity> onMarkMessageRead;
  final Future<void> Function(String body) onSendMessage;
  final bool sendingMessage;

  const MessagesTab({
    super.key,
    required this.summary,
    required this.messages,
    required this.onMarkMessageRead,
    required this.onSendMessage,
    required this.sendingMessage,
  });

  @override
  State<MessagesTab> createState() => _MessagesTabState();
}

class _MessagesTabState extends State<MessagesTab> {
  final _controller = TextEditingController();
  String? _clientProfileImagePath;

  @override
  void initState() {
    super.initState();
    _loadClientProfileImage();
    _markAllMessagesAsRead();
  }

  @override
  void didUpdateWidget(MessagesTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messages != oldWidget.messages) {
      _markAllMessagesAsRead();
    }
  }

  Future<void> _loadClientProfileImage() async {
    try {
      final user = await locator<GetUserUsecase>().getUserData();
      if (mounted) {
        setState(() {
          _clientProfileImagePath = user.profileImagePath;
        });
      }
    } catch (_) {}
  }

  void _markAllMessagesAsRead() {
    for (final message in widget.messages.messages) {
      if (!message.isRead && message.authorRole != 'client') {
        widget.onMarkMessageRead(message);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = widget.messages;
    final colorScheme = Theme.of(context).colorScheme;

    if (!messages.isSupported) {
      return Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              eyebrow: S.of(context).professionalTabMessages,
              title: S.of(context).professionalTabMessages,
              subtitle: S.of(context).professionalMessagesUnavailableBody,
            ),
            const SizedBox(height: 10),
            Text(
              S.of(context).professionalMessagesUnavailableHint,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      );
    }

    final sortedMessages = messages.messages.reversed.toList();

    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          SectionHeader(
            eyebrow: S.of(context).professionalMessagesConversationEyebrow,
            title: S.of(context).professionalMessagesChatThreadTitle,
            subtitle: '',
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Messages list container (Chat Window Viewport)
          Container(
            constraints: const BoxConstraints(maxHeight: 360),
            decoration: BoxDecoration(
              color: colorScheme.brightness == Brightness.dark
                  ? colorScheme.surfaceContainerLow
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: sortedMessages.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(
                        S.of(context).professionalMessagesEmpty,
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                  )
                : Scrollbar(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: sortedMessages.length,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      itemBuilder: (context, index) {
                        final message = sortedMessages[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: MessageBubbleCard(
                            message: message,
                            summary: widget.summary,
                          ),
                        );
                      },
                    ),
                  ),
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Message input bar
          if (!messages.messagesEnabled)
            Text(
              S.of(context).professionalMessagesDisabled,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: S.of(context).professionalMessagesInputHint,
                      hintStyle: const TextStyle(fontSize: 13),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHigh,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: widget.sendingMessage
                      ? null
                      : () async {
                          final text = _controller.text.trim();
                          if (text.isEmpty) {
                            return;
                          }
                          await widget.onSendMessage(text);
                          if (mounted) {
                            _controller.clear();
                          }
                        },
                  icon: widget.sendingMessage
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.all(12),
                    elevation: 2,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class MessageBubbleCard extends StatelessWidget {
  final ProfessionalMessageEntity message;
  final ProfessionalSectionSummaryEntity summary;

  const MessageBubbleCard({
    super.key,
    required this.message,
    required this.summary,
  });

  String formatShortTime(BuildContext context, DateTime? value) {
    if (value == null) return '';
    final local = value.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Widget _buildStatusTicks(BuildContext context, ProfessionalMessageEntity message) {
    final isRead = message.professionalReadAt != null;
    final timeDifference = DateTime.now().difference(message.createdAt.toLocal());
    final isVeryRecent = timeDifference.inSeconds < 5;

    if (isRead) {
      // Double blue checkmarks
      return const Icon(
        Icons.done_all,
        size: 14,
        color: Colors.cyanAccent,
      );
    } else if (isVeryRecent) {
      // Single white checkmark
      return Icon(
        Icons.done,
        size: 14,
        color: Colors.white.withValues(alpha: 0.6),
      );
    } else {
      // Double white checkmarks
      return Icon(
        Icons.done_all,
        size: 14,
        color: Colors.white.withValues(alpha: 0.6),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fromClient = message.authorRole == 'client';

    final bubbleColor = fromClient
        ? colorScheme.primary
        : colorScheme.surface;

    final textColor = fromClient
        ? colorScheme.onPrimary
        : colorScheme.onSurface;

    final alignment = fromClient ? Alignment.centerRight : Alignment.centerLeft;

    final borderRadius = fromClient
        ? const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(4),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(16),
          );

    return Align(
      alignment: alignment,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: borderRadius,
          onLongPress: () {
            Clipboard.setData(ClipboardData(text: message.body));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  Localizations.localeOf(context).languageCode == 'es'
                      ? 'Mensaje copiado al portapapeles'
                      : 'Message copied to clipboard',
                ),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          child: Container(
            constraints: const BoxConstraints(maxWidth: 290),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              color: bubbleColor,
              boxShadow: [
                BoxShadow(
                  color: fromClient
                      ? colorScheme.primary.withValues(alpha: 0.15)
                      : Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 1.5),
                ),
              ],
              border: fromClient
                  ? null
                  : Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.35),
                    ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!fromClient) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        summary.connection.professionalName,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: colorScheme.primary,
                              fontSize: 10,
                            ),
                      ),
                      if (!message.isRead) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  message.body,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: textColor,
                        height: 1.35,
                      ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Spacer(),
                    Text(
                      formatShortTime(context, message.createdAt),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: fromClient
                                ? colorScheme.onPrimary.withValues(alpha: 0.7)
                                : colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                            fontSize: 9,
                          ),
                    ),
                    if (fromClient) ...[
                      const SizedBox(width: 4),
                      _buildStatusTicks(context, message),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
