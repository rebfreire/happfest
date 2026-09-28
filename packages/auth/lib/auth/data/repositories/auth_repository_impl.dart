import 'package:dio/dio.dart';
import 'package:happfest_auth/auth/data/datasources/auth_remote_datasource.dart';
import 'package:happfest_auth/auth/data/dto/login_request_dto.dart';
import 'package:happfest_auth/auth/data/mappers/auth_session_mapper.dart';
import 'package:happfest_auth/auth/domain/entities/auth_session.dart';
import 'package:happfest_auth/auth/domain/repositories/auth_repository.dart';
import 'package:happfest_core/core/error/failure.dart';
import 'package:happfest_core/core/error/result.dart';
import 'package:happfest_core/core/network/api_exception.dart';
import 'package:happfest_core/core/storage/token_storage.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remoteDataSource, this._tokenStorage);

  final AuthRemoteDataSource _remoteDataSource;
  final TokenStorage _tokenStorage;

  @override
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _remoteDataSource.login(
        LoginRequestDto(email: email, senha: password),
      );
      await _tokenStorage.saveToken(response.token);
      return Ok(response.toEntity());
    } on DioException catch (exception) {
      final error = exception.error;
      final failure = error is ApiException
          ? error.failure
          : const UnknownFailure();
      return Err(failure);
    }
  }

  @override
  Future<void> logout() => _tokenStorage.clear();
}
