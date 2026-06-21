import 'package:flutter/material.dart';
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
    // Sort oldest first for natural top-to-bottom chat rendering
    final sortedMessages = messages.messages.reversed.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        // Chat Thread Panel
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                eyebrow: S.of(context).professionalMessagesConversationEyebrow,
                title: S.of(context).professionalMessagesChatThreadTitle,
                subtitle: S.of(context).professionalMessagesThreadSubtitle,
              ),
              const SizedBox(height: 16),
              
              if (sortedMessages.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      S.of(context).professionalMessagesEmpty,
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    for (final message in sortedMessages)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: MessageBubbleCard(
                          message: message,
                          onTap: () {
                            if (!message.isRead && message.authorRole != 'client') {
                              widget.onMarkMessageRead(message);
                            }
                            _showMessageDetailSheet(context, message);
                          },
                          onMarkRead: (message.isRead || message.authorRole == 'client')
                              ? null
                              : () => widget.onMarkMessageRead(message),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // New Message Input Box
        if (!messages.messagesEnabled)
          Panel(
            child: Text(
              S.of(context).professionalMessagesDisabled,
            ),
          )
        else
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  eyebrow: S.of(context).professionalMessagesNewEyebrow,
                  title: S.of(context).professionalMessagesWriteTitle,
                  subtitle: S.of(context).professionalMessagesWriteSubtitle,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _controller,
                  minLines: 2,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: S.of(context).professionalMessagesInputHint,
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerLow,
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
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
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_outlined),
                    label: Text(
                      S.of(context).professionalMessagesSend,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _showMessageDetailSheet(BuildContext context, ProfessionalMessageEntity message) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final fromClient = message.authorRole == 'client';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161618) : colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: fromClient
                              ? colorScheme.primary.withValues(alpha: 0.16)
                              : colorScheme.secondaryContainer,
                          child: Icon(
                            fromClient ? Icons.person_outline : Icons.verified_user_outlined,
                            color: fromClient ? colorScheme.primary : colorScheme.onSecondaryContainer,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fromClient ? S.of(context).professionalMessagesAuthorClientFull : S.of(context).professionalMessagesAuthorProfessionalFull,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              formatDateTime(context, message.createdAt),
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      icon: const Icon(Icons.close),
                      style: IconButton.styleFrom(
                        backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  S.of(context).professionalMessagesFullMessage,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: colorScheme.surfaceContainerLow,
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.35),
                    ),
                  ),
                  child: SelectableText(
                    message.body,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.45,
                        ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    child: Text(S.of(context).professionalMessagesGotIt),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MessageBubbleCard extends StatelessWidget {
  final ProfessionalMessageEntity message;
  final VoidCallback onTap;
  final VoidCallback? onMarkRead;

  const MessageBubbleCard({
    super.key,
    required this.message,
    required this.onTap,
    required this.onMarkRead,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fromClient = message.authorRole == 'client';
    
    final bubbleColor = fromClient
        ? colorScheme.primary.withValues(alpha: 0.12)
        : colorScheme.surfaceContainerLow;
        
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
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            color: bubbleColor,
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.28),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    fromClient ? S.of(context).professionalMessagesAuthorClientShort : S.of(context).professionalMessagesAuthorProfessionalShort,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: fromClient ? colorScheme.primary : colorScheme.onSurfaceVariant,
                        ),
                  ),
                  if (!message.isRead && !fromClient) ...[
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
                  const SizedBox(width: 8),
                  Text(
                    formatDateTime(context, message.createdAt),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                          fontSize: 9,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                message.body,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.4,
                    ),
              ),
              if (onMarkRead != null) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: onMarkRead,
                    icon: const Icon(Icons.mark_email_read_outlined, size: 14),
                    label: Text(
                      S.of(context).professionalMessagesMarkRead,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
