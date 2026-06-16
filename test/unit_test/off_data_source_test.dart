import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/features/add_meal/data/data_source/off_data_source.dart';
import 'package:macrotracker/features/scanner/data/product_not_found_exception.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class MockHttpClient extends http.BaseClient {
  final Future<http.Response> Function(http.BaseRequest) sendHandler;
  MockHttpClient(this.sendHandler);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await sendHandler(request);
    return http.StreamedResponse(
      Stream.value(response.bodyBytes),
      response.statusCode,
      contentLength: response.contentLength,
      request: request,
      headers: response.headers,
      isRedirect: response.isRedirect,
      persistentConnection: response.persistentConnection,
      reasonPhrase: response.reasonPhrase,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    locator.allowReassignment = true;
    await Sentry.init((options) => options.dsn = '');

    // Mock PackageInfo channel
    const channel = MethodChannel('dev.fluttercommunity.plus/package_info');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'getAll') {
        return {
          'appName': 'MacroTracker',
          'packageName': 'com.epsait.macrotracker',
          'version': '1.2.3',
          'buildNumber': '45',
          'buildSignature': '',
        };
      }
      return null;
    });
  });

  group('OFFDataSource Word Search Tests', () {
    test('fetchSearchWordResults returns empty DTO if query is too short', () async {
      final dataSource = OFFDataSource();
      final result = await dataSource.fetchSearchWordResults('a');
      expect(result.count, equals(0));
      expect(result.products, isEmpty);
    });

    test('fetchSearchWordResults returns parsed OFFWordResponseDTO on success', () async {
      final mockResponse = {
        'count': 2,
        'page': 1,
        'page_count': 1,
        'page_size': 20,
        'products': [
          {
            'code': '12345',
            'product_name': 'Test Product 1',
            'nutriments': {
              'energy-kcal_100g': 150,
              'proteins_100g': 10,
              'carbohydrates_100g': 20,
              'fat_100g': 5
            }
          },
          {
            'code': '67890',
            'product_name': 'Test Product 2',
            // Missing nutriments to test putIfAbsent
          }
        ]
      };

      final client = MockHttpClient((request) async {
        return http.Response(jsonEncode(mockResponse), 200);
      });

      final dataSource = OFFDataSource(client: client);
      final result = await dataSource.fetchSearchWordResults('test');

      expect(result.count, equals(2));
      expect(result.products, hasLength(2));
      expect(result.products[0].code, equals('12345'));
      expect(result.products[0].product_name, equals('Test Product 1'));
      expect(result.products[1].code, equals('67890'));
      expect(result.products[1].product_name, equals('Test Product 2'));
    });

    test('fetchSearchWordResults skips malformed products', () async {
      final mockResponse = {
        'count': 1,
        'products': [
          {
            'code': 12345, // ID is int, should be String in DTO
            'product_name': 'Malformed',
          }
        ]
      };

      final client = MockHttpClient((request) async {
        return http.Response(jsonEncode(mockResponse), 200);
      });

      final dataSource = OFFDataSource(client: client);
      final result = await dataSource.fetchSearchWordResults('test');

      expect(result.products, isEmpty);
    });

    test('fetchSearchWordResults returns Future.error on non-200 response', () async {
      final client = MockHttpClient((request) async {
        return http.Response('Error', 500);
      });

      final dataSource = OFFDataSource(client: client);
      expect(dataSource.fetchSearchWordResults('test'), throwsA(equals(500)));
    });

    test('fetchSearchWordResults handles SocketException without Sentry', () async {
      final client = MockHttpClient((request) async {
        throw const SocketException('No Internet');
      });

      final dataSource = OFFDataSource(client: client);
      expect(dataSource.fetchSearchWordResults('test'), throwsA(isA<SocketException>()));
    });

    test('fetchSearchWordResults handles generic Exception with Sentry reporting', () async {
      final client = MockHttpClient((request) async {
        throw Exception('Generic Error');
      });

      final dataSource = OFFDataSource(client: client);
      expect(dataSource.fetchSearchWordResults('test'), throwsA(isA<Exception>()));
    });
  });

  group('OFFDataSource Barcode Search Tests', () {
    test('fetchBarcodeResults returns product details on success', () async {
      final mockResponse = {
        'status': 1,
        'status_verbose': 'product found',
        'product': {
          'code': '1234567890',
          'product_name': 'Barcode Product',
          'nutriments': {
            'energy-kcal_100g': 200,
          }
        }
      };

      final client = MockHttpClient((request) async {
        return http.Response(jsonEncode(mockResponse), 200);
      });

      final dataSource = OFFDataSource(client: client);
      final result = await dataSource.fetchBarcodeResults('1234567890');

      expect(result.status, equals(1));
      expect(result.product.code, equals('1234567890'));
      expect(result.product.product_name, equals('Barcode Product'));
    });

    test('fetchBarcodeResults returns Future.error ProductNotFoundException on 404', () async {
      final client = MockHttpClient((request) async {
        return http.Response('Not Found', 404);
      });

      final dataSource = OFFDataSource(client: client);
      expect(
        dataSource.fetchBarcodeResults('1111'),
        throwsA(equals(ProductNotFoundException)),
      );
    });

    test('fetchBarcodeResults returns Future.error on other status codes', () async {
      final client = MockHttpClient((request) async {
        return http.Response('Server Error', 502);
      });

      final dataSource = OFFDataSource(client: client);
      expect(
        dataSource.fetchBarcodeResults('1111'),
        throwsA(equals(502)),
      );
    });

    test('fetchBarcodeResults handles exceptions correctly and logs them', () async {
      final client = MockHttpClient((request) async {
        throw const SocketException('Host lookup failed');
      });

      final dataSource = OFFDataSource(client: client);
      expect(
        dataSource.fetchBarcodeResults('1111'),
        throwsA(isA<SocketException>()),
      );
    });
  });

  group('OFFDataSource _shouldReportToSentry Coverage', () {
    test('filters out network and connection issues', () async {
      final client1 = MockHttpClient((request) async => throw const SocketException('No Internet'));
      final client2 = MockHttpClient((request) async => throw TimeoutException('Timed out'));
      final client3 = MockHttpClient((request) async => throw Exception('failed host lookup'));
      final client4 = MockHttpClient((request) async => throw Exception('networkisunreachable'));
      final client5 = MockHttpClient((request) async => throw Exception('connection failed'));
      final client6 = MockHttpClient((request) async => throw Exception('timed out'));

      await expectLater(OFFDataSource(client: client1).fetchBarcodeResults('1'), throwsA(isA<SocketException>()));
      await expectLater(OFFDataSource(client: client2).fetchBarcodeResults('1'), throwsA(isA<TimeoutException>()));
      await expectLater(OFFDataSource(client: client3).fetchBarcodeResults('1'), throwsA(isA<Exception>()));
      await expectLater(OFFDataSource(client: client4).fetchBarcodeResults('1'), throwsA(isA<Exception>()));
      await expectLater(OFFDataSource(client: client5).fetchBarcodeResults('1'), throwsA(isA<Exception>()));
      await expectLater(OFFDataSource(client: client6).fetchBarcodeResults('1'), throwsA(isA<Exception>()));
    });
  });
}
