import 'package:dio/dio.dart';
import 'package:happfest/core/config/env.dart';
import 'package:happfest/core/network/auth_interceptor.dart';
import 'package:happfest/core/network/cart_session_interceptor.dart';
import 'package:happfest/core/network/error_mapper_interceptor.dart';
import 'package:happfest/core/network/pretty_log_interceptor.dart';
import 'package:happfest/core/network/retry_interceptor.dart';
import 'package:happfest/core/storage/cart_session_storage.dart';
import 'package:happfest/core/storage/token_storage.dart';

Dio buildDioClient(
  Env env,
  TokenStorage tokenStorage,
  CartSessionStorage cartSessionStorage,
) {
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
    CartSessionInterceptor(cartSessionStorage),
    RetryInterceptor(dio),
    ErrorMapperInterceptor(),
    if (env.isDebug) PrettyLogInterceptor(),
  ]);

  return dio;
}
