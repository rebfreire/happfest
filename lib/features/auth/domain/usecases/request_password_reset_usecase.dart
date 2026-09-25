import 'package:happfest/core/error/result.dart';
import 'package:happfest/features/auth/domain/repositories/auth_repository.dart';

class RequestPasswordResetUseCase {
  const RequestPasswordResetUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<void>> call(String email) {
    return _repository.requestPasswordReset(email);
  }
}
