import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:happfest/core/error/failure.dart';
import 'package:happfest/core/network/error_mapper.dart';

void main() {
  final requestOptions = RequestOptions(path: '/products');

  DioException withStatus(int statusCode) {
    return DioException(
      requestOptions: requestOptions,
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: requestOptions,
        statusCode: statusCode,
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
  });
}
