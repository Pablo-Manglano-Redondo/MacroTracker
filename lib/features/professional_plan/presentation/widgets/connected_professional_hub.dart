import 'package:flutter/material.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_section_entities.dart';
import 'package:macrotracker/generated/l10n.dart';
import 'package:macrotracker/features/professional_plan/presentation/widgets/professional_ui_helpers.dart';
import 'package:macrotracker/features/professional_plan/presentation/widgets/summary_tab.dart';
import 'package:macrotracker/features/professional_plan/presentation/widgets/plan_tab.dart';
import 'package:macrotracker/features/professional_plan/presentation/widgets/tracking_tab.dart';
import 'package:macrotracker/features/professional_plan/presentation/widgets/privacy_tab.dart';
import 'package:macrotracker/features/professional_plan/presentation/widgets/messages_tab.dart';
import 'package:macrotracker/features/professional_plan/presentation/widgets/recipes_tab.dart';
import 'package:macrotracker/features/professional_plan/presentation/widgets/checkin_tab.dart';
import 'package:macrotracker/features/professional_plan/presentation/widgets/notes_tab.dart';

class ConnectedProfessionalHub extends StatelessWidget {
  final ProfessionalSectionSummaryEntity summary;
  final ProfessionalSharingScopeEntity sharingScope;
  final ProfessionalMessageThreadEntity messages;
  final ProfessionalHubTab selectedTab;
  final String? error;
  final ValueChanged<ProfessionalHubTab> onSelectTab;
  final VoidCallback onDisconnect;
  final ValueChanged<ProfessionalMessageEntity> onMarkMessageRead;
  final Future<void> Function(String body) onSendMessage;
  final bool sendingMessage;
  final ValueChanged<String> onUpdateSharingMode;
  final ValueChanged<String> onUpdateDailyNote;

  const ConnectedProfessionalHub({
    super.key,
    required this.summary,
    required this.sharingScope,
    required this.messages,
    required this.selectedTab,
    required this.error,
    required this.onSelectTab,
    required this.onDisconnect,
    required this.onMarkMessageRead,
    required this.onSendMessage,
    required this.sendingMessage,
    required this.onUpdateSharingMode,
    required this.onUpdateDailyNote,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HubOverviewCard(summary: summary),
        const SizedBox(height: 16),
        HubTabBar(
          selectedTab: selectedTab,
          unreadCount: messages.unreadCount,
          onSelectTab: onSelectTab,
        ),
        if (error != null) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              error!,
              style: TextStyle(color: colorScheme.onErrorContainer),
            ),
          ),
        ],
        const SizedBox(height: 16),
        switch (selectedTab) {
          ProfessionalHubTab.summary => SummaryTab(
              summary: summary,
              onUpdateDailyNote: onUpdateDailyNote,
            ),
          ProfessionalHubTab.plan => PlanTab(summary: summary),
          ProfessionalHubTab.tracking => TrackingTab(summary: summary),
          ProfessionalHubTab.checkin => CheckinTab(summary: summary),
          ProfessionalHubTab.notes => NotesTab(summary: summary),
          ProfessionalHubTab.recipes => RecipesTab(summary: summary),
          ProfessionalHubTab.privacy => PrivacyTab(
              summary: summary,
              sharingScope: sharingScope,
              onDisconnect: onDisconnect,
              onUpdateSharingMode: onUpdateSharingMode,
            ),
          ProfessionalHubTab.messages => MessagesTab(
              summary: summary,
              messages: messages,
              onMarkMessageRead: onMarkMessageRead,
              onSendMessage: onSendMessage,
              sendingMessage: sendingMessage,
            ),
        },
      ],
    );
  }
}

class HubOverviewCard extends StatelessWidget {
  final ProfessionalSectionSummaryEntity summary;

  const HubOverviewCard({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Panel(
      accent: Color.alphaBlend(
        colorScheme.primary.withValues(alpha: 0.12),
        colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: colorScheme.primary.withValues(alpha: 0.16),
                ),
                child: Icon(
                  Icons.verified_user_outlined,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      uiText(
                        context,
                        es: 'Conexión profesional activa',
                        en: 'Professional connection active',
                      ),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      summary.connection.professionalName,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            height: 1.02,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      summary.activePlan?.name ??
                          S.of(context).professionalHubNoPublishedPlan,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.25,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (summary.todayTarget != null) ...[
            Text(
              uiText(context, es: 'Objetivos diarios de tu plan', en: 'Plan daily targets'),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: CompactStat(
                    label: uiText(context, es: 'Calorías', en: 'Calories'),
                    value: '${summary.todayTarget!.kcalGoal.round()} kcal',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CompactStat(
                    label: uiText(context, es: 'Proteínas', en: 'Proteins'),
                    value: '${summary.todayTarget!.proteinGoal.round()}g',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: CompactStat(
                    label: uiText(context, es: 'Carbohidratos', en: 'Carbs'),
                    value: '${summary.todayTarget!.carbsGoal.round()}g',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CompactStat(
                    label: uiText(context, es: 'Grasas', en: 'Fats'),
                    value: '${summary.todayTarget!.fatGoal.round()}g',
                  ),
                ),
              ],
            ),
          ] else ...[
            CompactStat(
              label: uiText(context, es: 'Objetivo hoy', en: 'Today target'),
              value: S.of(context).professionalHubNoTodayTarget,
            ),
          ],
        ],
      ),
    );
  }
}

class HubTabBar extends StatelessWidget {
  final ProfessionalHubTab selectedTab;
  final int unreadCount;
  final ValueChanged<ProfessionalHubTab> onSelectTab;

  const HubTabBar({
    super.key,
    required this.selectedTab,
    required this.unreadCount,
    required this.onSelectTab,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tabs = <(ProfessionalHubTab, String, IconData)>[
      (ProfessionalHubTab.summary, S.of(context).professionalTabSummary, Icons.dashboard_outlined),
      (ProfessionalHubTab.plan, S.of(context).professionalTabPlan, Icons.assignment_outlined),
      (ProfessionalHubTab.tracking, S.of(context).professionalTabTracking, Icons.insights_outlined),
      (ProfessionalHubTab.checkin, S.of(context).professionalTabCheckin, Icons.assignment_turned_in_outlined),
      (ProfessionalHubTab.notes, S.of(context).professionalTabNotes, Icons.note_alt_outlined),
      (ProfessionalHubTab.recipes, S.of(context).professionalTabRecipes, Icons.restaurant_outlined),
      (
        ProfessionalHubTab.messages,
        unreadCount > 0
            ? S.of(context).professionalMessagesTabWithCount(unreadCount)
            : S.of(context).professionalTabMessages,
        Icons.chat_bubble_outlined
      ),
      (ProfessionalHubTab.privacy, S.of(context).professionalTabPrivacy, Icons.lock_outline),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          for (final tab in tabs)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                showCheckmark: false,
                avatar: Icon(
                  tab.$3,
                  size: 16,
                  color: selectedTab == tab.$1
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
                selected: selectedTab == tab.$1,
                label: Text(
                  tab.$2,
                  style: TextStyle(
                    fontWeight: selectedTab == tab.$1 ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
                onSelected: (_) => onSelectTab(tab.$1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
            ),
        ],
      ),
    );
  }
}
