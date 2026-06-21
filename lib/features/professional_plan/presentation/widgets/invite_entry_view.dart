import 'package:flutter/material.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_connection_entity.dart';
import 'package:macrotracker/features/professional_plan/presentation/widgets/professional_ui_helpers.dart';
import 'package:macrotracker/generated/l10n.dart';

class InviteEntryView extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Panel(
          accent: Color.alphaBlend(
            colorScheme.primary.withValues(alpha: 0.12),
            colorScheme.surface,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                eyebrow: S.of(context).professionalInvitePrivateActivation,
                title: S.of(context).professionalInviteSectionTitle,
                subtitle: S.of(context).professionalInviteSectionBody,
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  StatusPill(
                    icon: Icons.key_outlined,
                    label: S.of(context).professionalInvitePillInvite,
                  ),
                  StatusPill(
                    icon: Icons.shield_outlined,
                    label: S.of(context).professionalInvitePillConsent,
                  ),
                  StatusPill(
                    icon: Icons.lock_clock_outlined,
                    label: S.of(context).professionalInvitePillClearPrivacy,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
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
                controller: codeController,
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
                  onPressed: isBusy ? null : onPreviewInvite,
                  icon: const Icon(Icons.search_outlined),
                  label: Text(S.of(context).professionalInviteReviewAction),
                ),
              ),
            ],
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: colorScheme.errorContainer,
            ),
            child: Text(
              error!,
              style: TextStyle(color: colorScheme.onErrorContainer),
            ),
          ),
        ],
        if (invitePreview != null && !invitePreview!.isExpired) ...[
          const SizedBox(height: 18),
          ConsentCard(
            invitePreview: invitePreview!,
            isBusy: isBusy,
            onAcceptInvite: onAcceptInvite,
          ),
        ],
      ],
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
