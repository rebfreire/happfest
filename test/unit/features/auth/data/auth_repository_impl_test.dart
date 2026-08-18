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

  test('returns Ok and saves the token when the API returns one', () async {
    when(
      () => remoteDataSource.login(any()),
    ).thenAnswer(
      (_) async => const LoginResponseDto(
        token: 'token-123',
        userId: 'user-1',
        profileType: ProfileTypeDto.customer,
      ),
    );
    when(() => tokenStorage.saveToken(any())).thenAnswer((_) async {});

    final result = await repository.login(email: 'a@b.com', password: '123');

    expect(result, isA<Ok<dynamic>>());
    verify(() => tokenStorage.saveToken('token-123')).called(1);
  });

  test(
    'returns Err instead of hanging when the API returns a null token '
    '(observed in production: HTTP 200 with token: null)',
    () async {
      when(
        () => remoteDataSource.login(any()),
      ).thenAnswer(
        (_) async => const LoginResponseDto(
          token: null,
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
      verifyNever(() => tokenStorage.saveToken(any()));
    },
  );

  test(
    'logout clears both the auth token and the cart session id',
    () async {
      when(() => tokenStorage.clear()).thenAnswer((_) async {});
      when(() => cartSessionStorage.clear()).thenAnswer((_) async {});

      await repository.logout();

      verify(() => tokenStorage.clear()).called(1);
      verify(() => cartSessionStorage.clear()).called(1);
    },
  );
}
