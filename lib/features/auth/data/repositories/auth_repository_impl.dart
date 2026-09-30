import 'package:dio/dio.dart';
import 'package:happfest/core/error/failure.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/core/network/api_exception.dart';
import 'package:happfest/core/storage/cart_session_storage.dart';
import 'package:happfest/core/storage/token_storage.dart';
import 'package:happfest/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:happfest/features/auth/data/dto/login_request_dto.dart';
import 'package:happfest/features/auth/data/dto/registration_address_request_dto.dart';
import 'package:happfest/features/auth/data/dto/signup_request_dto.dart';
import 'package:happfest/features/auth/data/mappers/auth_session_mapper.dart';
import 'package:happfest/features/auth/domain/entities/auth_session.dart';
import 'package:happfest/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(
    this._remoteDataSource,
    this._tokenStorage,
    this._cartSessionStorage,
  );

  final AuthRemoteDataSource _remoteDataSource;
  final TokenStorage _tokenStorage;
  final CartSessionStorage _cartSessionStorage;

  @override
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _remoteDataSource.login(
        LoginRequestDto(email: email, senha: password),
      );
      final accessToken = response.accessToken;
      final refreshToken = response.refreshToken;
      final userId = response.userId;
      if (accessToken == null || refreshToken == null || userId == null) {
        return const Err(
          UnknownFailure(
            'Não foi possível concluir o login (resposta incompleta da '
            'API). Tente novamente em alguns instantes.',
          ),
        );
      }
      await _tokenStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
      return Ok(response.toEntity(accessToken: accessToken, userId: userId));
    } on DioException catch (exception) {
      return Err(_failureOf(exception));
    }
  }

  @override
  Future<Result<void>> signup({
    required String name,
    required String email,
    required String password,
    required String cpf,
    required String phone,
    required String birthDate,
    required double incomeValue,
    required String street,
    required String number,
    required String neighborhood,
    required int cityCodigoIbge,
    required int stateCodigoUf,
    required String zipCode,
    String? complement,
  }) async {
    try {
      await _remoteDataSource.signup(
        SignupRequestDto(
          nome: name,
          email: email,
          senha: password,
          cpf: cpf,
          phone: phone,
          birthDate: birthDate,
          incomeValue: incomeValue,
          address: RegistrationAddressRequestDto(
            street: street,
            number: number,
            complement: complement,
            neighborhood: neighborhood,
            cityCodigoIbge: cityCodigoIbge,
            stateCodigoUf: stateCodigoUf,
            zipCode: zipCode,
          ),
        ),
      );
      return const Ok(null);
    } on DioException catch (exception) {
      return Err(_failureOf(exception));
    }
  }

  @override
  Future<Result<void>> requestPasswordReset(String email) async {
    try {
      await _remoteDataSource.requestPasswordReset(email);
      return const Ok(null);
    } on DioException catch (exception) {
      return Err(_failureOf(exception));
    }
  }

  @override
  Future<void> logout() async {
    await _tokenStorage.clear();
    // Nova sessão anônima de carrinho para o próximo uso do dispositivo,
    // evitando associar o carrinho de quem acabou de deslogar a outra conta.
    await _cartSessionStorage.clear();
  }

  Failure _failureOf(DioException exception) {
    final error = exception.error;
    return error is ApiException ? error.failure : const UnknownFailure();
  }
}
