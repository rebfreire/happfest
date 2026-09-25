import 'package:happfest/core/error/result.dart';
import 'package:happfest/features/auth/domain/entities/auth_session.dart';
import 'package:happfest/features/auth/domain/repositories/auth_repository.dart';

class SignupUseCase {
  const SignupUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthSession>> call({
    required String name,
    required String email,
    required String password,
    required String cpf,
    required String phone,
  }) {
    return _repository.signup(
      name: name,
      email: email,
      password: password,
      cpf: cpf,
      phone: phone,
    );
  }
}
