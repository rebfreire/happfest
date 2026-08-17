import 'package:dio/dio.dart';
import 'package:happfest/core/error/failure.dart';

Failure mapDioExceptionToFailure(DioException exception) {
  switch (exception.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
      return const NetworkFailure();
    case DioExceptionType.cancel:
      return const UnknownFailure('Requisição cancelada.');
    case DioExceptionType.badCertificate:
      return const NetworkFailure('Certificado de segurança inválido.');
    case DioExceptionType.badResponse:
      return _mapStatusCode(exception.response?.statusCode, exception);
    case DioExceptionType.unknown:
    case DioExceptionType.transformTimeout:
      return const UnknownFailure();
  }
}

Failure _mapStatusCode(int? statusCode, DioException exception) {
  if (statusCode == 401) return const UnauthorizedFailure();
  if (statusCode == 403) return const ForbiddenFailure();
  if (statusCode == 404) return const NotFoundFailure();
  if (statusCode == 422) {
    return ValidationFailure(_extractFieldErrors(exception.response?.data));
  }
  if (statusCode != null && statusCode >= 500) return const ServerFailure();
  return const UnknownFailure();
}

Map<String, List<String>> _extractFieldErrors(dynamic data) {
  if (data is! Map) return const {};
  final errors = data['errors'];
  if (errors is! Map) return const {};
  return errors.map(
    (key, value) => MapEntry(
      key.toString(),
      value is List ? value.map((e) => e.toString()).toList() : <String>[],
    ),
  );
}
