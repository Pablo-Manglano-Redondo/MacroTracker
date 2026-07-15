import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  @override
  void initState() {
    super.initState();
    _markAllMessagesAsRead();
  }

  @override
  void didUpdateWidget(MessagesTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messages != oldWidget.messages) {
      _markAllMessagesAsRead();
    }
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
            const SizedBox(height: 12),
            Text(
              S.of(context).professionalMessagesUnavailableHint,
              style: theme.textTheme.bodyMedium?.copyWith(
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
            subtitle: S.of(context).professionalMessagesHeaderSubtitle,
          ),
          const SizedBox(height: 12),

          // Messages list container (Chat Window Viewport)
          Container(
            constraints: const BoxConstraints(maxHeight: 380),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: sortedMessages.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        S.of(context).professionalMessagesEmpty,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                : Scrollbar(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: sortedMessages.length,
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                      itemBuilder: (context, index) {
                        final message = sortedMessages[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
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
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      hintText: S.of(context).professionalMessagesInputHint,
                      filled: true,
                      fillColor: colorScheme.surfaceContainerLow,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide(
                          color: colorScheme.outlineVariant.withValues(alpha: 0.15),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide(
                          color: colorScheme.primary,
                          width: 1.5,
                        ),
                      ),
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                          ),
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
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.onPrimary,
                          ),
                        )
                      : const Icon(Icons.send_rounded, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.all(12),
                    elevation: 1,
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
      return const Icon(
        Icons.done_all_rounded,
        size: 15,
        color: Colors.lightBlueAccent,
      );
    } else if (isVeryRecent) {
      return Icon(
        Icons.done_rounded,
        size: 15,
        color: Colors.white.withValues(alpha: 0.5),
      );
    } else {
      return Icon(
        Icons.done_all_rounded,
        size: 15,
        color: Colors.white.withValues(alpha: 0.5),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final fromClient = message.authorRole == 'client';

    final bubbleColor = fromClient
        ? colorScheme.primary
        : colorScheme.surfaceContainerHigh.withValues(alpha: 0.85);

    final textColor = fromClient
        ? colorScheme.onPrimary
        : colorScheme.onSurface;

    final alignment = fromClient ? Alignment.centerRight : Alignment.centerLeft;

    final borderRadius = fromClient
        ? const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(4),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(18),
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
                  S.of(context).professionalMessagesCopied,
                ),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          child: Container(
            constraints: const BoxConstraints(maxWidth: 280),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              color: bubbleColor,
              border: fromClient
                  ? null
                  : Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.15),
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
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: colorScheme.primary,
                          fontSize: 10,
                          letterSpacing: 0.2,
                        ),
                      ),
                      if (!message.isRead) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 5,
                          height: 5,
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
                  style: theme.textTheme.bodyMedium?.copyWith(
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
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: fromClient
                            ? colorScheme.onPrimary.withValues(alpha: 0.7)
                            : colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
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
