import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';

import 'app_headers.dart';
import 'force_update_helper.dart';

/// Shared Dio instance used for outgoing API calls.
///
/// The attached [AppVersionInterceptor] does two things:
/// 1. Injects `x-app-version`, `x-app-platform`, `x-app-channel`,
///    `x-app-bundle` and a branded `User-Agent` onto every request.
/// 2. Catches `426 Upgrade Required` responses and shows a non-dismissible
///    force-update dialog via the global navigator.
class ApiClient {
  ApiClient._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    // Don't throw on non-2xx — repository code inspects statusCode directly,
    // matching the previous `package:http` behaviour. 426 is still handled
    // specially in the interceptor so the force-update dialog still appears.
    validateStatus: (_) => true,
  ))
    ..interceptors.add(AppVersionInterceptor());

  static Dio get instance => _dio;
}

class AppVersionInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    options.headers.addAll(AppHeaders.headers);
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.statusCode == 426) {
      _handle426(response.data);
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 426) {
      _handle426(err.response?.data);
    }
    handler.next(err);
  }

  void _handle426(dynamic body) {
    String? message;
    String? installed;
    String? latest;

    if (body is Map) {
      message = body['message']?.toString();
      installed = body['installed_version']?.toString();
      latest = body['latest_version']?.toString();
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
}
