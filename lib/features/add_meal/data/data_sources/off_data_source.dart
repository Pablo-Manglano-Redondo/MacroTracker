import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:macrotracker/core/utils/app_const.dart';
import 'package:macrotracker/core/utils/off_const.dart';
import 'package:macrotracker/core/utils/ont_http_client.dart';
import 'package:macrotracker/features/add_meal/data/dto/off/off_product_dto.dart';
import 'package:macrotracker/features/add_meal/data/dto/off/off_product_response_dto.dart';
import 'package:macrotracker/features/add_meal/data/dto/off/off_word_response_dto.dart';
import 'package:macrotracker/features/scanner/data/product_not_found_exception.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class OFFDataSource {
  static const _timeoutDuration = Duration(seconds: 20); // TODO lower timeout
  final log = Logger('OFFDataSource');

  Future<OFFWordResponseDTO> fetchSearchWordResults(String searchString) async {
    try {
      final normalizedSearch = searchString.trim();
      if (normalizedSearch.length < 2) {
        return OFFWordResponseDTO(
          count: 0,
          page: 1,
          page_count: 0,
          page_size: 0,
          products: const [],
        );
      }

      final searchUrlString = OFFConst.getOffWordSearchUrl(normalizedSearch);
      final userAgentString = await AppConst.getUserAgentString();
      final httpClient = ONTHttpClient(userAgentString, http.Client());

      final response =
          await httpClient.get(searchUrlString).timeout(_timeoutDuration);
      log.fine('Fetching OFF results from: $searchUrlString');
      if (response.statusCode == OFFConst.offHttpSuccessCode) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final rawProducts =
            (decoded['products'] as List<dynamic>? ?? const <dynamic>[])
                .whereType<Map<String, dynamic>>();
        final List<OFFProductDTO> products = rawProducts
            .map(_normalizeOffProductJson)
            .map(_tryParseProduct)
            .whereType<OFFProductDTO>()
            .toList(growable: false);
        final wordResponse = OFFWordResponseDTO(
          count: decoded['count'] ?? products.length,
          page: decoded['page'] ?? 1,
          page_count: (decoded['page_count'] as num?)?.toInt(),
          page_size: (decoded['page_size'] as num?)?.toInt(),
          products: products,
        );
        log.fine('Successful response from OFF');
        return wordResponse;
      } else {
        log.warning('Failed OFF call: ${response.statusCode}');
        return Future.error(response.statusCode);
      }
    } catch (exception, stacktrace) {
      log.severe('Exception while getting OFF word search $exception');
      Sentry.captureException(exception, stackTrace: stacktrace);
      return Future.error(exception);
    }
  }

  Map<String, dynamic> _normalizeOffProductJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);
    normalized.putIfAbsent('nutriments', () => <String, dynamic>{});
    return normalized;
  }

  OFFProductDTO? _tryParseProduct(Map<String, dynamic> json) {
    try {
      return OFFProductDTO.fromJson(json);
    } catch (exception, stacktrace) {
      log.warning('Skipping malformed OFF product: $exception');
      Sentry.captureException(exception, stackTrace: stacktrace);
      return null;
    }
  }

  Future<OFFProductResponseDTO> fetchBarcodeResults(String barcode) async {
    try {
      final searchUrl = OFFConst.getOffBarcodeSearchUri(barcode);
      final userAgentString = await AppConst.getUserAgentString();
      final httpClient = ONTHttpClient(userAgentString, http.Client());

      final response =
          await httpClient.get(searchUrl).timeout(_timeoutDuration);
      log.fine('Fetching OFF result from: $searchUrl');
      if (response.statusCode == OFFConst.offHttpSuccessCode) {
        final productResponse =
            OFFProductResponseDTO.fromJson(jsonDecode(response.body));
        log.fine('Successful response from OFF');
        return productResponse;
      } else if (response.statusCode == OFFConst.offProductNotFoundCode) {
        log.warning("404 OFF Product not found");
        return Future.error(ProductNotFoundException);
      } else {
        log.warning('Failed OFF call: ${response.statusCode}');
        return Future.error(response.statusCode);
      }
    } catch (exception, stacktrace) {
      log.severe('Exception while getting OFF barcode search $exception');
      Sentry.captureException(exception, stackTrace: stacktrace);
      return Future.error(exception);
    }
  }
}
