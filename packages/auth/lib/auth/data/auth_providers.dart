import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happfest_auth/auth/data/datasources/auth_remote_datasource.dart';
import 'package:happfest_auth/auth/data/repositories/auth_repository_impl.dart';
import 'package:happfest_auth/auth/domain/repositories/auth_repository.dart';
import 'package:happfest_auth/auth/domain/usecases/login_usecase.dart';
import 'package:happfest_core/core/di/app_providers.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.watch(dioProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
    ref.watch(tokenStorageProvider),
  );
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});
