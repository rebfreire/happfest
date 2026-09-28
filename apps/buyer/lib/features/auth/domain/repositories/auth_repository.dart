import 'package:happfest/features/auth/domain/entities/auth_session.dart';
import 'package:happfest_core/core/error/result.dart';

abstract interface class AuthRepository {
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
  });

  Future<void> logout();
}
