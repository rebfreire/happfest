import 'package:happfest/core/error/result.dart';
import 'package:happfest/features/auth/domain/entities/auth_session.dart';

abstract interface class AuthRepository {
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
  });

  /// `POST /customers` — não retorna tokens nem permite login imediato: a
  /// API exige verificação de e-mail antes de autenticar (um login logo
  /// após o cadastro falha com 401/403 pedindo a verificação), então não
  /// há auto-login aqui. Desde que o backend provisiona automaticamente
  /// uma subconta financeira Asaas por cliente, todos os campos são
  /// obrigatórios: sem eles a API rejeita o cadastro com 422.
  Future<Result<void>> signup({
    required String name,
    required String email,
    required String password,
    required String cpf,
    required String phone,
    /// Formato `YYYY-MM-DD`, sem conversão de fuso horário.
    required String birthDate,
    required double incomeValue,
    required String street,
    required String number,
    required String neighborhood,
    required int cityCodigoIbge,
    required int stateCodigoUf,
    required String zipCode,
    String? complement,
  });

  /// `POST /auth/recuperar-senha` — envia um e-mail com link de
  /// recuperação de senha; público, não exige sessão ativa.
  Future<Result<void>> requestPasswordReset(String email);

  Future<void> logout();
}
