import 'package:happfest_auth/auth/domain/entities/auth_session.dart';
import 'package:happfest_auth/auth/domain/repositories/auth_repository.dart';
import 'package:happfest_core/core/error/result.dart';

class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthSession>> call({
    required String email,
    required String password,
  }) {
    return _repository.login(email: email, password: password);
  }
}
