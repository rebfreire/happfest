import 'package:dio/dio.dart';
import 'package:happfest/core/error/failure.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/core/network/api_exception.dart';
import 'package:happfest/core/storage/cart_session_storage.dart';
import 'package:happfest/core/storage/token_storage.dart';
import 'package:happfest/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:happfest/features/auth/data/dto/login_request_dto.dart';
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
  Future<Result<AuthSession>> signup({
    required String name,
    required String email,
    required String password,
    required String cpf,
    required String phone,
  }) async {
    try {
      await _remoteDataSource.signup(
        SignupRequestDto(
          nome: name,
          email: email,
          senha: password,
          cpf: cpf,
          phone: phone,
        ),
      );
    } on DioException catch (exception) {
      return Err(_failureOf(exception));
    }
    // O cadastro não retorna tokens — loga em seguida com as mesmas
    // credenciais para obter a sessão, igual ao fluxo normal de login.
    return login(email: email, password: password);
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
