import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:three_zero_two_property/constant/constant.dart';

class AppVersionService {
  static const String _endpoint = '/api/app-version';

  static Future<VersionCheckResult> checkVersion() async {
    try {
      // Step 1: Get current installed app version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      print('📱 APP VERSION CHECK STARTED');
      print('📱 Current App Version: $currentVersion');

      // Step 2: Detect platform
      final platform = Platform.isAndroid ? 'android' : 'ios';
      print('📱 Platform: $platform');

      // Step 3: Call GET /api/app-version?platform=android
      final uri = Uri.parse('$Api_url$_endpoint?platform=$platform');
      print('📱 Calling: $uri');

      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      print('📱 Response Code: ${response.statusCode}');
      print('📱 Response Body: ${response.body}');

      // 404 = not configured yet → proceed normally
      if (response.statusCode == 404) {
        print('📱 No version config → Proceeding');
        return VersionCheckResult(status: VersionStatus.upToDate);
      }

      if (response.statusCode != 200) {
        print('📱 API Error → Proceeding');
        return VersionCheckResult(status: VersionStatus.upToDate);
      }

      final data = jsonDecode(response.body);
      final latestVersion = data['latest_version'] as String;
      final minimumVersion = data['minimum_supported_version'] as String;
      final isForceUpdate = data['is_force_update'] as bool;

      print('📱 Latest: $latestVersion | Minimum: $minimumVersion | Force: $isForceUpdate');

      final current = _parseVersion(currentVersion);
      final minimum = _parseVersion(minimumVersion);
      final latest = _parseVersion(latestVersion);

      if (_isLower(current, minimum)) {
        print('📱 Result: FORCE UPDATE (below minimum)');
        return VersionCheckResult(status: VersionStatus.forceUpdate, latestVersion: latestVersion);
      }

      if (_isLower(current, latest) && isForceUpdate) {
        print('📱 Result: FORCE UPDATE (force flag)');
        return VersionCheckResult(status: VersionStatus.forceUpdate, latestVersion: latestVersion);
      }

      if (_isLower(current, latest)) {
        print('📱 Result: SOFT UPDATE');
        return VersionCheckResult(status: VersionStatus.softUpdate, latestVersion: latestVersion);
      }

      print('📱 Result: UP TO DATE');
      return VersionCheckResult(status: VersionStatus.upToDate);
    } catch (e) {
      print('📱 Version check error: $e');
      return VersionCheckResult(status: VersionStatus.upToDate);
    }
  }

  static List<int> _parseVersion(String version) =>
      version.split('.').map((e) => int.tryParse(e) ?? 0).toList();

  static bool _isLower(List<int> a, List<int> b) {
    for (int i = 0; i < 3; i++) {
      final aVal = i < a.length ? a[i] : 0;
      final bVal = i < b.length ? b[i] : 0;
      if (aVal < bVal) return true;
      if (aVal > bVal) return false;
    }
    return false;
  }
}

enum VersionStatus { upToDate, softUpdate, forceUpdate }

class VersionCheckResult {
  final VersionStatus status;
  final String? latestVersion;
  VersionCheckResult({required this.status, this.latestVersion});
}
