import 'package:flutter/material.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_section_entities.dart';
import 'package:macrotracker/generated/l10n.dart';
import 'package:macrotracker/features/professional_plan/presentation/widgets/professional_ui_helpers.dart';
import 'package:macrotracker/features/professional_plan/presentation/widgets/invite_entry_view.dart'; // Imports ConsentGroup and ConsentRow

class PrivacyTab extends StatelessWidget {
  final ProfessionalSectionSummaryEntity summary;
  final ProfessionalSharingScopeEntity sharingScope;
  final VoidCallback onDisconnect;
  final ValueChanged<String> onUpdateSharingMode;

  const PrivacyTab({
    super.key,
    required this.summary,
    required this.sharingScope,
    required this.onDisconnect,
    required this.onUpdateSharingMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isAggregate = sharingScope.sharingMode == 'aggregate';
    final isDetailed = sharingScope.sharingMode == 'detailed';

    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Section Header
          SectionHeader(
            eyebrow: S.of(context).professionalPrivacyControlEyebrow,
            title: S.of(context).professionalPrivacyAccessLevelEyebrow,
            subtitle: S.of(context).professionalPrivacyHeaderSubtitle,
          ),
          const SizedBox(height: 20),

          // Current Access Mode Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.15),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context).professionalPrivacyCurrentLevel,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                StatusPill(
                  icon: Icons.shield_outlined,
                  label: isAggregate
                      ? S.of(context).professionalPrivacyAggregateOnly
                      : (isDetailed
                          ? S.of(context).professionalPrivacyDetailed
                          : sharingScope.sharingMode),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_outlined,
                      size: 14,
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        S.of(context).professionalPrivacyConsentSince(
                              formatDateTime(context, sharingScope.consentAcceptedAt),
                            ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Shared Data list
          ConsentGroup(
            title: S.of(context).professionalPrivacySharedNow,
            rows: sharingScope.sharedNow
                .map((item) => privacyLabel(context, item))
                .toList(),
          ),

          const Divider(height: 48, thickness: 0.5),

          // Section 2: Sharing Level Switcher
          Text(
            S.of(context).professionalPrivacySharingModeTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            S.of(context).professionalPrivacySharingModeSubtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ChoiceChip(
                label: Text(S.of(context).professionalPrivacyAggregateOnly),
                selected: isAggregate,
                onSelected: (_) {
                  if (!isAggregate) {
                    onUpdateSharingMode('aggregate');
                  }
                },
                selectedColor: colorScheme.primary,
                labelStyle: TextStyle(
                  color: isAggregate ? colorScheme.onPrimary : colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              ChoiceChip(
                label: Text(S.of(context).professionalPrivacyDetailed),
                selected: isDetailed,
                onSelected: (_) {
                  if (!isDetailed) {
                    onUpdateSharingMode('detailed');
                  }
                },
                selectedColor: colorScheme.primary,
                labelStyle: TextStyle(
                  color: isDetailed ? colorScheme.onPrimary : colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: colorScheme.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isAggregate
                        ? S.of(context).professionalPrivacyAggregateModeBody
                        : S.of(context).professionalPrivacyDetailedModeBody,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 48, thickness: 0.5),

          // Section 3: Access Revocation
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.error.withValues(alpha: 0.25),
                width: 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: colorScheme.error, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      S.of(context).professionalPrivacyAccessControl,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colorScheme.onErrorContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  S.of(context).professionalPrivacyAccessControlBody,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onErrorContainer.withValues(alpha: 0.8),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: onDisconnect,
                    icon: const Icon(Icons.link_off_rounded, size: 18),
                    label: Text(
                      S.of(context).professionalRevokeNow,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.error,
                      side: BorderSide(color: colorScheme.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
