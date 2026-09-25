import 'package:happfest/core/error/result.dart';
import 'package:happfest/features/auth/domain/entities/auth_session.dart';

abstract interface class AuthRepository {
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
  });

  /// `POST /customers` seguido de login automático com as mesmas
  /// credenciais — o cadastro em si não retorna tokens.
  Future<Result<AuthSession>> signup({
    required String name,
    required String email,
    required String password,
    required String cpf,
    required String phone,
  });

  /// `POST /auth/recuperar-senha` — envia um e-mail com link de
  /// recuperação de senha; público, não exige sessão ativa.
  Future<Result<void>> requestPasswordReset(String email);

  Future<void> logout();
}
