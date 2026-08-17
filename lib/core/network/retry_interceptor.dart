import 'package:dio/dio.dart';

const _idempotentMethods = {'GET', 'HEAD', 'PUT', 'DELETE', 'OPTIONS'};

/// Retries with backoff on network errors or 5xx responses, only for
/// idempotent methods — never retries POST/PATCH blindly.
class RetryInterceptor extends Interceptor {
  RetryInterceptor(this._dio, {this.maxRetries = 2});

  final Dio _dio;
  final int maxRetries;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final method = err.requestOptions.method.toUpperCase();
    final isRetryable =
        _idempotentMethods.contains(method) && _isRetryableError(err);
    final attempt = (err.requestOptions.extra['retryAttempt'] as int?) ?? 0;

    if (!isRetryable || attempt >= maxRetries) {
      handler.next(err);
      return;
    }

    final delay = Duration(milliseconds: 300 * (attempt + 1));
    await Future<void>.delayed(delay);

    final options = err.requestOptions..extra['retryAttempt'] = attempt + 1;
    try {
      final response = await _dio.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  bool _isRetryableError(DioException err) {
    final statusCode = err.response?.statusCode;
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.connectionError ||
        (statusCode != null && statusCode >= 500);
  }
}
