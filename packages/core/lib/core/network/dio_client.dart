import 'package:dio/dio.dart';
import 'package:happfest_core/core/config/env.dart';
import 'package:happfest_core/core/network/auth_interceptor.dart';
import 'package:happfest_core/core/network/error_mapper_interceptor.dart';
import 'package:happfest_core/core/network/pretty_log_interceptor.dart';
import 'package:happfest_core/core/network/retry_interceptor.dart';
import 'package:happfest_core/core/storage/token_storage.dart';

Dio buildDioClient(Env env, TokenStorage tokenStorage) {
  final dio = Dio(
    BaseOptions(
      baseUrl: env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Accept': 'application/json'},
    ),
  );

  dio.interceptors.addAll([
    AuthInterceptor(tokenStorage, dio),
    RetryInterceptor(dio),
    ErrorMapperInterceptor(),
    if (env.isDebug) PrettyLogInterceptor(),
  ]);

  return dio;
}
