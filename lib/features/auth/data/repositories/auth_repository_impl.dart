import 'package:dio/dio.dart';
import 'package:happfest/core/error/failure.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/core/network/api_exception.dart';
import 'package:happfest/core/storage/cart_session_storage.dart';
import 'package:happfest/core/storage/token_storage.dart';
import 'package:happfest/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:happfest/features/auth/data/dto/login_request_dto.dart';
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
      final token = response.token;
      if (token == null) {
        return const Err(
          UnknownFailure(
            'Não foi possível concluir o login (token não retornado pela '
            'API). Tente novamente em alguns instantes.',
          ),
        );
      }
      await _tokenStorage.saveToken(token);
      return Ok(response.toEntity(token));
    } on DioException catch (exception) {
      final error = exception.error;
      final failure = error is ApiException
          ? error.failure
          : const UnknownFailure();
      return Err(failure);
    }
  }

  @override
  Future<void> logout() async {
    await _tokenStorage.clear();
    // Nova sessão anônima de carrinho para o próximo uso do dispositivo,
    // evitando associar o carrinho de quem acabou de deslogar a outra conta.
    await _cartSessionStorage.clear();
  }
}
