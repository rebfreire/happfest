import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:happfest/core/error/failure.dart';
import 'package:happfest/core/network/error_mapper.dart';

void main() {
  final requestOptions = RequestOptions(path: '/products');

  DioException withStatus(int statusCode, {Map<String, dynamic>? data}) {
    return DioException(
      requestOptions: requestOptions,
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: requestOptions,
        statusCode: statusCode,
        data: data,
      ),
    );
  }

  group('mapDioExceptionToFailure', () {
    test('maps connection errors to NetworkFailure', () {
      final exception = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.connectionError,
      );

      expect(mapDioExceptionToFailure(exception), isA<NetworkFailure>());
    });

    test('maps 401 to UnauthorizedFailure', () {
      expect(
        mapDioExceptionToFailure(withStatus(401)),
        isA<UnauthorizedFailure>(),
      );
    });

    test('maps 403 to ForbiddenFailure', () {
      expect(
        mapDioExceptionToFailure(withStatus(403)),
        isA<ForbiddenFailure>(),
      );
    });

    test('maps 404 to NotFoundFailure', () {
      expect(mapDioExceptionToFailure(withStatus(404)), isA<NotFoundFailure>());
    });

    test('maps 500 to ServerFailure', () {
      expect(mapDioExceptionToFailure(withStatus(500)), isA<ServerFailure>());
    });

    test('maps unknown type to UnknownFailure', () {
      final exception = DioException(requestOptions: requestOptions);

      expect(mapDioExceptionToFailure(exception), isA<UnknownFailure>());
    });

    test('uses the API "detail" message when present (RFC 7807)', () {
      final failure = mapDioExceptionToFailure(
        withStatus(
          401,
          data: {'title': 'Não autenticado', 'detail': 'Credenciais inválidas'},
        ),
      );

      expect(failure, isA<UnauthorizedFailure>());
      expect(failure.message, 'Credenciais inválidas');
    });

    test('falls back to "title" when "detail" is absent', () {
      final failure = mapDioExceptionToFailure(
        withStatus(403, data: {'title': 'Acesso negado'}),
      );

      expect(failure.message, 'Acesso negado');
    });

    test('falls back to the generic default when the API sends no body', () {
      final failure = mapDioExceptionToFailure(withStatus(401));

      expect(failure.message, const UnauthorizedFailure().message);
    });
  });
}
