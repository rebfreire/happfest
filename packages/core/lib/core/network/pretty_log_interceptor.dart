import 'dart:developer' as developer;

import 'package:dio/dio.dart';

/// Debug-only request/response logger. Never logs headers or body — those
/// can carry the auth token or user PII (see AGENTS.md seção 9).
class PrettyLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    developer.log('→ ${options.method} ${options.uri}', name: 'happfest.http');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    developer.log(
      '← ${response.statusCode} ${response.requestOptions.uri}',
      name: 'happfest.http',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    developer.log(
      '✗ ${err.response?.statusCode} ${err.requestOptions.uri}',
      name: 'happfest.http',
      error: err.type,
    );
    handler.next(err);
  }
}
