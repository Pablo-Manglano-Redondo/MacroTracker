import 'package:flutter/material.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_connection_entity.dart';
import 'package:macrotracker/features/professional_plan/presentation/widgets/professional_ui_helpers.dart';
import 'package:macrotracker/generated/l10n.dart';

class InviteEntryView extends StatefulWidget {
  final TextEditingController codeController;
  final ProfessionalInvitePreviewEntity? invitePreview;
  final String? error;
  final bool isBusy;
  final VoidCallback onPreviewInvite;
  final VoidCallback onAcceptInvite;

  const InviteEntryView({
    super.key,
    required this.codeController,
    required this.invitePreview,
    required this.error,
    required this.isBusy,
    required this.onPreviewInvite,
    required this.onAcceptInvite,
  });

  @override
  State<InviteEntryView> createState() => _InviteEntryViewState();
}

class _InviteEntryViewState extends State<InviteEntryView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  // Track the last "result" key so AnimatedSwitcher re-animates on change.
  Object? _lastResultKey;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _lastResultKey = _resultKey;
    if (_lastResultKey != null) {
      _controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(covariant InviteEntryView old) {
    super.didUpdateWidget(old);
    final newKey = _resultKey;
    if (newKey != null && newKey != _lastResultKey) {
      _lastResultKey = newKey;
      _controller.forward(from: 0);
    } else if (newKey == null) {
      _lastResultKey = null;
      _controller.reverse();
    }
  }

  /// Unique key representing the current result state.
  Object? get _resultKey {
    if (widget.error != null) return 'error:${widget.error}';
    if (widget.invitePreview != null && !widget.invitePreview!.isExpired) {
      return 'preview:${widget.invitePreview!.professionalId}';
    }
    return null;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasInviteConsentPreview =
        widget.invitePreview != null && !widget.invitePreview!.isExpired;
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!hasInviteConsentPreview)
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  eyebrow: S.of(context).professionalInviteCodeEyebrow,
                  title: S.of(context).professionalInviteCodeLabel,
                  subtitle: S.of(context).professionalInviteReviewBeforeSharing,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: widget.codeController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: S.of(context).professionalInviteCodeLabel,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.key_outlined),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerLow,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: widget.isBusy ? null : widget.onPreviewInvite,
                    icon: widget.isBusy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.search_outlined),
                    label: Text(S.of(context).professionalInviteReviewAction),
                  ),
                ),
              ],
            ),
          ),

        AnimatedSize(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: _resultKey == null
              ? const SizedBox.shrink()
              : FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        if (widget.error != null)
                          _ErrorBanner(message: widget.error!),
                        if (widget.invitePreview != null &&
                            !widget.invitePreview!.isExpired) ...[
                          if (widget.error != null) const SizedBox(height: 12),
                          ConsentCard(
                            invitePreview: widget.invitePreview!,
                            isBusy: widget.isBusy,
                            onAcceptInvite: widget.onAcceptInvite,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: colorScheme.errorContainer,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline,
              size: 18, color: colorScheme.onErrorContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onErrorContainer,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class ConsentCard extends StatelessWidget {
  final ProfessionalInvitePreviewEntity invitePreview;
  final bool isBusy;
  final VoidCallback onAcceptInvite;

  const ConsentCard({
    super.key,
    required this.invitePreview,
    required this.isBusy,
    required this.onAcceptInvite,
  });

  @override
  Widget build(BuildContext context) {
    return Panel(
      accent: Theme.of(context)
          .colorScheme
          .secondaryContainer
          .withValues(alpha: 0.55),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            eyebrow: S.of(context).professionalConsentReviewEyebrow,
            title: invitePreview.professionalName,
            subtitle: S.of(context).professionalConsentReviewSubtitle,
          ),
          const SizedBox(height: 14),
          ConsentGroup(
            title: S.of(context).professionalConsentSharedToday,
            rows: [
              S.of(context).professionalConsentSharedTodayBody,
            ],
          ),
          const SizedBox(height: 10),
          ConsentGroup(
            title: S.of(context).professionalConsentNotSharedToday,
            rows: [
              S.of(context).professionalConsentNotSharedTodayBody,
            ],
          ),
          const SizedBox(height: 10),
          ConsentRow(
            text: S.of(context).professionalConsentRevokeHint,
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: isBusy ? null : onAcceptInvite,
            icon: isBusy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_circle_outline),
            label: Text(
              isBusy
                  ? S.of(context).professionalOpeningGoogle
                  : S.of(context).professionalAcceptAndConnect,
            ),
          ),
        ],
      ),
    );
  }
}

class ConsentGroup extends StatelessWidget {
  final String title;
  final List<String> rows;

  const ConsentGroup({
    super.key,
    required this.title,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          for (final row in rows) ...[
            ConsentRow(text: row),
            if (row != rows.last) const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }
}

class ConsentRow extends StatelessWidget {
  final String text;

  const ConsentRow({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_outlined, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
