import 'package:dio/dio.dart';
import 'package:happfest/core/network/api_exception.dart';
import 'package:happfest/core/network/error_mapper.dart';

/// Converts every Dio exception into an [ApiException] carrying a typed
/// Failure, so the UI never has to pattern-match on Dio internals.
class ErrorMapperInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final failure = mapDioExceptionToFailure(err);
    handler.next(err.copyWith(error: ApiException(failure)));
  }
}
