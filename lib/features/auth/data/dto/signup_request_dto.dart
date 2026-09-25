import 'package:freezed_annotation/freezed_annotation.dart';

part 'signup_request_dto.freezed.dart';
part 'signup_request_dto.g.dart';

/// Corresponde a `CustomerRequest` em `docs/api/openapi.json` —
/// `POST /customers`, endpoint público de cadastro de novo cliente.
@freezed
abstract class SignupRequestDto with _$SignupRequestDto {
  const factory SignupRequestDto({
    required String nome,
    required String email,
    required String senha,
    required String cpf,
    required String phone,
  }) = _SignupRequestDto;

  factory SignupRequestDto.fromJson(Map<String, dynamic> json) =>
      _$SignupRequestDtoFromJson(json);
}
