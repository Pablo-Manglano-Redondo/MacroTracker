import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/core/utils/navigation_options.dart';
import 'package:macrotracker/features/feature_tour/presentation/bloc/feature_tour_bloc.dart';
import 'package:macrotracker/features/home/presentation/bloc/home_bloc.dart';
import 'package:macrotracker/features/diary/presentation/bloc/diary_bloc.dart';
import 'package:macrotracker/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:macrotracker/generated/l10n.dart';

class ProductTourKeys {
  static final GlobalKey fabKey = GlobalKey(debugLabel: 'tour_fab');
  static final GlobalKey dashboardKey = GlobalKey(debugLabel: 'tour_dashboard');
  static final GlobalKey habitsKey = GlobalKey(debugLabel: 'tour_habits');
  static final GlobalKey progressKey = GlobalKey(debugLabel: 'tour_progress');
  static final GlobalKey insightsKey = GlobalKey(debugLabel: 'tour_insights');
  static final GlobalKey nutritionistPromoKey = GlobalKey(debugLabel: 'tour_nutritionist_promo');
  static final GlobalKey diaryEntriesKey = GlobalKey(debugLabel: 'tour_diary_entries');
  static final GlobalKey recipeIconKey = GlobalKey(debugLabel: 'tour_recipe_icon');
  static final GlobalKey backupSectionKey = GlobalKey(debugLabel: 'tour_backup_section');
}

class ProductTourOverlay extends StatefulWidget {
  final FeatureTourBloc featureTourBloc;
  final bool hasProfessionalTab;
  final int activePageIndex;
  final ValueChanged<int> onTabChanged;
  final bool isInsideSettings;

  const ProductTourOverlay({
    super.key,
    required this.featureTourBloc,
    required this.hasProfessionalTab,
    required this.activePageIndex,
    required this.onTabChanged,
    this.isInsideSettings = false,
  });

  @override
  State<ProductTourOverlay> createState() => _ProductTourOverlayState();
}

class _ProductTourOverlayState extends State<ProductTourOverlay> {
  int? _lastStep;
  ScrollController? _scrollController;
  StreamSubscription? _tourSubscription;
  StreamSubscription? _homeSubscription;
  StreamSubscription? _diarySubscription;
  StreamSubscription? _profileSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupScrollListener();
      _setupBlocListeners();
    });
  }

  void _setupScrollListener() {
    _updateScrollController();
  }

  void _updateScrollController() {
    String instanceName = 'homeScroll';
    if (widget.isInsideSettings) {
      instanceName = 'settingsScroll';
    } else {
      final step = widget.featureTourBloc.state.currentSlideIndex;
      if (step >= 7 && step <= 9) {
        instanceName = 'diaryScroll';
      }
    }

    if (locator.isRegistered<ScrollController>(instanceName: instanceName)) {
      final latestController = locator<ScrollController>(instanceName: instanceName);
      if (latestController != _scrollController) {
        _scrollController?.removeListener(_onScroll);
        _scrollController = latestController;
        _scrollController?.addListener(_onScroll);
      }
    } else {
      if (_scrollController != null) {
        _scrollController?.removeListener(_onScroll);
        _scrollController = null;
      }
    }
  }

  void _setupBlocListeners() {
    _tourSubscription = widget.featureTourBloc.stream.listen((state) {
      if (mounted) {
        if (state.isCompleted && widget.isInsideSettings) {
          Navigator.of(context).pop();
        }
      }
    });

    if (locator.isRegistered<HomeBloc>()) {
      _homeSubscription = locator<HomeBloc>().stream.listen((state) {
        if (mounted) {
          setState(() {});
          _handleStepChangeScroll(widget.featureTourBloc.state.currentSlideIndex);
        }
      });
    }
    if (locator.isRegistered<DiaryBloc>()) {
      _diarySubscription = locator<DiaryBloc>().stream.listen((state) {
        if (mounted) {
          setState(() {});
          _handleStepChangeScroll(widget.featureTourBloc.state.currentSlideIndex);
        }
      });
    }
    if (locator.isRegistered<ProfileBloc>()) {
      _profileSubscription = locator<ProfileBloc>().stream.listen((state) {
        if (mounted) {
          setState(() {});
          _handleStepChangeScroll(widget.featureTourBloc.state.currentSlideIndex);
        }
      });
    }
  }

  void _cancelBlocListeners() {
    _tourSubscription?.cancel();
    _homeSubscription?.cancel();
    _diarySubscription?.cancel();
    _profileSubscription?.cancel();
  }

  void _onScroll() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _scrollController?.removeListener(_onScroll);
    _cancelBlocListeners();
    super.dispose();
  }

  Offset? _getWidgetCenter(GlobalKey key) {
    final context = key.currentContext;
    if (context == null) return null;
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return null;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    return position + Offset(size.width / 2, size.height / 2);
  }

  Size? _getWidgetSize(GlobalKey key) {
    final context = key.currentContext;
    if (context == null) return null;
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return null;
    return renderBox.size;
  }

  void _handleStepChangeScroll(int step) {
    _updateScrollController();

    if (!widget.isInsideSettings) {
      // Automatically switch tabs on MainScreen to match step requirements
      final professionalIndex = 1;
      final diaryIndex = widget.hasProfessionalTab ? 2 : 1;
      final profileIndex = widget.hasProfessionalTab ? 3 : 2;

      int? expectedTab;
      if (step >= 0 && step <= 5) {
        expectedTab = 0;
      } else if (step == 6) {
        expectedTab = widget.hasProfessionalTab ? professionalIndex : 0;
      } else if (step >= 7 && step <= 9) {
        expectedTab = diaryIndex;
      } else if (step >= 10 && step <= 11) {
        expectedTab = profileIndex;
      } else if (step == 12) {
        expectedTab = 0;
      }

      if (expectedTab != null && widget.activePageIndex != expectedTab) {
        widget.onTabChanged(expectedTab);
        return;
      }

      if (step == 11 || (step == 6 && !widget.hasProfessionalTab)) {
        Navigator.of(context).pushNamed(NavigationOptions.settingsRoute);
        return;
      }
    }

    GlobalKey? targetKey;
    if (widget.isInsideSettings) {
      if (step == 6) {
        targetKey = ProductTourKeys.nutritionistPromoKey;
      } else if (step == 11) {
        targetKey = ProductTourKeys.backupSectionKey;
      }
    } else {
      if (step == 3) {
        targetKey = ProductTourKeys.habitsKey;
      } else if (step == 4) {
        targetKey = ProductTourKeys.progressKey;
      } else if (step == 5) {
        targetKey = ProductTourKeys.insightsKey;
      } else if (step == 8) {
        targetKey = ProductTourKeys.diaryEntriesKey;
      }
    }

    // Trigger additional delayed coordinate refreshes to resolve layout race conditions
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() {});
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() {});
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() {});
    });

    if (targetKey != null && targetKey.currentContext != null) {
      final context = targetKey.currentContext;
      if (context != null && _scrollController != null && _scrollController!.hasClients) {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox != null && renderBox.hasSize) {
          final scrollableState = Scrollable.maybeOf(context);
          final scrollableRenderBox = scrollableState?.context.findRenderObject() as RenderBox?;
          if (scrollableRenderBox != null) {
            final positionInScrollable = renderBox.localToGlobal(Offset.zero, ancestor: scrollableRenderBox);
            final scrollOffset = _scrollController!.offset;
            final widgetTopInScrollable = positionInScrollable.dy + scrollOffset;
            final widgetHeight = renderBox.size.height;
            final viewportHeight = scrollableRenderBox.size.height;
            
            final targetScroll = widgetTopInScrollable - (viewportHeight - widgetHeight) / 2;
            final maxScroll = _scrollController!.position.maxScrollExtent;
            final minScroll = _scrollController!.position.minScrollExtent;
            final clampedScroll = targetScroll.clamp(minScroll, maxScroll);
            
            if ((_scrollController!.offset - clampedScroll).abs() > 1.0) {
              _scrollController!.animateTo(
                clampedScroll,
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOut,
              ).then((_) {
                if (mounted) setState(() {});
              });
            } else {
              if (mounted) setState(() {});
            }
            return;
          }
        }
      }
      
      Scrollable.ensureVisible(
        targetKey.currentContext!,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        alignment: 0.5,
      ).then((_) {
        if (mounted) setState(() {});
      });
    } else if (_scrollController != null && _scrollController!.hasClients) {
      double targetScroll = 0.0;
      if (widget.isInsideSettings) {
        if (step == 6) {
          targetScroll = 350.0;
        } else if (step == 11) {
          targetScroll = 260.0;
        }
      } else {
        if (step == 3) {
          targetScroll = 520.0;
        } else if (step == 4) {
          targetScroll = 380.0;
        } else if (step == 5) {
          targetScroll = 680.0;
        } else {
          targetScroll = 0.0;
        }
      }

      if ((_scrollController!.offset - targetScroll).abs() > 1.0) {
        _scrollController!.animateTo(
          targetScroll,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        ).then((_) {
          if (mounted) setState(() {});
        });
      } else {
        if (mounted) setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeatureTourBloc, FeatureTourState>(
      bloc: widget.featureTourBloc,
      builder: (context, state) {
        if (state.isCompleted) {
          return const SizedBox.shrink();
        }

        final currentStep = state.currentSlideIndex;
        if (currentStep != _lastStep) {
          _lastStep = currentStep;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleStepChangeScroll(currentStep);
          });
        }

        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        final padding = MediaQuery.of(context).padding;

        // Read scroll offset dynamically to update highlights in real-time
        double scrollOffset = 0.0;
        _updateScrollController();
        if (_scrollController != null && _scrollController!.hasClients) {
          scrollOffset = _scrollController!.offset;
        }

        // Coordinates & Cutout size configuration
        Offset? targetOffset;
        double targetRadius = 0.0;
        Size? targetSize;
        bool isRound = true;

        if (currentStep == 1) {
          // 1. FAB Add Button (Home) - rounded rectangle highlight
          final center = _getWidgetCenter(ProductTourKeys.fabKey);
          final size = _getWidgetSize(ProductTourKeys.fabKey);
          if (center != null && size != null) {
            targetOffset = center;
            targetSize = size + const Offset(12, 12);
          } else {
            targetOffset = Offset(
              screenWidth - 44,
              screenHeight - 68 - 44 - padding.bottom,
            );
            targetSize = const Size(64, 64);
          }
          isRound = false;
        } else if (currentStep == 2) {
          // 2. Calories and Macros metrics (DashboardWidget) - dynamically scrolled
          final center = _getWidgetCenter(ProductTourKeys.dashboardKey);
          final size = _getWidgetSize(ProductTourKeys.dashboardKey);
          if (center != null && size != null) {
            targetOffset = center;
            targetSize = size + const Offset(8, 8);
          } else {
            final double appBarHeight = 56.0;
            final double headerHeight = 115.0;
            final double cardTopOffset = 105.0;
            final double highlightHeight = 220.0;
            final double highlightWidth = screenWidth - 32;
            
            targetOffset = Offset(
              screenWidth / 2,
              padding.top + appBarHeight + headerHeight + cardTopOffset + (highlightHeight / 2) - scrollOffset,
            );
            targetSize = Size(highlightWidth, highlightHeight);
          }
          isRound = false;
        } else if (currentStep == 3) {
          // 3. GymHabitsCard (dynamically computed using current scroll offset)
          final center = _getWidgetCenter(ProductTourKeys.habitsKey);
          final size = _getWidgetSize(ProductTourKeys.habitsKey);
          if (center != null && size != null) {
            targetOffset = center;
            targetSize = size + const Offset(8, 8);
          } else {
            targetOffset = Offset(screenWidth / 2, padding.top + 56.0 + 933.0 / 2 - scrollOffset);
            targetSize = Size(screenWidth - 32, 240.0);
          }
          isRound = false;
        } else if (currentStep == 4) {
          // 4. BodyProgressCard (dynamically computed using current scroll offset)
          final center = _getWidgetCenter(ProductTourKeys.progressKey);
          final size = _getWidgetSize(ProductTourKeys.progressKey);
          if (center != null && size != null) {
            targetOffset = center;
            targetSize = size + const Offset(8, 8);
          } else {
            targetOffset = Offset(screenWidth / 2, padding.top + 56.0 + 736.0 / 2 - scrollOffset);
            targetSize = Size(screenWidth - 32, 130.0);
          }
          isRound = false;
        } else if (currentStep == 5) {
          // 5. Weekly Insights Card (dynamically computed using current scroll offset)
          final center = _getWidgetCenter(ProductTourKeys.insightsKey);
          final size = _getWidgetSize(ProductTourKeys.insightsKey);
          if (center != null && size != null) {
            targetOffset = center;
            targetSize = size + const Offset(8, 8);
          } else {
            targetOffset = Offset(screenWidth / 2, padding.top + 56.0 + 1135.0 / 2 - scrollOffset);
            targetSize = Size(screenWidth - 32, 140.0);
          }
          isRound = false;
        } else if (currentStep == 6) {
          // 6. Nutricionista / Professional (Tab or Card)
          if (widget.hasProfessionalTab) {
            final totalTabs = 4;
            final tabWidth = screenWidth / totalTabs;
            targetOffset = Offset(
              1.5 * tabWidth,
              screenHeight - 34 - padding.bottom,
            );
            targetSize = const Size(76, 56);
            isRound = false;
          } else {
            final center = _getWidgetCenter(ProductTourKeys.nutritionistPromoKey);
            final size = _getWidgetSize(ProductTourKeys.nutritionistPromoKey);
            if (center != null && size != null) {
              targetOffset = center;
              targetSize = size + const Offset(8, 8);
            } else {
              // Highlight nutritionist promo card on Home screen (dynamically computed)
              targetOffset = Offset(screenWidth / 2, padding.top + 56.0 + 611.0 / 2 - scrollOffset);
              targetSize = Size(screenWidth - 32, 100.0);
            }
            isRound = false;
          }
        } else if (currentStep == 7) {
          // 7. Diario Bottom Tab Access - RRect highlight on Diario tab
          final totalTabs = widget.hasProfessionalTab ? 4 : 3;
          final diaryIndex = widget.hasProfessionalTab ? 2 : 1;
          final tabWidth = screenWidth / totalTabs;
          targetOffset = Offset(
            (diaryIndex + 0.5) * tabWidth,
            screenHeight - 34 - padding.bottom,
          );
          targetSize = const Size(76, 56);
          isRound = false;
        } else if (currentStep == 8) {
          // 8. Diary Entries List (Diary screen) - rounded rectangle highlight
          final center = _getWidgetCenter(ProductTourKeys.diaryEntriesKey);
          final size = _getWidgetSize(ProductTourKeys.diaryEntriesKey);
          if (center != null && size != null) {
            targetOffset = center;
            targetSize = size + const Offset(8, 8);
          } else {
            final double height = 220.0;
            targetOffset = Offset(
              screenWidth / 2, 
              screenHeight - 68 - padding.bottom - (height / 2) - 10,
            );
            targetSize = Size(screenWidth - 24, height);
          }
          isRound = false;
        } else if (currentStep == 9) {
          // 9. AppBar recipe library icon
          final center = _getWidgetCenter(ProductTourKeys.recipeIconKey);
          final size = _getWidgetSize(ProductTourKeys.recipeIconKey);
          if (center != null && size != null) {
            targetOffset = center;
            targetSize = size + const Offset(8, 8);
          } else {
            targetOffset = Offset(screenWidth - 40, padding.top + 28);
            targetSize = const Size(48, 48);
          }
          isRound = false;
        } else if (currentStep == 10) {
          // 10. Profile Bottom Tab Access - RRect highlight on Profile tab
          final totalTabs = widget.hasProfessionalTab ? 4 : 3;
          final profileIndex = widget.hasProfessionalTab ? 3 : 2;
          final tabWidth = screenWidth / totalTabs;
          targetOffset = Offset(
            (profileIndex + 0.5) * tabWidth,
            screenHeight - 34 - padding.bottom,
          );
          targetSize = const Size(76, 56);
          isRound = false;
        } else if (currentStep == 11) {
          // 11. Profile Backup list area
          final center = _getWidgetCenter(ProductTourKeys.backupSectionKey);
          final size = _getWidgetSize(ProductTourKeys.backupSectionKey);
          if (center != null && size != null) {
            targetOffset = center;
            targetSize = size + const Offset(8, 8);
          } else {
            targetOffset = Offset(screenWidth / 2, padding.top + 56 + 260);
            targetSize = Size(screenWidth - 24, screenHeight * 0.40);
          }
          isRound = false;
        }

        // Determine tooltip floating card position
        double? cardTop;
        double? cardBottom;
        double cardLeft = 20.0;
        double cardRight = 20.0;

        if (currentStep == 0 || currentStep == 12) {
          // Centered vertically
          cardTop = (screenHeight - 210) / 2;
        } else if (currentStep == 1) {
          // FAB is bottom right, place card at top
          cardTop = padding.top + 60.0;
        } else if (currentStep == 2) {
          // Place card at the top since metrics is in the middle
          cardTop = padding.top + 10.0;
        } else if (currentStep == 3) {
          // Habits is at bottom, place card at top
          cardTop = padding.top + 80.0;
        } else if (currentStep == 4) {
          // Progress is in middle, place card at top
          cardTop = padding.top + 80.0;
        } else if (currentStep == 5) {
          // Insights is at bottom, place card at top
          cardTop = padding.top + 80.0;
        } else if (currentStep == 6) {
          if (widget.hasProfessionalTab) {
            cardBottom = padding.bottom + 110.0;
          } else {
            cardTop = padding.top + 80.0;
          }
        } else if (currentStep == 7) {
          cardBottom = padding.bottom + 110.0;
        } else if (currentStep == 8) {
          // List is at bottom, place card at top
          cardTop = padding.top + 80.0;
        } else if (currentStep == 9) {
          cardTop = padding.top + 100.0;
        } else if (currentStep == 10) {
          cardBottom = padding.bottom + 110.0;
        } else if (currentStep == 11) {
          cardBottom = padding.bottom + 80.0;
        }

        final stepTitle = _getStepTitle(context, currentStep);
        final stepDesc = _getStepDescription(context, currentStep);
        final nextBtnLabel = currentStep == 12
            ? S.of(context).featureTourStart
            : S.of(context).featureTourNext;

        // Check steps that require direct user interaction
        final bool isInteractiveStep = currentStep == 1 || 
            (currentStep == 6 && widget.hasProfessionalTab) || 
            currentStep == 7 || 
            currentStep == 10;
            
        final showNextButton = !isInteractiveStep;

        return PassThroughHitTestWidget(
          targetOffset: targetOffset,
          targetRadius: targetRadius,
          targetSize: targetSize,
          isRound: isRound,
          allowInteraction: isInteractiveStep,
          child: Stack(
            children: [
              // Dark Overlay with Cutout hole
              Positioned.fill(
                child: CustomPaint(
                  painter: TourCutoutPainter(
                    targetOffset: targetOffset,
                    targetRadius: targetRadius,
                    targetSize: targetSize,
                    isRound: isRound,
                    borderColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              
              // Barrier to absorb taps outside the cutout
              const Positioned.fill(
                child: ModalBarrier(dismissible: false),
              ),

              // Glassmorphic Card
              Positioned(
                top: cardTop,
                bottom: cardBottom,
                left: cardLeft,
                right: cardRight,
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 300),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.scale(
                        scale: 0.96 + (value * 0.04),
                        child: child,
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: Theme.of(context).brightness == Brightness.dark
                                ? [
                                    Colors.black.withValues(alpha: 0.65),
                                    Colors.black.withValues(alpha: 0.45),
                                  ]
                                : [
                                    Colors.white.withValues(alpha: 0.88),
                                    Colors.white.withValues(alpha: 0.70),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white.withValues(alpha: 0.16)
                                : Colors.black.withValues(alpha: 0.08),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  S.of(context).featureTourStepCounter(
                                    currentStep + 1,
                                    13,
                                  ),
                                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (currentStep < 12)
                                  TextButton(
                                    onPressed: () {
                                      widget.featureTourBloc.add(SkipTourEvent());
                                    },
                                    style: TextButton.styleFrom(
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    child: Text(
                                      S.of(context).featureTourSkip,
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              stepTitle,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              stepDesc,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                height: 1.35,
                                fontSize: 13.5,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Back button
                                if (currentStep > 0)
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      final prevStep = currentStep - 1;
                                      _handleNavigationTabs(prevStep);
                                      widget.featureTourBloc.add(PrevSlideEvent());
                                    },
                                    icon: const Icon(Icons.arrow_back, size: 14),
                                    label: Text(S.of(context).featureTourBack),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 14),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  )
                                else
                                  const SizedBox.shrink(),
                                
                                // Next / Action indicator button
                                if (showNextButton)
                                  FilledButton.icon(
                                    onPressed: () {
                                      final nextStep = currentStep + 1;
                                      _handleNavigationTabs(nextStep);
                                      widget.featureTourBloc.add(NextSlideEvent());
                                    },
                                    icon: const Icon(Icons.arrow_forward, size: 14),
                                    label: Text(nextBtnLabel),
                                    style: FilledButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 18),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  )
                                else
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(100),
                                      border: Border.all(
                                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.35),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const _PulsingIcon(),
                                        const SizedBox(width: 8),
                                        Text(
                                          S.of(context).featureTourTapHighlightedArea,
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.primary,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleNavigationTabs(int targetStep) {
    if (widget.isInsideSettings) {
      if (targetStep != 6 && targetStep != 11) {
        Navigator.of(context).pop();
        return;
      }
    } else {
      if ((targetStep == 6 && !widget.hasProfessionalTab) || targetStep == 11) {
        Navigator.of(context).pushNamed(NavigationOptions.settingsRoute);
        return;
      }
    }

    final professionalIndex = 1;
    final diaryIndex = widget.hasProfessionalTab ? 2 : 1;
    final profileIndex = widget.hasProfessionalTab ? 3 : 2;

    if (targetStep >= 0 && targetStep <= 5) {
      if (widget.activePageIndex != 0) {
        widget.onTabChanged(0);
      }
    } else if (targetStep == 6) {
      if (widget.hasProfessionalTab) {
        if (widget.activePageIndex != professionalIndex) {
          widget.onTabChanged(professionalIndex);
        }
      } else {
        if (widget.activePageIndex != 0) {
          widget.onTabChanged(0);
        }
      }
    } else if (targetStep >= 7 && targetStep <= 9) {
      if (widget.activePageIndex != diaryIndex) {
        widget.onTabChanged(diaryIndex);
      }
    } else if (targetStep >= 10 && targetStep <= 11) {
      if (widget.activePageIndex != profileIndex) {
        widget.onTabChanged(profileIndex);
      }
    } else if (targetStep == 12) {
      if (widget.activePageIndex != 0) {
        widget.onTabChanged(0);
      }
    }
  }

  String _getStepTitle(BuildContext context, int step) {
    switch (step) {
      case 0:
        return S.of(context).featureTourTitle0;
      case 1:
        return S.of(context).featureTourTitle1;
      case 2:
        return S.of(context).featureTourTitle2;
      case 3:
        return S.of(context).featureTourTitle3;
      case 4:
        return S.of(context).featureTourTitle4;
      case 5:
        return S.of(context).featureTourTitle5;
      case 6:
        return S.of(context).featureTourTitle6;
      case 7:
        return S.of(context).featureTourTitle7;
      case 8:
        return S.of(context).featureTourTitle8;
      case 9:
        return S.of(context).featureTourTitle9;
      case 10:
        return S.of(context).featureTourTitle10;
      case 11:
        return S.of(context).featureTourTitle11;
      case 12:
        return S.of(context).featureTourTitle12;
      default:
        return '';
    }
  }

  String _getStepDescription(BuildContext context, int step) {
    switch (step) {
      case 0:
        return S.of(context).featureTourDesc0;
      case 1:
        return S.of(context).featureTourDesc1;
      case 2:
        return S.of(context).featureTourDesc2;
      case 3:
        return S.of(context).featureTourDesc3;
      case 4:
        return S.of(context).featureTourDesc4;
      case 5:
        return S.of(context).featureTourDesc5;
      case 6:
        return S.of(context).featureTourDesc6;
      case 7:
        return S.of(context).featureTourDesc7;
      case 8:
        return S.of(context).featureTourDesc8;
      case 9:
        return S.of(context).featureTourDesc9;
      case 10:
        return S.of(context).featureTourDesc10;
      case 11:
        return S.of(context).featureTourDesc11;
      case 12:
        return S.of(context).featureTourDesc12;
      default:
        return '';
    }
  }
}

class PassThroughHitTestWidget extends SingleChildRenderObjectWidget {
  final Offset? targetOffset;
  final double targetRadius;
  final Size? targetSize;
  final bool isRound;
  final bool allowInteraction;

  const PassThroughHitTestWidget({
    super.key,
    required super.child,
    required this.targetOffset,
    required this.targetRadius,
    this.targetSize,
    required this.isRound,
    required this.allowInteraction,
  });

  @override
  RenderPassThroughHitTest createRenderObject(BuildContext context) {
    return RenderPassThroughHitTest(
      targetOffset: targetOffset,
      targetRadius: targetRadius,
      targetSize: targetSize,
      isRound: isRound,
      allowInteraction: allowInteraction,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderPassThroughHitTest renderObject) {
    renderObject
      ..targetOffset = targetOffset
      ..targetRadius = targetRadius
      ..targetSize = targetSize
      ..isRound = isRound
      ..allowInteraction = allowInteraction;
  }
}

class RenderPassThroughHitTest extends RenderProxyBox {
  Offset? targetOffset;
  double targetRadius;
  Size? targetSize;
  bool isRound;
  bool allowInteraction;

  RenderPassThroughHitTest({
    required this.targetOffset,
    required this.targetRadius,
    this.targetSize,
    required this.isRound,
    required this.allowInteraction,
  });

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (!allowInteraction || targetOffset == null) {
      return super.hitTest(result, position: position);
    }

    bool isInside = false;
    if (isRound) {
      final distance = (position - targetOffset!).distance;
      isInside = distance <= targetRadius;
    } else {
      final rectSize = targetSize ?? Size(targetRadius * 2, targetRadius * 2);
      final rect = Rect.fromCenter(
        center: targetOffset!,
        width: rectSize.width,
        height: rectSize.height,
      );
      isInside = rect.contains(position);
    }

    if (isInside) {
      // Bypasses the hit test on this overlay so it goes to widgets behind it
      return false;
    }

    return super.hitTest(result, position: position);
  }
}

class TourCutoutPainter extends CustomPainter {
  final Offset? targetOffset;
  final double targetRadius;
  final Size? targetSize;
  final bool isRound;
  final Color borderColor;

  TourCutoutPainter({
    required this.targetOffset,
    required this.targetRadius,
    this.targetSize,
    required this.isRound,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.60);
    if (targetOffset == null) {
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
      return;
    }

    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
    // Draw full background mask
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Subtract the cutout
    final cutoutPaint = Paint()
      ..blendMode = BlendMode.dstOut
      ..color = Colors.black;

    if (isRound) {
      canvas.drawCircle(targetOffset!, targetRadius, cutoutPaint);
    } else {
      final rectSize = targetSize ?? Size(targetRadius * 2, targetRadius * 2);
      final rect = Rect.fromCenter(
        center: targetOffset!,
        width: rectSize.width,
        height: rectSize.height,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(16)),
        cutoutPaint,
      );
    }
    canvas.restore();

    // Draw a premium glowing focus border around the cutout
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    if (isRound) {
      canvas.drawCircle(targetOffset!, targetRadius, borderPaint);
    } else {
      final rectSize = targetSize ?? Size(targetRadius * 2, targetRadius * 2);
      final rect = Rect.fromCenter(
        center: targetOffset!,
        width: rectSize.width,
        height: rectSize.height,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(16)),
        borderPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant TourCutoutPainter oldDelegate) {
    return oldDelegate.targetOffset != targetOffset ||
        oldDelegate.targetRadius != targetRadius ||
        oldDelegate.targetSize != targetSize ||
        oldDelegate.isRound != isRound ||
        oldDelegate.borderColor != borderColor;
  }
}

class _PulsingIcon extends StatefulWidget {
  const _PulsingIcon();

  @override
  State<_PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<_PulsingIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Icon(
        Icons.touch_app,
        color: Theme.of(context).colorScheme.primary,
        size: 18,
      ),
    );
  }
}


