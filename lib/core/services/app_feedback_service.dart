import 'dart:io' show Platform;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppFeedbackService {
  final SupabaseClient _supabaseClient;

  AppFeedbackService(this._supabaseClient);

  Future<void> submitFeedback({
    required String type, // 'bug' or 'feature'
    required String title,
    required String description,
  }) async {
    final userId = _supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User is not authenticated');
    }

    final packageInfo = await PackageInfo.fromPlatform();
    final deviceOS = Platform.isAndroid ? 'Android' : (Platform.isIOS ? 'iOS' : 'Other');
    final version = packageInfo.version;
    final buildNumber = packageInfo.buildNumber;

    final deviceInfo = {
      'os': deviceOS,
      'app_version': version,
      'build_number': buildNumber,
      'os_version': Platform.operatingSystemVersion,
    };

    await _supabaseClient.from('app_feedback').insert({
      'user_id': userId,
      'type': type,
      'title': title,
      'description': description,
      'device_info': deviceInfo,
    });
  }
}
