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

/// A API responde erros no formato RFC 7807 (Problem Details), com uma
/// mensagem específica em `detail` (ou `title` como fallback) — ex.:
/// `{"title":"Não autenticado","detail":"Credenciais inválidas",...}`. Essa
/// mensagem é sempre mais precisa que o texto genérico padrão de cada
/// [Failure], então é usada quando presente.
Failure _mapStatusCode(int? statusCode, DioException exception) {
  final data = exception.response?.data;
  final apiMessage = _extractMessage(data);
  if (statusCode == 401) {
    return apiMessage != null
        ? UnauthorizedFailure(apiMessage)
        : const UnauthorizedFailure();
  }
  if (statusCode == 403) {
    return apiMessage != null
        ? ForbiddenFailure(apiMessage)
        : const ForbiddenFailure();
  }
  if (statusCode == 404) {
    return apiMessage != null
        ? NotFoundFailure(apiMessage)
        : const NotFoundFailure();
  }
  if (statusCode == 422) {
    final fields = _extractFieldErrors(data);
    return apiMessage != null
        ? ValidationFailure(fields, apiMessage)
        : ValidationFailure(fields);
  }
  if (statusCode != null && statusCode >= 500) {
    return apiMessage != null
        ? ServerFailure(apiMessage)
        : const ServerFailure();
  }
  return apiMessage != null
      ? UnknownFailure(apiMessage)
      : const UnknownFailure();
}

String? _extractMessage(dynamic data) {
  if (data is! Map) return null;
  final detail = data['detail'];
  if (detail is String && detail.trim().isNotEmpty) return detail;
  final title = data['title'];
  if (title is String && title.trim().isNotEmpty) return title;
  return null;
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
