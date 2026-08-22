import 'package:dio/dio.dart';
import 'package:happfest/core/storage/token_storage.dart';
import 'package:happfest/features/auth/data/dto/login_response_dto.dart';

/// Injects the Bearer access token on every request and refreshes the
/// access+refresh pair once on a 401, queuing concurrent requests behind a
/// single in-flight refresh so we never fire multiple
/// `/auth/mobile/refresh` calls at once.
///
/// Usa `_dio.post` direto em vez de `AuthRemoteDataSource` para evitar uma
/// dependência circular no grafo de providers (`AuthRemoteDataSource`
/// depende do mesmo `Dio` que carrega este interceptor).
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
    final accessToken = await _tokenStorage.readAccessToken();
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
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

    final newAccessToken = await _refreshTokens();
    if (newAccessToken == null) {
      await _tokenStorage.clear();
      handler.next(err);
      return;
    }

    final retryOptions = err.requestOptions
      ..headers['Authorization'] = 'Bearer $newAccessToken'
      ..extra['retriedAfterRefresh'] = true;
    try {
      final response = await _dio.fetch<dynamic>(retryOptions);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  Future<String?> _refreshTokens() {
    return _refreshing ??= _doRefresh().whenComplete(() {
      _refreshing = null;
    });
  }

  Future<String?> _doRefresh() async {
    final currentRefreshToken = await _tokenStorage.readRefreshToken();
    if (currentRefreshToken == null) return null;
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/mobile/refresh',
        data: {'refreshToken': currentRefreshToken},
      );
      final dto = LoginResponseDto.fromJson(response.data!);
      final newAccessToken = dto.accessToken;
      final newRefreshToken = dto.refreshToken;
      if (newAccessToken == null || newRefreshToken == null) return null;
      await _tokenStorage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );
      return newAccessToken;
    } on DioException {
      return null;
    }
  }
}
