import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'api_client.dart';
import 'app_headers.dart';
import 'force_update_helper.dart';

/// Drop-in replacements for `http.get / post / put / delete / patch` that
/// automatically attach the version-reporting headers from [AppHeaders] and
/// route `426 Upgrade Required` responses to the force-update dialog.
///
/// Existing call sites only need to change the function name:
///   `http.post(...)` -> `apiPost(...)`
/// The signatures match `package:http` exactly and the returned
/// `http.Response` is identical, so the surrounding parsing code keeps
/// working unchanged.

Map<String, String> _mergeHeaders(Map<String, String>? userHeaders) {
  final merged = <String, String>{};
  if (userHeaders != null) merged.addAll(userHeaders);
  // App headers go last so the version/platform/channel signals can't
  // accidentally be overridden by per-call header maps.
  merged.addAll(AppHeaders.headers);
  return merged;
}

void _logOutgoing(String method, Uri url) {
  // Auto-suppressed in release/profile by the zone-level print filter in main().
}

void _check426(http.Response response) {
  if (response.statusCode != 426) return;

  String? message;
  String? installed;
  String? latest;
  try {
    final decoded = json.decode(response.body);
    if (decoded is Map) {
      message = decoded['message']?.toString();
      installed = decoded['installed_version']?.toString();
      latest = decoded['latest_version']?.toString();
    }
  } catch (_) {
    // Non-JSON 426 body — fall back to defaults inside ForceUpdateHelper.
  }

  final ctx = ApiClient.navigatorKey.currentContext;
  if (ctx != null) {
    ForceUpdateHelper.show(
      ctx,
      latestVersion: latest,
      installedVersion: installed,
      message: message,
    );
  }
}

/// Soft-update path. When the server returns a successful response but
/// adds `x-app-update-recommended: true`, the client shows a dismissible
/// banner suggesting an upgrade. Helper [ForceUpdateHelper.showSoftUpdate]
/// guarantees the banner is shown at most once per app session.
void _checkSoftUpdate(http.Response response) {
  final flag = response.headers['x-app-update-recommended'];
  if (flag == null || flag.toLowerCase() != 'true') return;

  final recommended = response.headers['x-app-recommended-version'];


  final ctx = ApiClient.navigatorKey.currentContext;
  if (ctx != null) {
    ForceUpdateHelper.showSoftUpdate(ctx, latestVersion: recommended);
  }
}

Future<http.Response> apiGet(Uri url, {Map<String, String>? headers}) async {
  _logOutgoing('GET', url);
  final response = await http.get(url, headers: _mergeHeaders(headers)).timeout(Duration(seconds: 30));
  _check426(response);
  _checkSoftUpdate(response);
  return response;
}

Future<http.Response> apiPost(
  Uri url, {
  Map<String, String>? headers,
  Object? body,
  Encoding? encoding,
}) async {
  _logOutgoing('POST', url);
  final response = await http.post(
    url,
    headers: _mergeHeaders(headers),
    body: body,
    encoding: encoding,
  ).timeout(Duration(seconds: 30));
  _check426(response);
  _checkSoftUpdate(response);
  return response;
}

Future<http.Response> apiPut(
  Uri url, {
  Map<String, String>? headers,
  Object? body,
  Encoding? encoding,
}) async {
  _logOutgoing('PUT', url);
  final response = await http.put(
    url,
    headers: _mergeHeaders(headers),
    body: body,
    encoding: encoding,
  ).timeout(Duration(seconds: 30));
  _check426(response);
  _checkSoftUpdate(response);
  return response;
}

Future<http.Response> apiDelete(
  Uri url, {
  Map<String, String>? headers,
  Object? body,
  Encoding? encoding,
}) async {
  _logOutgoing('DELETE', url);
  final response = await http.delete(
    url,
    headers: _mergeHeaders(headers),
    body: body,
    encoding: encoding,
  ).timeout(Duration(seconds: 30));
  _check426(response);
  _checkSoftUpdate(response);
  return response;
}

Future<http.Response> apiPatch(
  Uri url, {
  Map<String, String>? headers,
  Object? body,
  Encoding? encoding,
}) async {
  _logOutgoing('PATCH', url);
  final response = await http.patch(
    url,
    headers: _mergeHeaders(headers),
    body: body,
    encoding: encoding,
  ).timeout(Duration(seconds: 30));
  _check426(response);
  _checkSoftUpdate(response);
  return response;
}

/// The `id` header the upload endpoint expects is the caller's OWN id, which
/// differs per role — an admin id resolves the wrong user branch for the other
/// roles. Mirrors the mapping in splash_screen's session check and the login
/// screen, keyed off the same stored `role`.
Future<Map<String, String>> _authHeaders() async {
  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');
  final String role = prefs.getString('role') ?? '';

  final String? ownId = role == 'Admin'
      ? prefs.getString('adminId')
      : role == 'Staffmember'
          ? prefs.getString('staff_id')
          : role == 'Tenant'
              ? prefs.getString('tenant_id')
              : role == 'Vendor'
                  ? prefs.getString('vendor_id')
                  : null;

  if (token == null || token.isEmpty || ownId == null || ownId.isEmpty) {
    return const {};
  }
  return {
    'authorization': 'CRM $token',
    'id': 'CRM $ownId',
  };
}

/// For `http.MultipartRequest` / file-upload flows. Attach app headers to
/// the request before sending. Status 426 is detected from the streamed
/// response by peeking the status code; the body stream is left intact for
/// the caller (we can't easily re-read it without buffering).
///
/// Auth headers are filled in here because every multipart upload in the app
/// targets the same authenticated endpoint, and none of the ~50 call sites
/// were sending them — the server rejected each one with a 401 and stored
/// nothing, which screens that preview the local file made look successful.
/// Doing it centrally means new upload screens inherit it. A call site that
/// sets `authorization` itself still wins, so explicit per-screen headers are
/// left untouched.
Future<http.StreamedResponse> apiSend(http.BaseRequest request) async {
  if (!request.headers.keys
      .any((k) => k.toLowerCase() == 'authorization')) {
    request.headers.addAll(await _authHeaders());
  }
  request.headers.addAll(AppHeaders.headers);
  _logOutgoing(request.method, request.url);
  final response = await request.send();
  if (response.statusCode == 426) {
    // Body is a single-read stream; trigger dialog with empty metadata.
    final ctx = ApiClient.navigatorKey.currentContext;
    if (ctx != null) {
      ForceUpdateHelper.show(ctx);
    }
  }
  return response;
}
