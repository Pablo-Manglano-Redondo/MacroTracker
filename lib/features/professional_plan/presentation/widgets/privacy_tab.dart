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
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Panel(
          accent: Color.alphaBlend(
            colorScheme.tertiary.withValues(alpha: 0.10),
            colorScheme.surface,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                eyebrow: uiText(context, es: 'Control de privacidad', en: 'Privacy control'),
                title: S.of(context).professionalPrivacyCurrentLevel,
                subtitle: uiText(
                  context,
                  es: 'Esta sección describe el nivel real de datos compartidos ahora mismo, sin prometer más de lo activo.',
                  en: 'This section describes the real level of data being shared right now, without promising more than what is active.',
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  StatusPill(
                    icon: Icons.shield_outlined,
                    label: sharingScope.sharingMode == 'aggregate'
                        ? S.of(context).professionalPrivacyAggregateOnly
                        : (sharingScope.sharingMode == 'detailed'
                            ? (uiText(context, es: 'Detallado', en: 'Detailed'))
                            : sharingScope.sharingMode),
                  ),
                  StatusPill(
                    icon: Icons.schedule_outlined,
                    label: S.of(context).professionalPrivacyConsentSince(
                      formatDateTime(context, sharingScope.consentAcceptedAt),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Panel(
          child: ConsentGroup(
            title: S.of(context).professionalPrivacySharedNow,
            rows: sharingScope.sharedNow
                .map((item) => privacyLabel(context, item))
                .toList(),
          ),
        ),
        const SizedBox(height: 16),
        Panel(
          accent: colorScheme.errorContainer,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                eyebrow: uiText(context, es: 'Acceso', en: 'Access'),
                title: S.of(context).professionalPrivacyAccessControl,
                subtitle: S.of(context).professionalPrivacyAccessControlBody,
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: onDisconnect,
                icon: const Icon(Icons.link_off_outlined),
                label: Text(S.of(context).professionalRevokeNow),
              ),
            ],
          ),
        ),
      ],
    );
  }

}
