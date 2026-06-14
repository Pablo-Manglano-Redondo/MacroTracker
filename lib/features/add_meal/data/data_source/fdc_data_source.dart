import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';

import 'package:http/http.dart' as http;
import 'package:macrotracker/core/utils/env.dart';
import 'package:macrotracker/features/add_meal/data/dto/fdc/fdc_const.dart';
import 'package:macrotracker/features/add_meal/data/dto/fdc/fdc_word_response_dto.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class FDCDataSource {
  static const _timeoutDuration = Duration(seconds: 10);
  final log = Logger('FDCDataSource');

  Future<FDCWordResponseDTO> fetchSearchWordResults(String searchString) async {
    try {
      final searchUrlString =
          FDCConst.getFDCWordSearchUrl(searchString, Env.fdcApiKey);

      final response =
          await http.get(searchUrlString).timeout(_timeoutDuration);
      log.fine('Fetching FDC results from: $searchUrlString');
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return Future.error(
          HttpException('FDC search failed with status ${response.statusCode}'),
        );
      }

      final wordResponse =
          FDCWordResponseDTO.fromJson(jsonDecode(response.body));
      log.fine('Successful response from FDC');
      return wordResponse;
    } catch (exception, stacktrace) {
      log.severe('Exception while getting FDC word search $exception');
      if (_shouldReportToSentry(exception)) {
        Sentry.captureException(exception, stackTrace: stacktrace);
      }
      return Future.error(exception);
    }
  }

  bool _shouldReportToSentry(Object exception) {
    if (exception is SocketException || exception is TimeoutException) {
      return false;
    }
    final message = exception.toString().toLowerCase();
    return !message.contains('socketexception') &&
        !message.contains('failed host lookup') &&
        !message.contains('networkisunreachable') &&
        !message.contains('connection failed') &&
        !message.contains('timed out');
  }
}
