import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:macrotracker/core/domain/usecase/get_config_usecase.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:macrotracker/features/add_meal/domain/usecase/search_products_usecase.dart';

part 'products_event.dart';

part 'products_state.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final log = Logger('ProductsBloc');

  final SearchProductsUseCase _searchProductUseCase;
  final GetConfigUsecase _getConfigUsecase;

  String _searchString = "";

  ProductsBloc(this._searchProductUseCase, this._getConfigUsecase)
      : super(ProductsInitial()) {
    on<LoadProductsEvent>((event, emit) async {
      final normalizedQuery = event.searchString.trim();
      if (normalizedQuery.isEmpty) {
        _searchString = "";
        emit(ProductsInitial());
        return;
      }

      if (normalizedQuery != _searchString) {
        _searchString = normalizedQuery;
        emit(ProductsLoadingState());
        try {
          var result = await _searchProductUseCase
              .searchOFFProductsByString(_searchString);
          if (result.isEmpty) {
            result = await _searchProductUseCase
                .searchFDCFoodByString(_searchString);
          }
          final config = await _getConfigUsecase.getConfig();

          emit(ProductsLoadedState(
              products: result, usesImperialUnits: config.usesImperialUnits));
        } catch (error) {
          log.severe(error);
          final isNetworkError = error is SocketException ||
              error.toString().contains('SocketException') ||
              error.toString().contains('Failed host lookup') ||
              error.toString().contains('NetworkIsUnreachable') ||
              error.toString().contains('Connection failed');
          if (isNetworkError) {
            try {
              final offlineResults =
                  await _searchProductUseCase.searchOfflineCache(_searchString);
              emit(ProductsOfflineState(cachedProducts: offlineResults));
            } catch (_) {
              emit(ProductsFailedState());
            }
          } else {
            emit(ProductsFailedState());
          }
        }
      }
    });
    on<RefreshProductsEvent>((event, emit) async {
      final normalizedQuery = _searchString.trim();
      if (normalizedQuery.isEmpty) {
        emit(ProductsInitial());
        return;
      }
      emit(ProductsLoadingState());
      try {
        var result = await _searchProductUseCase
            .searchOFFProductsByString(_searchString);
        if (result.isEmpty) {
          result = await _searchProductUseCase
              .searchFDCFoodByString(_searchString);
        }
        final config = await _getConfigUsecase.getConfig();
        emit(ProductsLoadedState(
            products: result, usesImperialUnits: config.usesImperialUnits));
      } catch (error) {
        log.severe(error);
        final isNetworkError = error is SocketException ||
            error.toString().contains('SocketException') ||
            error.toString().contains('Failed host lookup') ||
            error.toString().contains('NetworkIsUnreachable') ||
            error.toString().contains('Connection failed');
        if (isNetworkError) {
          try {
            final offlineResults =
                await _searchProductUseCase.searchOfflineCache(_searchString);
            emit(ProductsOfflineState(cachedProducts: offlineResults));
          } catch (_) {
            emit(ProductsFailedState());
          }
        } else {
          emit(ProductsFailedState());
        }
      }
    });
  }
}
