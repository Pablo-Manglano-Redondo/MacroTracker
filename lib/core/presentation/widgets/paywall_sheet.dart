import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:macrotracker/core/services/conversion_analytics_service.dart';
import 'package:macrotracker/core/services/monetization_service.dart';
import 'package:macrotracker/core/services/subscription_service.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

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
        _errorMessage =
            'Premium is not configured for this build. Please contact support.';
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
      await locator<ConversionAnalyticsService>().logPurchaseCompleted(
        placement: _placementName(widget.placement),
        package: _selectedPackage,
      );
      if (!mounted) {
        return;
      }
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('MacroTracker Premium is active.')),
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
        _errorMessage = 'The purchase could not be completed.';
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
      HapticFeedback.heavyImpact();
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _errorMessage = 'No active purchases were found.';
      });
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
                _errorMessage ?? 'Premium plans are not available right now.',
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
          ],
        ),
      ),
    );
  }

  Widget _buildPackageTile(Package package) {
    final product = package.storeProduct;
    final selected = package.identifier == _selectedPackage?.identifier;
    final isAnnual = package.packageType == PackageType.annual;
    final isEs = Localizations.localeOf(context).languageCode == 'es';
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
                isEs
                    ? 'Mejor valor para registrar comidas con IA todo el año.'
                    : 'Best value for AI meal logging all year.',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ],
        ),
        secondary: Text(
          product.priceString,
          style: Theme.of(context).textTheme.titleMedium,
        ),
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
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    final remaining = trialState?.remaining;
    final trialBadge = remaining == null
        ? null
        : isEs
            ? '$remaining pruebas de IA restantes'
            : '$remaining AI trials remaining';

    final commonBenefits = [
      _BenefitCopy(
        icon: Icons.auto_awesome_outlined,
        text: isEs
            ? 'Borradores de comidas por texto y foto'
            : 'AI meal drafts from text and photos',
      ),
      _BenefitCopy(
        icon: Icons.tune_outlined,
        text: isEs
            ? 'Revision editable antes de guardar'
            : 'Editable review before saving',
      ),
      _BenefitCopy(
        icon: Icons.query_stats_outlined,
        text: isEs
            ? 'Seguimiento mas rapido de macros y progreso'
            : 'Faster macro and progress tracking',
      ),
      _BenefitCopy(
        icon: Icons.psychology_alt_outlined,
        text: isEs
            ? 'La IA aprende de tus correcciones habituales'
            : 'AI learns from your usual corrections',
      ),
    ];
    final macroCoachBenefits = [
      _BenefitCopy(
        icon: Icons.track_changes_outlined,
        text: isEs
            ? 'Opciones concretas para cerrar los macros de hoy'
            : 'Concrete options to close today macros',
      ),
      _BenefitCopy(
        icon: Icons.restaurant_menu_outlined,
        text: isEs
            ? 'Cantidades ajustadas a tus calorias y proteina restante'
            : 'Servings adjusted to your remaining calories and protein',
      ),
      _BenefitCopy(
        icon: Icons.add_circle_outline,
        text: isEs
            ? 'Guarda la recomendacion en la comida correcta con un toque'
            : 'Log the recommendation to the right meal with one tap',
      ),
      _BenefitCopy(
        icon: Icons.query_stats_outlined,
        text: isEs
            ? 'Explicacion de por que encaja con tu objetivo del dia'
            : 'Explanation for why it fits today goal',
      ),
    ];

    final cta = isEs ? 'Activar Premium' : 'Start Premium';
    final processing = isEs ? 'Procesando...' : 'Processing...';
    final restore = isEs ? 'Restaurar compras' : 'Restore purchases';
    final footer = isEs
        ? 'Puedes seguir usando el registro manual gratis.'
        : 'You can keep using manual tracking for free.';

    switch (placement) {
      case PaywallPlacement.onboarding:
        return _PaywallCopy(
          title:
              isEs ? 'Acelera tu primer registro' : 'Speed up your first log',
          subtitle: isEs
              ? 'Premium desbloquea la IA para convertir comidas reales en macros revisables en segundos.'
              : 'Premium unlocks AI that turns real meals into editable macros in seconds.',
          badge: isEs ? 'Oferta de lanzamiento' : 'Launch offer',
          benefits: commonBenefits,
          ctaLabel: cta,
          processingLabel: processing,
          restoreLabel: restore,
          footer: footer,
        );
      case PaywallPlacement.aiText:
        return _PaywallCopy(
          title: isEs ? 'Convierte texto en macros' : 'Turn text into macros',
          subtitle: isEs
              ? 'Describe la comida y revisa un borrador editable antes de guardarlo.'
              : 'Describe a meal and review an editable draft before saving it.',
          badge: trialBadge,
          benefits: commonBenefits,
          ctaLabel: cta,
          processingLabel: processing,
          restoreLabel: restore,
          footer: footer,
        );
      case PaywallPlacement.aiPhoto:
        return _PaywallCopy(
          title: isEs ? 'Registra con una foto' : 'Log from a photo',
          subtitle: isEs
              ? 'Usa la camara o galeria para crear un borrador de ingredientes y macros.'
              : 'Use camera or gallery to create an ingredient and macro draft.',
          badge: trialBadge,
          benefits: commonBenefits,
          ctaLabel: cta,
          processingLabel: processing,
          restoreLabel: restore,
          footer: footer,
        );
      case PaywallPlacement.aiLimit:
        return _PaywallCopy(
          title:
              isEs ? 'Desbloquea IA ilimitada' : 'Unlock unlimited AI logging',
          subtitle: isEs
              ? 'Ya has probado la IA. Premium mantiene el registro rapido sin cortar tu flujo.'
              : 'You have tried AI logging. Premium keeps the fast flow available.',
          badge: _trialUsedBadge(isEs, trialState),
          benefits: commonBenefits,
          ctaLabel: cta,
          processingLabel: processing,
          restoreLabel: restore,
          footer: footer,
        );
      case PaywallPlacement.macroCoach:
        return _PaywallCopy(
          title: isEs
              ? 'Desbloquea tu Coach de macros'
              : 'Unlock your Macro Coach',
          subtitle: isEs
              ? 'Premium convierte los macros que te faltan en comidas concretas, cantidades ajustadas y registro rapido.'
              : 'Premium turns your remaining macros into concrete meals, adjusted servings, and fast logging.',
          badge: isEs ? 'Recomendacion Premium' : 'Premium recommendation',
          benefits: macroCoachBenefits,
          ctaLabel: cta,
          processingLabel: processing,
          restoreLabel: restore,
          footer: footer,
        );
      case PaywallPlacement.weeklyInsights:
        return _PaywallCopy(
          title: isEs
              ? 'Convierte tus datos en ajustes'
              : 'Turn your data into adjustments',
          subtitle: isEs
              ? 'Premium combina IA, adherencia y progreso para decidir que cambiar esta semana.'
              : 'Premium combines AI, adherence, and progress to decide what to change this week.',
          badge: isEs ? 'Recomendado con 3+ dias' : 'Best with 3+ days',
          benefits: commonBenefits,
          ctaLabel: cta,
          processingLabel: processing,
          restoreLabel: restore,
          footer: footer,
        );
      case PaywallPlacement.settings:
        return _PaywallCopy(
          title: 'MacroTracker Premium',
          subtitle: isEs
              ? 'Desbloquea IA para registrar comidas por texto y foto.'
              : 'Unlock AI meal interpretation from text and photos.',
          badge: isEs ? 'Oferta anual de lanzamiento' : 'Launch annual offer',
          benefits: commonBenefits,
          ctaLabel: cta,
          processingLabel: processing,
          restoreLabel: restore,
          footer: footer,
        );
    }
  }

  static String _trialUsedBadge(bool isEs, AiTrialState? trialState) {
    if (trialState == null || trialState.aiMealsSaved <= 0) {
      return isEs ? 'Prueba finalizada' : 'Trial used';
    }
    return isEs
        ? '${trialState.aiMealsSaved} comidas IA guardadas'
        : '${trialState.aiMealsSaved} AI meals saved';
  }
}

class _UsageValueStrip extends StatelessWidget {
  final AiTrialState trialState;

  const _UsageValueStrip({required this.trialState});

  @override
  Widget build(BuildContext context) {
    final isEs = Localizations.localeOf(context).languageCode == 'es';
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
              isEs
                  ? '${trialState.aiMealsSaved} comidas IA guardadas. Unos ${trialState.estimatedMinutesSaved} min ahorrados.'
                  : '${trialState.aiMealsSaved} AI meals saved. About ${trialState.estimatedMinutesSaved} min saved.',
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
