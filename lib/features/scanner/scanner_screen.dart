import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/services.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/core/utils/navigation_options.dart';
import 'package:macrotracker/features/meal_detail/meal_detail_screen.dart';
import 'package:macrotracker/features/scanner/presentation/scanner_bloc.dart';
import 'package:macrotracker/generated/l10n.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';
import 'package:macrotracker/core/domain/usecase/get_config_usecase.dart';
import 'package:macrotracker/features/edit_meal/presentation/edit_meal_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final log = Logger('ScannerScreen');
  final MobileScannerController _cameraController = MobileScannerController();

  String? _scannedBarcode;
  bool _hasNavigatedToMealDetail = false;
  bool _isHandlingDetection = false;
  late IntakeTypeEntity _intakeTypeEntity;
  late DateTime _day;

  late ScannerBloc _scannerBloc;

  @override
  void initState() {
    _scannerBloc = locator<ScannerBloc>();
    super.initState();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    if (routeArgs is ScannerScreenArguments) {
      _intakeTypeEntity = routeArgs.intakeTypeEntity;
      _day = routeArgs.day;
    } else if (routeArgs is Map) {
      _intakeTypeEntity = routeArgs['mealType'] as IntakeTypeEntity? ??
          IntakeTypeEntity.breakfast;
      _day = routeArgs['day'] as DateTime? ?? DateTime.now();
    } else {
      _intakeTypeEntity = IntakeTypeEntity.breakfast;
      _day = DateTime.now();
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScannerBloc, ScannerState>(
      bloc: _scannerBloc,
      builder: (context, state) {
        if (state is ScannerInitial) {
          return _getScannerContent(context);
        } else if (state is ScannerLoadingState) {
          return Scaffold(
              appBar: AppBar(),
              body: const Center(child: CircularProgressIndicator()));
        } else if (state is ScannerLoadedState) {
          // Push new route after build
          Future.microtask(() {
            if (context.mounted && !_hasNavigatedToMealDetail) {
              _hasNavigatedToMealDetail = true;
              return Navigator.of(context).pushReplacementNamed(
                  NavigationOptions.mealDetailRoute,
                  arguments: MealDetailScreenArguments(state.product,
                      _intakeTypeEntity, _day, state.usesImperialUnits));
            }
          });
        } else if (state is ScannerFailedState) {
          final isProductNotFound = state.type == ScannerFailedStateType.productNotFound;
          final isEs = Localizations.localeOf(context).languageCode == 'es';
          
          return Scaffold(
            appBar: AppBar(
              title: Text(isProductNotFound 
                  ? (isEs ? 'No encontrado' : 'Not Found') 
                  : (isEs ? 'Error' : 'Error')),
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(),
                    Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isProductNotFound ? Icons.search_off_outlined : Icons.wifi_off_outlined,
                        size: 48,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      isProductNotFound
                          ? S.of(context).errorProductNotFound
                          : S.of(context).errorFetchingProductData,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (isProductNotFound && _scannedBarcode != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        '${isEs ? "Código" : "Barcode"}: $_scannedBarcode',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontFamily: 'monospace',
                            ),
                      ),
                    ],
                    const Spacer(),
                    if (isProductNotFound && _scannedBarcode != null) ...[
                      FilledButton.icon(
                        icon: const Icon(Icons.add_circle_outline_outlined),
                        label: Text(isEs ? 'Crear alimento manualmente' : 'Create food manually'),
                        onPressed: _onCreateCustomFoodPressed,
                      ),
                      const SizedBox(height: 12),
                    ],
                    OutlinedButton.icon(
                      icon: const Icon(Icons.refresh_outlined),
                      label: Text(isEs ? 'Reintentar escaneo' : 'Retry scanning'),
                      onPressed: () {
                        setState(() {
                          _isHandlingDetection = false;
                          _hasNavigatedToMealDetail = false;
                        });
                        _scannerBloc.add(ScannerResetEvent());
                        _cameraController.start();
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Scaffold _getScannerContent(BuildContext context) {
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).scanProductLabel),
        actions: [
          IconButton(
            icon: const Icon(Icons.keyboard_outlined),
            tooltip: isEs ? 'Escribir código' : 'Enter code',
            onPressed: _showManualBarcodeDialog,
          ),
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _cameraController,
              builder: (context, state, child) {
                switch (state.torchState) {
                  case TorchState.off || TorchState.unavailable:
                    return const Icon(Icons.flash_off_outlined,
                        color: Colors.grey);
                  case TorchState.on || TorchState.auto:
                    return const Icon(Icons.flash_on_outlined);
                }
              },
            ),
            onPressed: () => _cameraController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_android_outlined),
            onPressed: () => _cameraController.switchCamera(),
          ),
        ],
      ),
      body: MobileScanner(
          controller: _cameraController,
          onDetect: (capture) {
            if (_isHandlingDetection) {
              return;
            }
            final List<Barcode> barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              final barcodeResult = barcode.rawValue;
              if (barcodeResult != null && barcodeResult.trim().isNotEmpty) {
                final normalizedResult = barcodeResult.trim();
                final isProductType = barcode.type == BarcodeType.product;
                final isNumericBarcode = RegExp(r'^\d{7,15}$').hasMatch(normalizedResult);
                
                if (isProductType || isNumericBarcode) {
                  _isHandlingDetection = true;
                  _cameraController.stop();
                  HapticFeedback.lightImpact();
                  _scannedBarcode = normalizedResult;
                  log.fine('Barcode found: $normalizedResult');
                  _scannerBloc
                      .add(ScannerLoadProductEvent(barcode: normalizedResult));
                  break;
                }
              }
            }
          }),
    );
  }

  void _showManualBarcodeDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        final isEs = Localizations.localeOf(context).languageCode == 'es';
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            isEs ? 'Introducir Código de Barras' : 'Enter Barcode',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'e.g. 8410012345678',
              labelText: isEs ? 'Código de barras' : 'Barcode number',
              prefixIcon: const Icon(Icons.pin_outlined),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(isEs ? 'Cancelar' : 'Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final code = controller.text.trim();
                if (code.isNotEmpty) {
                  Navigator.of(context).pop();
                  _isHandlingDetection = true;
                  _cameraController.stop();
                  _scannedBarcode = code;
                  _scannerBloc.add(ScannerLoadProductEvent(barcode: code));
                }
              },
              child: Text(isEs ? 'Buscar' : 'Search'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _onCreateCustomFoodPressed() async {
    final barcode = _scannedBarcode;
    if (barcode == null) return;
    
    final config = await locator<GetConfigUsecase>().getConfig();
    final usesImperialUnits = config.usesImperialUnits;

    final emptyMealWithBarcode = MealEntity(
      code: barcode,
      name: '',
      brands: '',
      thumbnailImageUrl: null,
      mainImageUrl: null,
      url: null,
      mealQuantity: '100',
      mealUnit: 'g',
      servingQuantity: 100,
      servingUnit: 'g',
      servingSize: '100 g',
      nutriments: MealNutrimentsEntity.empty(),
      source: MealSourceEntity.custom,
    );

    if (mounted) {
      Navigator.of(context).pushReplacementNamed(
        NavigationOptions.editMealRoute,
        arguments: EditMealScreenArguments(
          _day,
          emptyMealWithBarcode,
          _intakeTypeEntity,
          usesImperialUnits,
        ),
      );
    }
  }
}

class ScannerScreenArguments {
  final DateTime day;
  final IntakeTypeEntity intakeTypeEntity;

  ScannerScreenArguments(this.day, this.intakeTypeEntity);
}
