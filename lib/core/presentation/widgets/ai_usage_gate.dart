import 'package:flutter/material.dart';
import 'package:macrotracker/core/presentation/widgets/paywall_sheet.dart';
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
    return purchased == true
        ? const AiAccessResult.allowed(shouldConsumeTrial: false)
        : const AiAccessResult.denied();
  }

  static Future<void> consumeTrialUse(AiAccessResult access) async {
    if (!access.shouldConsumeTrial) {
      return;
    }
    await locator<MonetizationService>().consumeAiTrialUse();
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
                      ? (isEs
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
                child: Text(isEs ? 'Premium' : 'Upgrade'),
              ),
            ],
          ),
        );
      },
    );
  }
}
