import 'package:flutter/material.dart';
import 'package:macrotracker/core/presentation/widgets/paywall_sheet.dart';
import 'package:macrotracker/core/services/conversion_analytics_service.dart';
import 'package:macrotracker/core/services/monetization_service.dart';
import 'package:macrotracker/core/utils/locator.dart';

class AiAccessResult {
  final bool allowed;
  final bool shouldConsumeTrial;

  const AiAccessResult._({
    required this.allowed,
    required this.shouldConsumeTrial,
  });

  const AiAccessResult.allowed({required bool shouldConsumeTrial})
      : this._(allowed: true, shouldConsumeTrial: shouldConsumeTrial);

  const AiAccessResult.denied()
      : this._(allowed: false, shouldConsumeTrial: false);
}

class AiUsageGate {
  static Future<AiAccessResult> ensureAccess(
    BuildContext context, {
    required PaywallPlacement placement,
  }) async {
    final service = locator<MonetizationService>();
    final state = await service.getAiTrialState();
    if (state.isPremium) {
      return const AiAccessResult.allowed(shouldConsumeTrial: false);
    }
    if (state.remaining > 0) {
      return const AiAccessResult.allowed(shouldConsumeTrial: true);
    }
    await locator<ConversionAnalyticsService>().logEvent(
      'ai_limit_reached',
      parameters: {'placement': _placementName(placement)},
    );
    if (!context.mounted) {
      return const AiAccessResult.denied();
    }
    return _showBlockedSheetAndRecheck(
      context,
      placement: placement,
      state: state,
    );
  }

  static Future<void> consumeTrialUse(AiAccessResult access) async {
    if (!access.shouldConsumeTrial) {
      return;
    }
    await locator<MonetizationService>().consumeAiTrialUse();
    await locator<ConversionAnalyticsService>().logEvent('ai_trial_used');
  }

  static Future<AiAccessResult> _showBlockedSheetAndRecheck(
    BuildContext context, {
    required PaywallPlacement placement,
    required AiTrialState state,
  }) async {
    if (!context.mounted) {
      return const AiAccessResult.denied();
    }
    final purchased = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => PaywallSheet(
        placement: placement,
        trialState: state,
      ),
    );
    if (purchased == true) {
      return const AiAccessResult.allowed(shouldConsumeTrial: false);
    }
    final refreshed = await locator<MonetizationService>().getAiTrialState();
    if (refreshed.isPremium) {
      return const AiAccessResult.allowed(shouldConsumeTrial: false);
    }
    if (refreshed.remaining > 0) {
      return const AiAccessResult.allowed(shouldConsumeTrial: true);
    }
    return const AiAccessResult.denied();
  }
}

String _placementName(PaywallPlacement placement) {
  switch (placement) {
    case PaywallPlacement.onboarding:
      return 'onboarding';
    case PaywallPlacement.aiText:
      return 'ai_text';
    case PaywallPlacement.aiPhoto:
      return 'ai_photo';
    case PaywallPlacement.aiLimit:
      return 'ai_limit';
    case PaywallPlacement.macroCoach:
      return 'macro_coach';
    case PaywallPlacement.weeklyInsights:
      return 'weekly_insights';
    case PaywallPlacement.settings:
      return 'settings';
  }
}

class AiTrialBanner extends StatelessWidget {
  final PaywallPlacement placement;

  const AiTrialBanner({
    super.key,
    required this.placement,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AiTrialState>(
      future: locator<MonetizationService>().getAiTrialState(),
      builder: (context, snapshot) {
        final state = snapshot.data;
        if (state == null || state.isPremium) {
          return const SizedBox.shrink();
        }

        final isEs = Localizations.localeOf(context).languageCode == 'es';
        final colorScheme = Theme.of(context).colorScheme;
        final remaining = state.remaining;
        final isBlocked = remaining <= 0;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isBlocked
                ? colorScheme.errorContainer.withValues(alpha: 0.35)
                : colorScheme.primaryContainer.withValues(alpha: 0.35),
            border: Border.all(
              color: isBlocked
                  ? colorScheme.error.withValues(alpha: 0.30)
                  : colorScheme.primary.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            children: [
              Icon(
                isBlocked ? Icons.lock_outline : Icons.auto_awesome_outlined,
                color: isBlocked ? colorScheme.error : colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isBlocked
                      ? state.requiresProtectedAccount
                          ? (isEs
                              ? 'Has agotado el cupo de invitado. Protege tu cuenta para desbloquear ${state.lockedFreeUses} usos gratis mas.'
                              : 'You have used the guest allowance. Protect your account to unlock ${state.lockedFreeUses} more free uses.')
                          : (isEs
                              ? 'Has usado tus ${state.limit} pruebas de IA.'
                              : 'You have used your ${state.limit} AI trials.')
                      : (isEs
                          ? '$remaining pruebas de IA gratis restantes.'
                          : '$remaining free AI trials remaining.'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              TextButton(
                onPressed: () => showModalBottomSheet<bool>(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => PaywallSheet(
                    placement: placement,
                    trialState: state,
                  ),
                ),
                child: Text(
                  state.requiresProtectedAccount
                      ? (isEs ? 'Google' : 'Google')
                      : (isEs ? 'Premium' : 'Upgrade'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
