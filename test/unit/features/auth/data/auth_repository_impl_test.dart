import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:happfest/core/error/failure.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/core/network/api_exception.dart';
import 'package:happfest/core/storage/cart_session_storage.dart';
import 'package:happfest/core/storage/token_storage.dart';
import 'package:happfest/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:happfest/features/auth/data/dto/login_request_dto.dart';
import 'package:happfest/features/auth/data/dto/login_response_dto.dart';
import 'package:happfest/features/auth/data/dto/registration_address_request_dto.dart';
import 'package:happfest/features/auth/data/dto/signup_request_dto.dart';
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
    registerFallbackValue(
      const SignupRequestDto(
        nome: 'a',
        email: 'a@b.com',
        senha: '123456',
        cpf: '12345678909',
        phone: '11999999999',
        birthDate: '1990-01-01',
        incomeValue: 1,
        address: RegistrationAddressRequestDto(
          street: 's',
          number: '1',
          neighborhood: 'n',
          cityCodigoIbge: 1,
          stateCodigoUf: 1,
          zipCode: '01001000',
        ),
      ),
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

  group('signup', () {
    test(
      'sends the full CustomerRequest payload required by the Asaas '
      'sub-account provisioning (birthDate, incomeValue, address), then '
      'logs in with the same credentials',
      () async {
        when(
          () => remoteDataSource.signup(any()),
        ).thenAnswer((_) async {});
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

        final result = await repository.signup(
          name: 'Maria da Silva',
          email: 'maria@example.com',
          password: 'SenhaForte123',
          cpf: '12345678909',
          phone: '11999999999',
          birthDate: '1990-05-10',
          incomeValue: 3500,
          street: 'Praça da Sé',
          number: '100',
          complement: 'Apto 12',
          neighborhood: 'Sé',
          cityCodigoIbge: 3550308,
          stateCodigoUf: 35,
          zipCode: '01001000',
        );

        expect(result, isA<Ok<dynamic>>());
        final captured = verify(
          () => remoteDataSource.signup(captureAny()),
        ).captured;
        final sent = (captured.single as SignupRequestDto).toJson();
        expect(sent, {
          'nome': 'Maria da Silva',
          'email': 'maria@example.com',
          'senha': 'SenhaForte123',
          'cpf': '12345678909',
          'phone': '11999999999',
          'birthDate': '1990-05-10',
          'incomeValue': 3500.0,
          'address': {
            'street': 'Praça da Sé',
            'number': '100',
            'complement': 'Apto 12',
            'neighborhood': 'Sé',
            'cityCodigoIbge': 3550308,
            'stateCodigoUf': 35,
            'zipCode': '01001000',
          },
        });
      },
    );

    test(
      'sends complement as null (not omitted) when not provided — same '
      'convention already used by CustomerAddressRequestDto',
      () async {
        when(() => remoteDataSource.signup(any())).thenAnswer((_) async {});
        when(() => remoteDataSource.login(any())).thenAnswer(
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

        await repository.signup(
          name: 'Maria',
          email: 'maria@example.com',
          password: 'SenhaForte123',
          cpf: '12345678909',
          phone: '11999999999',
          birthDate: '1990-05-10',
          incomeValue: 3500,
          street: 'Praça da Sé',
          number: '100',
          neighborhood: 'Sé',
          cityCodigoIbge: 3550308,
          stateCodigoUf: 35,
          zipCode: '01001000',
        );

        final captured = verify(
          () => remoteDataSource.signup(captureAny()),
        ).captured;
        final sent = (captured.single as SignupRequestDto).toJson();
        expect((sent['address'] as Map)['complement'], isNull);
      },
    );

    test('propagates 409 (email/CPF already registered) as ConflictFailure', () async {
      when(() => remoteDataSource.signup(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/customers'),
          response: Response(
            requestOptions: RequestOptions(path: '/customers'),
            statusCode: 409,
            data: {'title': 'Conflito', 'detail': 'E-mail já cadastrado.'},
          ),
          error: const ApiException(
            ConflictFailure('E-mail já cadastrado.'),
          ),
        ),
      );

      final result = await repository.signup(
        name: 'Maria',
        email: 'maria@example.com',
        password: 'SenhaForte123',
        cpf: '12345678909',
        phone: '11999999999',
        birthDate: '1990-05-10',
        incomeValue: 3500,
        street: 'Praça da Sé',
        number: '100',
        neighborhood: 'Sé',
        cityCodigoIbge: 3550308,
        stateCodigoUf: 35,
        zipCode: '01001000',
      );

      expect(result, isA<Err<dynamic>>());
      expect(
        (result as Err<dynamic>).failure,
        const ConflictFailure('E-mail já cadastrado.'),
      );
    });

    test(
      'propagates 422 (validation, e.g. missing/invalid field) as '
      'ValidationFailure',
      () async {
        when(() => remoteDataSource.signup(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/customers'),
            response: Response(
              requestOptions: RequestOptions(path: '/customers'),
              statusCode: 422,
            ),
            error: const ApiException(
              ValidationFailure({
                'incomeValue': ['deve ser maior que zero'],
              }),
            ),
          ),
        );

        final result = await repository.signup(
          name: 'Maria',
          email: 'maria@example.com',
          password: 'SenhaForte123',
          cpf: '12345678909',
          phone: '11999999999',
          birthDate: '1990-05-10',
          incomeValue: 0,
          street: 'Praça da Sé',
          number: '100',
          neighborhood: 'Sé',
          cityCodigoIbge: 3550308,
          stateCodigoUf: 35,
          zipCode: '01001000',
        );

        expect(result, isA<Err<dynamic>>());
        expect((result as Err<dynamic>).failure, isA<ValidationFailure>());
      },
    );

    test(
      'propagates 404 (city/state not found) as NotFoundFailure',
      () async {
        when(() => remoteDataSource.signup(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/customers'),
            response: Response(
              requestOptions: RequestOptions(path: '/customers'),
              statusCode: 404,
            ),
            error: const ApiException(
              NotFoundFailure('Cidade não encontrada.'),
            ),
          ),
        );

        final result = await repository.signup(
          name: 'Maria',
          email: 'maria@example.com',
          password: 'SenhaForte123',
          cpf: '12345678909',
          phone: '11999999999',
          birthDate: '1990-05-10',
          incomeValue: 3500,
          street: 'Praça da Sé',
          number: '100',
          neighborhood: 'Sé',
          cityCodigoIbge: 999999999,
          stateCodigoUf: 35,
          zipCode: '01001000',
        );

        expect(result, isA<Err<dynamic>>());
        expect(
          (result as Err<dynamic>).failure,
          isA<NotFoundFailure>(),
        );
      },
    );

    test(
      'propagates 400 (invalid data) as a Failure with the API message',
      () async {
        when(() => remoteDataSource.signup(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/customers'),
            response: Response(
              requestOptions: RequestOptions(path: '/customers'),
              statusCode: 400,
            ),
            error: const ApiException(UnknownFailure('Dados inválidos.')),
          ),
        );

        final result = await repository.signup(
          name: 'Maria',
          email: 'maria@example.com',
          password: 'SenhaForte123',
          cpf: '12345678909',
          phone: '11999999999',
          birthDate: '1990-05-10',
          incomeValue: 3500,
          street: 'Praça da Sé',
          number: '100',
          neighborhood: 'Sé',
          cityCodigoIbge: 3550308,
          stateCodigoUf: 35,
          zipCode: '01001000',
        );

        expect(result, isA<Err<dynamic>>());
        expect((result as Err<dynamic>).failure.message, 'Dados inválidos.');
      },
    );
  });
}
