import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/core/services/conversion_analytics_service.dart';
import 'package:macrotracker/core/services/monetization_service.dart';
import 'package:macrotracker/core/services/referral_service.dart';
import 'package:macrotracker/core/services/supabase_identity_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockPostgrestTransformBuilder<T> extends Fake
    implements PostgrestTransformBuilder<T> {
  final dynamic result;
  final bool isSingle;
  final bool isMaybeSingle;

  MockPostgrestTransformBuilder(this.result,
      {this.isSingle = false, this.isMaybeSingle = false});

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final memberName = invocation.memberName
        .toString()
        .replaceAll('Symbol("', '')
        .replaceAll('")', '');
    if (memberName == 'then') {
      final Function onValue = invocation.positionalArguments[0];
      final Function? onError = invocation.namedArguments[Symbol('onError')];
      return Future.value(result).then(
        (resolvedVal) {
          dynamic val = resolvedVal;
          if (isSingle || isMaybeSingle) {
            val = (resolvedVal is List)
                ? (resolvedVal.isNotEmpty ? resolvedVal.first : null)
                : resolvedVal;
          }
          return onValue(val);
        },
        onError: onError,
      );
    }
    if (memberName == 'maybeSingle') {
      return MockPostgrestTransformBuilder<Map<String, dynamic>?>(result,
          isMaybeSingle: true);
    }
    if (memberName == 'single') {
      return MockPostgrestTransformBuilder<Map<String, dynamic>>(result,
          isSingle: true);
    }
    return this;
  }
}

class MockPostgrestFilterBuilder<T> extends Fake
    implements PostgrestFilterBuilder<T> {
  final MockPostgrestTransformBuilder<T> transformBuilder;
  final List<String> calls = [];

  MockPostgrestFilterBuilder(this.transformBuilder);

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final memberName = invocation.memberName
        .toString()
        .replaceAll('Symbol("', '')
        .replaceAll('")', '');
    final args = invocation.positionalArguments.join(', ');
    calls.add('$memberName($args)');

    if (memberName == 'select') {
      return transformBuilder;
    }
    if (memberName == 'maybeSingle') {
      return MockPostgrestTransformBuilder<Map<String, dynamic>?>(
          transformBuilder.result,
          isMaybeSingle: true);
    }
    if (memberName == 'single') {
      return MockPostgrestTransformBuilder<Map<String, dynamic>>(
          transformBuilder.result,
          isSingle: true);
    }
    if (memberName == 'then') {
      final Function onValue = invocation.positionalArguments[0];
      final Function? onError = invocation.namedArguments[Symbol('onError')];
      return Future.value(transformBuilder.result).then(
        (resolvedVal) {
          dynamic typedVal = resolvedVal;
          final typeStr = T.toString();
          if (typeStr.contains('List<Map')) {
            final listVal = (resolvedVal is List) ? resolvedVal : [resolvedVal];
            typedVal = listVal.cast<Map<String, dynamic>>();
          } else if (typeStr.contains('Map')) {
            final listVal = (resolvedVal is List) ? resolvedVal : [resolvedVal];
            typedVal = (listVal.isNotEmpty) ? listVal.first : null;
          }
          return onValue(typedVal);
        },
        onError: onError,
      );
    }
    return this;
  }
}

class MockSupabaseQueryBuilder extends Fake implements SupabaseQueryBuilder {
  final MockPostgrestFilterBuilder<List<Map<String, dynamic>>> filterBuilder;
  MockSupabaseQueryBuilder(this.filterBuilder);

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final memberName = invocation.memberName
        .toString()
        .replaceAll('Symbol("', '')
        .replaceAll('")', '');
    final args = invocation.positionalArguments.join(', ');
    filterBuilder.calls.add('$memberName($args)');
    return filterBuilder;
  }
}

class _FakeSupabaseClient extends Fake implements SupabaseClient {
  final Map<String, dynamic> queries = {};
  Future<dynamic> Function(String, Map<String, dynamic>?)? onRpc;

  @override
  SupabaseQueryBuilder from(String table) {
    final result = queries[table];
    final transform =
        MockPostgrestTransformBuilder<List<Map<String, dynamic>>>(result);
    final filter =
        MockPostgrestFilterBuilder<List<Map<String, dynamic>>>(transform);
    return MockSupabaseQueryBuilder(filter);
  }

  @override
  PostgrestFilterBuilder<T> rpc<T>(
    String fn, {
    Map<String, dynamic>? params,
    Object? get,
    dynamic headers,
    dynamic httpMethod,
  }) {
    if (onRpc != null) {
      final fut = onRpc!(fn, params);
      final transform = MockPostgrestTransformBuilder<T>(fut);
      return MockPostgrestFilterBuilder<T>(transform) as dynamic;
    }
    final transform = MockPostgrestTransformBuilder<T>(null);
    return MockPostgrestFilterBuilder<T>(transform) as dynamic;
  }
}

class _FakeSupabaseIdentityService extends Fake
    implements SupabaseIdentityService {
  String userId = 'user-123';
  bool shouldThrow = false;
  bool shouldThrowAnonymousDisabled = false;

  @override
  Future<String> ensureUserSession() async {
    if (shouldThrow) {
      throw Exception('Session failed');
    }
    if (shouldThrowAnonymousDisabled) {
      throw AuthApiException('anonymous sign in disabled',
          code: 'anonymous_provider_disabled');
    }
    return userId;
  }
}

class _FakeMonetizationService extends Fake implements MonetizationService {
  @override
  String? savedReferralCode;
  int saveCalls = 0;
  int grantBonusCalls = 0;
  AiTrialState trialState = const AiTrialState(
    isPremium: false,
    isProtectedAccount: true,
    limit: 10,
    used: 0,
    aiMealsSaved: 0,
    hasOnboardingBonus: false,
    hasShareBonus: false,
    isFoundingMember: false,
    fullLimit: 10,
  );

  @override
  Future<void> saveReferralCode(String code) async {
    savedReferralCode = code;
    saveCalls++;
  }

  @override
  Future<void> grantShareBonus() async {
    grantBonusCalls++;
    trialState = AiTrialState(
      isPremium: trialState.isPremium,
      isProtectedAccount: trialState.isProtectedAccount,
      limit: trialState.limit + 5,
      used: trialState.used,
      aiMealsSaved: trialState.aiMealsSaved,
      hasOnboardingBonus: trialState.hasOnboardingBonus,
      hasShareBonus: true,
      isFoundingMember: trialState.isFoundingMember,
      fullLimit: trialState.fullLimit + 5,
    );
  }

  @override
  Future<AiTrialState> getAiTrialState() async => trialState;
}

class _FakeConversionAnalyticsService extends Fake
    implements ConversionAnalyticsService {
  int createdCalls = 0;
  int redeemedCalls = 0;
  int shareBonusCalls = 0;

  @override
  Future<void> logReferralCodeCreated() async {
    createdCalls++;
  }

  @override
  Future<void> logReferralRedeemed() async {
    redeemedCalls++;
  }

  @override
  Future<void> logShareBonusGranted() async {
    shareBonusCalls++;
  }
}

void main() {
  group('ReferralService Tests', () {
    late _FakeSupabaseClient supabase;
    late _FakeSupabaseIdentityService identityService;
    late _FakeMonetizationService monetizationService;
    late _FakeConversionAnalyticsService analyticsService;
    late ReferralService service;

    setUp(() {
      supabase = _FakeSupabaseClient();
      identityService = _FakeSupabaseIdentityService();
      monetizationService = _FakeMonetizationService();
      analyticsService = _FakeConversionAnalyticsService();
      service = ReferralService(
        supabase,
        identityService,
        monetizationService,
        analyticsService,
      );
    });

    group('getOrCreateReferralCode', () {
      test('returns cached local code if available', () async {
        monetizationService.savedReferralCode = 'LOCAL6';
        final code = await service.getOrCreateReferralCode();
        expect(code, 'LOCAL6');
        expect(monetizationService.saveCalls, 0);
      });

      test('fetches existing remote code from database if not cached',
          () async {
        supabase.queries['referral_codes'] = {'code': 'DBCODE'};
        final code = await service.getOrCreateReferralCode();
        expect(code, 'DBCODE');
        expect(monetizationService.savedReferralCode, 'DBCODE');
        expect(monetizationService.saveCalls, 1);
      });

      test('generates and inserts new code if none exists in database',
          () async {
        supabase.queries['referral_codes'] =
            null; // simulate maybeSingle returns null
        final code = await service.getOrCreateReferralCode();
        expect(code, isNotNull);
        expect(code!.length, 6);
        expect(monetizationService.savedReferralCode, code);
        expect(analyticsService.createdCalls, 1);
      });

      test(
          'returns null and catches AuthApiException when anonymous providers disabled',
          () async {
        identityService.shouldThrowAnonymousDisabled = true;
        final code = await service.getOrCreateReferralCode();
        expect(code, isNull);
      });

      test('returns null and catches other exceptions', () async {
        identityService.shouldThrow = true;
        final code = await service.getOrCreateReferralCode();
        expect(code, isNull);
      });
    });

    group('redeemCode', () {
      test('successfully redeems and grants share bonus', () async {
        supabase.onRpc = (fn, params) async {
          expect(fn, 'redeem_referral_code');
          expect(params?['p_code'], 'CODE12');
          return [
            {'status': 'success'}
          ];
        };

        final result = await service.redeemCode('CODE12');
        expect(result, ReferralRedemptionResult.success);
        expect(monetizationService.grantBonusCalls, 1);
        expect(analyticsService.redeemedCalls, 1);
      });

      test('returns unknownError when RPC response is empty', () async {
        supabase.onRpc = (fn, params) async => [];
        final result = await service.redeemCode('CODE12');
        expect(result, ReferralRedemptionResult.unknownError);
      });

      test('handles codeNotFound PostgrestException', () async {
        supabase.onRpc = (fn, params) async {
          throw const PostgrestException(message: 'code not found');
        };
        final result = await service.redeemCode('CODE12');
        expect(result, ReferralRedemptionResult.codeNotFound);
      });

      test('handles selfReferral PostgrestException', () async {
        supabase.onRpc = (fn, params) async {
          throw const PostgrestException(
              message: 'cannot redeem own referral code');
        };
        final result = await service.redeemCode('CODE12');
        expect(result, ReferralRedemptionResult.selfReferral);
      });

      test('handles alreadyRedeemed PostgrestException via message', () async {
        supabase.onRpc = (fn, params) async {
          throw const PostgrestException(
              message: 'duplicate key value violates unique constraint');
        };
        final result = await service.redeemCode('CODE12');
        expect(result, ReferralRedemptionResult.alreadyRedeemed);
      });

      test('handles alreadyRedeemed PostgrestException via code', () async {
        supabase.onRpc = (fn, params) async {
          throw const PostgrestException(message: 'some error', code: '23505');
        };
        final result = await service.redeemCode('CODE12');
        expect(result, ReferralRedemptionResult.alreadyRedeemed);
      });

      test('handles general PostgrestExceptions', () async {
        supabase.onRpc = (fn, params) async {
          throw const PostgrestException(message: 'fatal crash');
        };
        final result = await service.redeemCode('CODE12');
        expect(result, ReferralRedemptionResult.unknownError);
      });

      test('handles other general exceptions', () async {
        identityService.shouldThrow = true;
        final result = await service.redeemCode('CODE12');
        expect(result, ReferralRedemptionResult.unknownError);
      });
    });

    group('hasRedeemedAnyCode', () {
      test('returns true when query returns a record', () async {
        supabase.queries['referral_redemptions'] = {'id': 'r-1'};
        final res = await service.hasRedeemedAnyCode();
        expect(res, isTrue);
      });

      test('returns false when query returns null', () async {
        supabase.queries['referral_redemptions'] = null;
        final res = await service.hasRedeemedAnyCode();
        expect(res, isFalse);
      });

      test('returns false on anonymous sign in disabled exception', () async {
        identityService.shouldThrowAnonymousDisabled = true;
        final res = await service.hasRedeemedAnyCode();
        expect(res, isFalse);
      });

      test('returns false on general exceptions', () async {
        identityService.shouldThrow = true;
        final res = await service.hasRedeemedAnyCode();
        expect(res, isFalse);
      });
    });

    group('getReferralCount', () {
      test('returns RPC count', () async {
        supabase.onRpc = (fn, params) async => 5;
        final count = await service.getReferralCount();
        expect(count, 5);
      });

      test('returns 0 on anonymous sign in disabled', () async {
        identityService.shouldThrowAnonymousDisabled = true;
        final count = await service.getReferralCount();
        expect(count, 0);
      });

      test('returns 0 on other exceptions', () async {
        identityService.shouldThrow = true;
        final count = await service.getReferralCount();
        expect(count, 0);
      });
    });

    group('checkAndGrantShareBonus', () {
      test('returns early if local referral code is not set', () async {
        monetizationService.savedReferralCode = null;
        await service.checkAndGrantShareBonus();
        expect(monetizationService.grantBonusCalls, 0);
      });

      test('returns early if share bonus is already granted', () async {
        monetizationService.savedReferralCode = 'MYCODE';
        monetizationService.trialState = const AiTrialState(
          isPremium: false,
          isProtectedAccount: true,
          limit: 10,
          used: 0,
          aiMealsSaved: 0,
          hasOnboardingBonus: false,
          hasShareBonus: true,
          isFoundingMember: false,
          fullLimit: 10,
        );
        await service.checkAndGrantShareBonus();
        expect(monetizationService.grantBonusCalls, 0);
      });

      test('grants bonus when referral count > 0', () async {
        monetizationService.savedReferralCode = 'MYCODE';
        supabase.onRpc = (fn, params) async => 2;
        await service.checkAndGrantShareBonus();
        expect(monetizationService.grantBonusCalls, 1);
        expect(analyticsService.shareBonusCalls, 1);
      });

      test('does not grant bonus when referral count is 0', () async {
        monetizationService.savedReferralCode = 'MYCODE';
        supabase.onRpc = (fn, params) async => 0;
        await service.checkAndGrantShareBonus();
        expect(monetizationService.grantBonusCalls, 0);
      });
    });
  });
}
