import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:happfest/features/auth/data/dto/registration_address_request_dto.dart';

part 'signup_request_dto.freezed.dart';
part 'signup_request_dto.g.dart';

/// Corresponde a `CustomerRequest` em `docs/api/openapi.json` —
/// `POST /customers`, endpoint público de cadastro de novo cliente. Desde
/// que o backend passou a provisionar automaticamente uma subconta
/// financeira Asaas por cliente, o cadastro exige `birthDate`,
/// `incomeValue` e `address` completos — não apenas os dados de acesso.
///
@freezed
abstract class SignupRequestDto with _$SignupRequestDto {
  const factory SignupRequestDto({
    required String nome,
    required String email,
    required String senha,
    required String cpf,
    required String phone,
    /// Formato `YYYY-MM-DD`, sem conversão de fuso horário.
    required String birthDate,
    required double incomeValue,
    required RegistrationAddressRequestDto address,
  }) = _SignupRequestDto;

  factory SignupRequestDto.fromJson(Map<String, dynamic> json) =>
      _$SignupRequestDtoFromJson(json);
}
