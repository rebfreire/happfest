import 'package:dio/dio.dart';
import 'package:happfest/core/storage/token_storage.dart';

/// Injects the Bearer token on every request and refreshes it once on a 401,
/// queuing concurrent requests behind a single in-flight refresh so we never
/// fire multiple `/auth/refresh` calls at once.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokenStorage, this._dio);

  final TokenStorage _tokenStorage;
  final Dio _dio;

  Future<String?>? _refreshing;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.readToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final alreadyRetried =
        err.requestOptions.extra['retriedAfterRefresh'] == true;
    if (!isUnauthorized || alreadyRetried) {
      handler.next(err);
      return;
    }

    final newToken = await _refreshToken();
    if (newToken == null) {
      await _tokenStorage.clear();
      handler.next(err);
      return;
    }

    final retryOptions = err.requestOptions
      ..headers['Authorization'] = 'Bearer $newToken'
      ..extra['retriedAfterRefresh'] = true;
    try {
      final response = await _dio.fetch<dynamic>(retryOptions);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  Future<String?> _refreshToken() {
    return _refreshing ??= _doRefresh().whenComplete(() => _refreshing = null);
  }

  Future<String?> _doRefresh() async {
    final currentToken = await _tokenStorage.readToken();
    if (currentToken == null) return null;
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        queryParameters: {'token': currentToken},
      );
      final newToken = response.data?['token'] as String?;
      if (newToken == null) return null;
      await _tokenStorage.saveToken(newToken);
      return newToken;
    } on DioException {
      return null;
    }
  }
}
