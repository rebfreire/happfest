import 'package:flutter_test/flutter_test.dart';
import 'package:happfest/core/error/failure.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/core/storage/cart_session_storage.dart';
import 'package:happfest/core/storage/token_storage.dart';
import 'package:happfest/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:happfest/features/auth/data/dto/login_request_dto.dart';
import 'package:happfest/features/auth/data/dto/login_response_dto.dart';
import 'package:happfest/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class _MockTokenStorage extends Mock implements TokenStorage {}

class _MockCartSessionStorage extends Mock implements CartSessionStorage {}

void main() {
  late _MockAuthRemoteDataSource remoteDataSource;
  late _MockTokenStorage tokenStorage;
  late _MockCartSessionStorage cartSessionStorage;
  late AuthRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(
      const LoginRequestDto(email: 'a@b.com', senha: '123456'),
    );
  });

  setUp(() {
    remoteDataSource = _MockAuthRemoteDataSource();
    tokenStorage = _MockTokenStorage();
    cartSessionStorage = _MockCartSessionStorage();
    repository = AuthRepositoryImpl(
      remoteDataSource,
      tokenStorage,
      cartSessionStorage,
    );
  });

  test(
    'returns Ok and saves both tokens when the API returns a complete response',
    () async {
      when(
        () => remoteDataSource.login(any()),
      ).thenAnswer(
        (_) async => const LoginResponseDto(
          accessToken: 'access-123',
          refreshToken: 'refresh-123',
          userId: 'user-1',
          profileType: ProfileTypeDto.customer,
        ),
      );
      when(
        () => tokenStorage.saveTokens(
          accessToken: any(named: 'accessToken'),
          refreshToken: any(named: 'refreshToken'),
        ),
      ).thenAnswer((_) async {});

      final result = await repository.login(
        email: 'a@b.com',
        password: '123',
      );

      expect(result, isA<Ok<dynamic>>());
      verify(
        () => tokenStorage.saveTokens(
          accessToken: 'access-123',
          refreshToken: 'refresh-123',
        ),
      ).called(1);
    },
  );

  test(
    'returns Err instead of hanging when the API omits a token '
    '(observed in production with the old contract: HTTP 200 with token: null)',
    () async {
      when(
        () => remoteDataSource.login(any()),
      ).thenAnswer(
        (_) async => const LoginResponseDto(
          refreshToken: 'refresh-123',
          userId: 'user-1',
          profileType: ProfileTypeDto.customer,
        ),
      );

      final result = await repository.login(
        email: 'a@b.com',
        password: '123',
      );

      expect(result, isA<Err<dynamic>>());
      expect((result as Err<dynamic>).failure, isA<UnknownFailure>());
      verifyNever(
        () => tokenStorage.saveTokens(
          accessToken: any(named: 'accessToken'),
          refreshToken: any(named: 'refreshToken'),
        ),
      );
    },
  );

  test('logout clears both the auth tokens and the cart session id', () async {
    when(() => tokenStorage.clear()).thenAnswer((_) async {});
    when(() => cartSessionStorage.clear()).thenAnswer((_) async {});

    await repository.logout();

    verify(() => tokenStorage.clear()).called(1);
    verify(() => cartSessionStorage.clear()).called(1);
  });
}
