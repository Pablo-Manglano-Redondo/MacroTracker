import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
  final Future<void> Function(String) onUpdateDailyNote;
  final VoidCallback onDismissPlanUpdate;

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
    required this.onDismissPlanUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HubOverviewCard(
          summary: summary,
          onSelectTab: onSelectTab,
          unreadCount: messages.unreadCount,
        ),
        if (summary.pendingActions.isNotEmpty) ...[
          const SizedBox(height: 12),
          PendingActionsPanel(
            summary: summary,
            onSelectTab: onSelectTab,
            onDismissPlanUpdate: onDismissPlanUpdate,
          ),
        ],
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

class PendingActionsPanel extends StatelessWidget {
  final ProfessionalSectionSummaryEntity summary;
  final ValueChanged<ProfessionalHubTab> onSelectTab;
  final VoidCallback onDismissPlanUpdate;

  const PendingActionsPanel({
    super.key,
    required this.summary,
    required this.onSelectTab,
    required this.onDismissPlanUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notifications_none_rounded, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Novedades',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${summary.pendingActionCount}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              for (int i = 0; i < summary.pendingActions.length; i++) ...[
                if (i > 0) const SizedBox(height: 8),
                _NotificationRow(
                  icon: _iconFor(summary.pendingActions[i].kind),
                  label: _labelFor(context, summary.pendingActions[i]),
                  iconColor: _iconColorFor(summary.pendingActions[i].kind, colorScheme),
                  iconBackgroundColor: _iconBgColorFor(summary.pendingActions[i].kind, colorScheme),
                  onTap: () => onSelectTab(_tabFor(summary.pendingActions[i].kind)),
                  onDismiss: summary.pendingActions[i].kind == ProfessionalPendingActionKind.plan
                      ? onDismissPlanUpdate
                      : null,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  IconData _iconFor(ProfessionalPendingActionKind kind) {
    return switch (kind) {
      ProfessionalPendingActionKind.checkin =>
        Icons.assignment_turned_in_outlined,
      ProfessionalPendingActionKind.messages => Icons.chat_bubble_outline,
      ProfessionalPendingActionKind.recipes => Icons.restaurant_outlined,
      ProfessionalPendingActionKind.plan => Icons.assignment_outlined,
      ProfessionalPendingActionKind.sync => Icons.sync_problem_outlined,
    };
  }

  Color _iconColorFor(
      ProfessionalPendingActionKind kind, ColorScheme colorScheme) {
    return switch (kind) {
      ProfessionalPendingActionKind.checkin => colorScheme.primary,
      ProfessionalPendingActionKind.messages => const Color(0xFFE7A83B),
      ProfessionalPendingActionKind.recipes => const Color(0xFFD946EF),
      ProfessionalPendingActionKind.plan => const Color(0xFF10B981),
      ProfessionalPendingActionKind.sync => const Color(0xFFEF4444),
    };
  }

  Color _iconBgColorFor(
      ProfessionalPendingActionKind kind, ColorScheme colorScheme) {
    return _iconColorFor(kind, colorScheme).withValues(alpha: 0.08);
  }

  ProfessionalHubTab _tabFor(ProfessionalPendingActionKind kind) {
    return switch (kind) {
      ProfessionalPendingActionKind.checkin => ProfessionalHubTab.checkin,
      ProfessionalPendingActionKind.messages => ProfessionalHubTab.messages,
      ProfessionalPendingActionKind.recipes => ProfessionalHubTab.recipes,
      ProfessionalPendingActionKind.plan => ProfessionalHubTab.plan,
      ProfessionalPendingActionKind.sync => ProfessionalHubTab.tracking,
    };
  }

  String _labelFor(
    BuildContext context,
    ProfessionalPendingActionEntity action,
  ) {
    return switch (action.kind) {
      ProfessionalPendingActionKind.checkin => 'Check-in solicitado',
      ProfessionalPendingActionKind.messages =>
        action.count == 1 ? '1 mensaje sin leer' : '${action.count} mensajes',
      ProfessionalPendingActionKind.recipes =>
        action.count == 1 ? '1 receta propuesta' : '${action.count} recetas',
      ProfessionalPendingActionKind.plan => 'Plan actualizado',
      ProfessionalPendingActionKind.sync =>
        action.count == 1 ? '1 sync pendiente' : '${action.count} syncs',
    };
  }
}

class _NotificationRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color iconBackgroundColor;
  final VoidCallback onTap;
  final VoidCallback? onDismiss;

  const _NotificationRow({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.onTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 16,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 28,
              height: 28,
              child: Center(
                child: onDismiss != null
                    ? IconButton(
                        icon: Icon(
                          Icons.check_circle_outline_rounded,
                          size: 20,
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                        onPressed: onDismiss,
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        splashRadius: 16,
                        tooltip: 'Marcar como visto',
                      )
                    : Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class HubOverviewCard extends StatelessWidget {
  final ProfessionalSectionSummaryEntity summary;
  final ValueChanged<ProfessionalHubTab> onSelectTab;
  final int unreadCount;

  const HubOverviewCard({
    super.key,
    required this.summary,
    required this.onSelectTab,
    required this.unreadCount,
  });

  String _getInitials(String name) {
    if (name.isEmpty) return 'N';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      final first = parts[0].isNotEmpty ? parts[0][0] : '';
      final second = parts[1].isNotEmpty ? parts[1][0] : '';
      return (first + second).toUpperCase();
    }
    return parts[0].substring(0, parts[0].length.clamp(1, 2)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Panel(
      accent: Color.alphaBlend(
        colorScheme.primary.withValues(alpha: 0.05),
        colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Beautiful circle avatar with initials
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.primary.withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: summary.connection.professionalAvatarUrl != null &&
                            summary.connection.professionalAvatarUrl!.isNotEmpty
                        ? ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: summary.connection.professionalAvatarUrl!,
                              width: 52,
                              height: 52,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Text(
                                _getInitials(summary.connection.professionalName),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                ),
                              ),
                              errorWidget: (context, url, error) => Text(
                                _getInitials(summary.connection.professionalName),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          )
                        : Text(
                            _getInitials(summary.connection.professionalName),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.surface,
                          width: 2.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            summary.connection.professionalName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.2,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.verified,
                          color: colorScheme.primary,
                          size: 16,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      summary.activePlan?.name ??
                          S.of(context).professionalHubNoPublishedPlan,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Message / Chat icon with badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton.filledTonal(
                    onPressed: () => onSelectTab(ProfessionalHubTab.messages),
                    icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
                    style: IconButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    tooltip: 'Chat con nutricionista',
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
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
                tooltip: tab.$2,
                avatar: selectedTab == tab.$1
                    ? Icon(
                        tab.$3,
                        size: 16,
                        color: colorScheme.primary,
                      )
                    : null,
                selected: selectedTab == tab.$1,
                label: selectedTab == tab.$1
                    ? Text(
                        tab.$2,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      )
                    : Icon(
                        tab.$3,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                onSelected: (_) => onSelectTab(tab.$1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: selectedTab == tab.$1
                    ? const EdgeInsets.symmetric(horizontal: 10, vertical: 8)
                    : const EdgeInsets.all(8),
              ),
            ),
        ],
      ),
    );
  }
}
