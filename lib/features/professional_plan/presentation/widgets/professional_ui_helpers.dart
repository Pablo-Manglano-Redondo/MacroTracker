import 'package:flutter/material.dart';
import 'package:macrotracker/generated/l10n.dart';

enum ProfessionalHubTab {
  summary,
  plan,
  tracking,
  checkin,
  notes,
  recipes,
  privacy,
  messages,
}

String friendlyError(BuildContext context, Object error) {
  final raw = error.toString();
  if (raw.contains('SocketException') ||
      raw.contains('ClientException') ||
      raw.contains('Failed host lookup') ||
      raw.contains('Network')) {
    return S.of(context).professionalErrorOffline;
  }
  if (raw.contains('anonymous auth') || raw.contains('Authentication')) {
    return S.of(context).professionalErrorCloudIdentity;
  }
  if (raw.contains('expired')) {
    return S.of(context).professionalInviteExpired;
  }
  return S.of(context).professionalErrorAction;
}

String formatDateTime(BuildContext context, DateTime? value) {
  if (value == null) {
    return S.of(context).professionalNever;
  }
  final local = value.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final year = local.year.toString();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$day/$month/$year $hour:$minute';
}

String formatShortDate(BuildContext context, DateTime? value) {
  if (value == null) {
    return S.of(context).professionalNever;
  }
  final local = value.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  return '$day/$month';
}

String formatWeekday(BuildContext context, DateTime date) {
  final label = switch (date.weekday) {
    DateTime.monday => S.of(context).professionalWeekdayMonday,
    DateTime.tuesday => S.of(context).professionalWeekdayTuesday,
    DateTime.wednesday => S.of(context).professionalWeekdayWednesday,
    DateTime.thursday => S.of(context).professionalWeekdayThursday,
    DateTime.friday => S.of(context).professionalWeekdayFriday,
    DateTime.saturday => S.of(context).professionalWeekdaySaturday,
    DateTime.sunday => S.of(context).professionalWeekdaySunday,
    _ => '',
  };
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$label $day/$month';
}

String privacyLabel(BuildContext context, String key) {
  switch (key) {
    case 'aggregate_targets_vs_actuals':
      return S.of(context).professionalPrivacyAggregateTargets;
    case 'aggregate_tracked_days_and_meals':
      return S.of(context).professionalPrivacyAggregateTrackedDaysMeals;
    case 'aggregate_daily_adherence':
      return S.of(context).professionalPrivacyAggregateDailyAdherence;
    case 'raw_diary_entries':
      return S.of(context).professionalPrivacyRawDiary;
    case 'per_meal_detail':
      return S.of(context).professionalPrivacyPerMealDetail;
    case 'realtime_bidirectional_messages':
      return S.of(context).professionalPrivacyRealtimeMessages;
    case 'per_meal_detail_when_backend_ready':
      return S.of(context).professionalPrivacyPerMealDetailWhenReady;
    default:
      return key;
  }
}

String connectionStatusLabel(BuildContext context, String status) {
  switch (status.toLowerCase()) {
    case 'connected':
      return S.of(context).professionalStatusConnected;
    case 'active':
      return S.of(context).professionalStatusActive;
    case 'invite_only':
      return S.of(context).professionalStatusInviteOnly;
    default:
      return status;
  }
}

class Panel extends StatelessWidget {
  final Widget child;
  final Color? accent;

  const Panel({
    super.key,
    required this.child,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: accent ?? colorScheme.surface,
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: child,
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;

  const SectionHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
        ),
      ],
    );
  }
}

class StatusPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const StatusPill({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final maxWidth = MediaQuery.sizeOf(context).width * 0.78;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: colorScheme.surfaceContainerHigh,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: colorScheme.primary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CompactStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;

  const CompactStat({
    super.key,
    required this.label,
    required this.value,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: colorScheme.surfaceContainerLow,
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 15, color: colorScheme.primary),
                const SizedBox(width: 5),
              ],
              Flexible(
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: colorScheme.onSurface,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
