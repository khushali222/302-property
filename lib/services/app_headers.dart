import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';

import '../constant/constant.dart';

/// Cached metadata about the running build, exposed as HTTP headers attached
/// to every outgoing API request. Initialised once in `main()` before runApp.
class AppHeaders {
  static String version = '';
  static String buildNumber = '';
  static String platform = '';
  static String channel = 'production';
  static String bundleId = '';
  static String userAgent = '';

  static bool _initialised = false;

  static Future<void> init() async {
    if (_initialised) return;

    final info = await PackageInfo.fromPlatform();
    version = info.version;
    buildNumber = info.buildNumber;
    bundleId = info.packageName;
    platform = Platform.isIOS ? 'ios' : 'android';

    // Channel resolution, in priority order:
    //   1. Compile-time --dart-define=CHANNEL=...  (most explicit)
    //   2. Bundle-ID suffix (.beta / .staging / .dev) — spoof-proof when set
    //   3. Api_url host (staging./development. URLs imply non-production builds)
    //   4. Fallback: production
    const compileTimeChannel = String.fromEnvironment(
      'CHANNEL',
      defaultValue: '',
    );
    if (compileTimeChannel.isNotEmpty) {
      channel = compileTimeChannel;
    } else {
      final fromBundle = _channelFromBundleId(bundleId);
      if (fromBundle != 'production') {
        channel = fromBundle;
      } else {
        channel = _channelFromApiUrl(Api_url);
      }
    }

    userAgent = 'CRM-Mobile/$version ($platform; build=$buildNumber)';
    _initialised = true;

    // One-time startup banner so you can confirm what the app reports.
    // Auto-suppressed in release/profile by the zone-level print filter.
  }

  static String _channelFromBundleId(String id) {
    if (id.endsWith('.beta')) return 'testflight';
    if (id.endsWith('.staging')) return 'staging';
    if (id.endsWith('.dev')) return 'internal';
    return 'production';
  }

  static String _channelFromApiUrl(String url) {
    final lower = url.toLowerCase();
    // Map staging-server traffic to the `testflight` channel so the server's
    // existing TestFlight enforcement row (loose/off) governs QA testers and
    // local dev builds that point at staging. The server admin panel only
    // recognises `production` / `testflight` / `internal` — there is no
    // `staging` channel row, so reporting `staging` literally would fall
    // through to production rules and brick QA.
    if (lower.contains('staging.')) return 'testflight';
    if (lower.contains('development.')) return 'internal';
    if (lower.contains('localhost') || RegExp(r'192\.168\.|10\.|172\.\d+\.').hasMatch(lower)) {
      return 'internal';
    }
    return 'production';
  }

  static Map<String, String> get headers => {
        'x-app-version': version,
        'x-app-platform': platform,
        'x-app-channel': channel,
        'x-app-bundle': bundleId,
        'User-Agent': userAgent,
      };
}
