import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:macrotracker/core/services/cloud_account_service.dart';
import 'package:macrotracker/core/services/conversion_analytics_service.dart';
import 'package:macrotracker/core/services/monetization_service.dart';
import 'package:macrotracker/core/services/subscription_service.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/generated/l10n.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:macrotracker/core/utils/url_const.dart';

enum PaywallPlacement {
  onboarding,
  aiText,
  aiPhoto,
  aiLimit,
  macroCoach,
  weeklyInsights,
  settings,
}

class PaywallSheet extends StatefulWidget {
  final PaywallPlacement placement;
  final AiTrialState? trialState;

  const PaywallSheet({
    super.key,
    this.placement = PaywallPlacement.settings,
    this.trialState,
  });

  @override
  State<PaywallSheet> createState() => _PaywallSheetState();
}

class _PaywallSheetState extends State<PaywallSheet> {
  final _subscriptionService = locator<SubscriptionService>();

  List<Offering> _offerings = [];
  Package? _selectedPackage;
  bool _isLoadingOfferings = true;
  bool _isPurchasing = false;
  bool _isProtectingAccount = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    locator<ConversionAnalyticsService>().logPaywallViewed(
      placement: _placementName(widget.placement),
      aiTrialsRemaining: widget.trialState?.remaining,
    );
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    final offeringsList = await _subscriptionService.getOfferings();
    if (!mounted) {
      return;
    }
    setState(() {
      _offerings = offeringsList;
      _isLoadingOfferings = false;
      if (_offerings.isNotEmpty &&
          _offerings.first.availablePackages.isNotEmpty) {
        final packages = _offerings.first.availablePackages;
        _selectedPackage = packages.firstWhere(
          (package) => package.packageType == PackageType.annual,
          orElse: () => packages.first,
        );
      } else if (!_subscriptionService.isConfigured) {
        _errorMessage = S.of(context).paywallPremiumNotConfigured;
      }
    });
  }

  Future<void> _buySelected() async {
    if (_selectedPackage == null || _isPurchasing) {
      return;
    }

    HapticFeedback.mediumImpact();
    await locator<ConversionAnalyticsService>().logPurchaseStarted(
      placement: _placementName(widget.placement),
      package: _selectedPackage!,
    );
    setState(() {
      _isPurchasing = true;
      _errorMessage = null;
    });

    final success =
        await _subscriptionService.purchasePackage(_selectedPackage!);
    if (!mounted) {
      return;
    }

    setState(() => _isPurchasing = false);
    if (success) {
      await locator<MonetizationService>().markAsFoundingMember();
      await locator<ConversionAnalyticsService>().logPurchaseCompleted(
        placement: _placementName(widget.placement),
        package: _selectedPackage,
      );
      if (!mounted) {
        return;
      }
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).paywallPremiumActive)),
      );
      Navigator.of(context).pop(true);
    } else {
      await locator<ConversionAnalyticsService>().logPurchaseFailed(
        placement: _placementName(widget.placement),
        package: _selectedPackage,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = S.of(context).paywallPurchaseFailed;
      });
    }
  }

  Future<void> _restorePurchases() async {
    if (_isPurchasing) {
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() {
      _isPurchasing = true;
      _errorMessage = null;
    });

    final success = await _subscriptionService.restorePurchases();
    if (!mounted) {
      return;
    }

    setState(() => _isPurchasing = false);
    await locator<ConversionAnalyticsService>()
        .logPurchaseRestored(restored: success);
    if (!mounted) {
      return;
    }
    if (success) {
      await locator<MonetizationService>().markAsFoundingMember();
      if (!mounted) {
        return;
      }
      HapticFeedback.heavyImpact();
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _errorMessage = S.of(context).paywallNoActivePurchases;
      });
    }
  }

  Future<void> _protectAccount() async {
    if (_isProtectingAccount) {
      return;
    }
    setState(() {
      _isProtectingAccount = true;
    });
    try {
      final opened = await locator<CloudAccountService>().protectWithGoogle();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            opened
                ? S.of(context).paywallGoogleComplete
                : S.of(context).paywallGoogleOpenFailed,
          ),
        ),
      );
      Navigator.of(context).pop(false);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = S.of(context).paywallGoogleLinkStartFailed;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isProtectingAccount = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final copy = _PaywallCopy.forPlacement(context, widget.placement,
        trialState: widget.trialState);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          18,
          12,
          18,
          MediaQuery.of(context).viewInsets.bottom + 18,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    copy.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              copy.subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (copy.badge != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: colorScheme.primaryContainer.withValues(alpha: 0.45),
                  ),
                  child: Text(
                    copy.badge!,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 18),
            if (widget.trialState != null &&
                widget.trialState!.aiMealsSaved > 0) ...[
              _UsageValueStrip(trialState: widget.trialState!),
              const SizedBox(height: 18),
            ],
            for (final benefit in copy.benefits)
              _BenefitRow(icon: benefit.icon, text: benefit.text),
            const _ComparisonTable(),
            const SizedBox(height: 18),
            if (_isLoadingOfferings)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_offerings.isNotEmpty)
              RadioGroup<String>(
                groupValue: _selectedPackage?.identifier,
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _selectedPackage = _offerings.first.availablePackages
                        .firstWhere((package) => package.identifier == value);
                  });
                  locator<ConversionAnalyticsService>()
                      .logPaywallPackageSelected(
                    placement: _placementName(widget.placement),
                    package: _selectedPackage!,
                  );
                },
                child: Column(
                  children: _offerings.first.availablePackages
                      .map(_buildPackageTile)
                      .toList(growable: false),
                ),
              )
            else
              Text(
                _errorMessage ?? S.of(context).paywallPremiumUnavailable,
                style: TextStyle(color: colorScheme.error),
              ),
            if (_errorMessage != null && _offerings.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                _errorMessage!,
                style: TextStyle(color: colorScheme.error),
              ),
            ],
            const SizedBox(height: 18),
            FilledButton(
              onPressed: _selectedPackage == null || _isPurchasing
                  ? null
                  : _buySelected,
              child: Text(_isPurchasing ? copy.processingLabel : copy.ctaLabel),
            ),
            TextButton(
              onPressed: _isPurchasing ? null : _restorePurchases,
              child: Text(copy.restoreLabel),
            ),
            Text(
              copy.footer,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (widget.trialState?.requiresProtectedAccount == true) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: colorScheme.tertiaryContainer.withValues(alpha: 0.5),
                  border: Border.all(
                    color: colorScheme.tertiary.withValues(alpha: 0.18),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.verified_user_outlined,
                          color: colorScheme.tertiary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            S.of(context).paywallUnlockFreeUsesTitle,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      S.of(context).paywallUnlockFreeUsesBody(
                            widget.trialState!.lockedFreeUses,
                          ),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.tonalIcon(
                      onPressed: _isProtectingAccount ? null : _protectAccount,
                      icon: _isProtectingAccount
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.login_outlined),
                      label: Text(
                        S.of(context).paywallProtectWithGoogle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () async {
                    final languageCode =
                        Localizations.localeOf(context).languageCode;
                    final privacyUrl = languageCode == 'es'
                        ? URLConst.privacyPolicyURLEs
                        : URLConst.privacyPolicyURLEn;
                    final uri = Uri.parse(privacyUrl);
                    if (await canLaunchUrl(uri)) {
                      launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  child: Text(
                    S.of(context).privacyPolicyLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      decoration: TextDecoration.underline,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '•',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () async {
                    final uri = Uri.parse(
                        'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/');
                    if (await canLaunchUrl(uri)) {
                      launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  child: Text(
                    S.of(context).paywallTermsOfUseEula,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      decoration: TextDecoration.underline,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageTile(Package package) {
    final product = package.storeProduct;
    final selected = package.identifier == _selectedPackage?.identifier;
    final isAnnual = package.packageType == PackageType.annual;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: RadioListTile<String>(
        value: package.identifier,
        selected: selected,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(product.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.description),
            if (isAnnual) ...[
              const SizedBox(height: 4),
              Text(
                S.of(context).paywallBestAnnualValue,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ],
        ),
        secondary: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              product.priceString,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (isAnnual)
              Text(
                _getMonthlyPriceString(product),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
          ],
        ),
      ),
    );
  }

  String _getMonthlyPriceString(StoreProduct product) {
    final pricePerMonth = product.price / 12;
    final symbolRegExp = RegExp(r'[^\d\s\.,]+');
    final match = symbolRegExp.firstMatch(product.priceString);
    final symbol = match != null ? match.group(0) : product.currencyCode;

    final isSuffix = product.priceString.trim().endsWith(symbol ?? '');
    final isSpanish = Localizations.localeOf(context).languageCode == 'es';
    if (isSuffix) {
      return '${pricePerMonth.toStringAsFixed(2)} $symbol/${isSpanish ? 'mes' : 'mo'}';
    } else {
      return '$symbol${pricePerMonth.toStringAsFixed(2)}/${isSpanish ? 'mes' : 'mo'}';
    }
  }
}

class _ComparisonTable extends StatelessWidget {
  const _ComparisonTable();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSpanish = Localizations.localeOf(context).languageCode == 'es';

    final freeLabel = isSpanish ? 'Gratis' : 'Free';
    final premiumLabel = isSpanish ? 'Premium' : 'Premium';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                const Expanded(flex: 3, child: SizedBox.shrink()),
                Expanded(
                  flex: 2,
                  child: Text(
                    freeLabel,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    premiumLabel,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 6),
          _buildRow(
            context,
            isSpanish ? 'Registro diario con IA' : 'Daily AI Logging',
            isSpanish ? '5 comidas/día' : '5 meals/day',
            isSpanish ? 'Ilimitado' : 'Unlimited',
          ),
          _buildRow(
            context,
            isSpanish ? 'Sugerencias Macro Coach' : 'Macro Coach Suggestions',
            isSpanish ? 'Bloqueado' : 'Locked',
            isSpanish ? 'Incluido' : 'Included',
          ),
          _buildRow(
            context,
            isSpanish ? 'Ajustes semanales' : 'Weekly adjustments',
            isSpanish ? 'Bloqueado' : 'Locked',
            isSpanish ? 'Incluido' : 'Included',
          ),
          _buildRow(
            context,
            isSpanish ? 'Sincronización en la nube' : 'Cloud sync & backup',
            isSpanish ? 'Manual' : 'Manual',
            isSpanish ? 'Automática' : 'Automatic',
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    BuildContext context,
    String feature,
    String freeVal,
    String premiumVal,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              feature,
              style: theme.textTheme.bodySmall,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              freeVal,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              premiumVal,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
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

class _PaywallCopy {
  final String title;
  final String subtitle;
  final String? badge;
  final List<_BenefitCopy> benefits;
  final String ctaLabel;
  final String processingLabel;
  final String restoreLabel;
  final String footer;

  const _PaywallCopy({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.benefits,
    required this.ctaLabel,
    required this.processingLabel,
    required this.restoreLabel,
    required this.footer,
  });

  static _PaywallCopy forPlacement(
    BuildContext context,
    PaywallPlacement placement, {
    AiTrialState? trialState,
  }) {
    final remaining = trialState?.remaining;
    final trialBadge = remaining == null
        ? null
        : S.of(context).paywallTrialRemainingBadge(remaining);

    final commonBenefits = [
      _BenefitCopy(
        icon: Icons.auto_awesome_outlined,
        text: S.of(context).paywallBenefitAiDrafts,
      ),
      _BenefitCopy(
        icon: Icons.tune_outlined,
        text: S.of(context).paywallBenefitEditableReview,
      ),
      _BenefitCopy(
        icon: Icons.query_stats_outlined,
        text: S.of(context).paywallBenefitFasterTracking,
      ),
      _BenefitCopy(
        icon: Icons.psychology_alt_outlined,
        text: S.of(context).paywallBenefitLearnsCorrections,
      ),
    ];
    final macroCoachBenefits = [
      _BenefitCopy(
        icon: Icons.track_changes_outlined,
        text: S.of(context).paywallBenefitCloseTodayMacros,
      ),
      _BenefitCopy(
        icon: Icons.restaurant_menu_outlined,
        text: S.of(context).paywallBenefitAdjustedServings,
      ),
      _BenefitCopy(
        icon: Icons.add_circle_outline,
        text: S.of(context).paywallBenefitOneTapLog,
      ),
      _BenefitCopy(
        icon: Icons.query_stats_outlined,
        text: S.of(context).paywallBenefitGoalExplanation,
      ),
    ];

    final cta = S.of(context).paywallStartPremium;
    final processing = S.of(context).paywallProcessing;
    final restore = S.of(context).paywallRestorePurchases;
    final footer = S.of(context).paywallManualTrackingFooter;

    switch (placement) {
      case PaywallPlacement.onboarding:
        return _PaywallCopy(
          title: S.of(context).paywallOnboardingTitle,
          subtitle: S.of(context).paywallOnboardingSubtitle,
          badge: S.of(context).paywallLaunchOfferBadge,
          benefits: commonBenefits,
          ctaLabel: cta,
          processingLabel: processing,
          restoreLabel: restore,
          footer: footer,
        );
      case PaywallPlacement.aiText:
        return _PaywallCopy(
          title: S.of(context).paywallAiTextTitle,
          subtitle: S.of(context).paywallAiTextSubtitle,
          badge: trialBadge,
          benefits: commonBenefits,
          ctaLabel: cta,
          processingLabel: processing,
          restoreLabel: restore,
          footer: footer,
        );
      case PaywallPlacement.aiPhoto:
        return _PaywallCopy(
          title: S.of(context).paywallAiPhotoTitle,
          subtitle: S.of(context).paywallAiPhotoSubtitle,
          badge: trialBadge,
          benefits: commonBenefits,
          ctaLabel: cta,
          processingLabel: processing,
          restoreLabel: restore,
          footer: footer,
        );
      case PaywallPlacement.aiLimit:
        return _PaywallCopy(
          title: S.of(context).paywallAiLimitTitle,
          subtitle: S.of(context).paywallAiLimitSubtitle,
          badge: _trialUsedBadge(context, trialState),
          benefits: commonBenefits,
          ctaLabel: cta,
          processingLabel: processing,
          restoreLabel: restore,
          footer: footer,
        );
      case PaywallPlacement.macroCoach:
        return _PaywallCopy(
          title: S.of(context).paywallMacroCoachTitle,
          subtitle: S.of(context).paywallMacroCoachSubtitle,
          badge: S.of(context).paywallPremiumRecommendationBadge,
          benefits: macroCoachBenefits,
          ctaLabel: cta,
          processingLabel: processing,
          restoreLabel: restore,
          footer: footer,
        );
      case PaywallPlacement.weeklyInsights:
        return _PaywallCopy(
          title: S.of(context).paywallWeeklyInsightsTitle,
          subtitle: S.of(context).paywallWeeklyInsightsSubtitle,
          badge: S.of(context).paywallBestWithThreeDaysBadge,
          benefits: commonBenefits,
          ctaLabel: cta,
          processingLabel: processing,
          restoreLabel: restore,
          footer: footer,
        );
      case PaywallPlacement.settings:
        return _PaywallCopy(
          title: 'MacroTracker Premium',
          subtitle: S.of(context).paywallSettingsSubtitle,
          badge: S.of(context).paywallLaunchAnnualOfferBadge,
          benefits: commonBenefits,
          ctaLabel: cta,
          processingLabel: processing,
          restoreLabel: restore,
          footer: footer,
        );
    }
  }

  static String _trialUsedBadge(BuildContext context, AiTrialState? trialState) {
    if (trialState == null || trialState.aiMealsSaved <= 0) {
      return S.of(context).paywallTrialUsedBadge;
    }
    return S.of(context).paywallAiMealsSavedBadge(trialState.aiMealsSaved);
  }
}

class _UsageValueStrip extends StatelessWidget {
  final AiTrialState trialState;

  const _UsageValueStrip({required this.trialState});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: colorScheme.primaryContainer.withValues(alpha: 0.32),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(Icons.timer_outlined, color: colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              S.of(context).paywallUsageValueStrip(
                    trialState.aiMealsSaved,
                    trialState.estimatedMinutesSaved,
                  ),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitCopy {
  final IconData icon;
  final String text;

  const _BenefitCopy({
    required this.icon,
    required this.text,
  });
}

class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BenefitRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
