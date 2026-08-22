import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_response_dto.freezed.dart';
part 'login_response_dto.g.dart';

enum ProfileTypeDto {
  @JsonValue('CUSTOMER')
  customer,
  @JsonValue('SUPPLIER')
  supplier,
  @JsonValue('FRANCHISEE')
  franchisee,
  @JsonValue('ADMIN')
  admin,
}

/// Corresponde à resposta de `POST /auth/mobile/login` e
/// `POST /auth/mobile/refresh` (contrato enviado pelo time da API em
/// 2026-08-18, substitui o `POST /auth/login` antigo — ver
/// `docs/progress/03-auth.md`).
///
/// Nenhum campo é tratado como obrigatório aqui: o schema anterior
/// (`LoginResponse`) já mandou `token: null` num 200 OK real, então mesmo
/// campos "óbvios" como `accessToken` são nullable — a validação de
/// presença fica em `AuthRepositoryImpl`.
@freezed
abstract class LoginResponseDto with _$LoginResponseDto {
  const factory LoginResponseDto({
    String? tokenType,
    String? accessToken,
    String? refreshToken,
    int? expiresIn,
    int? refreshExpiresIn,
    String? userId,
    ProfileTypeDto? profileType,
    @Default([]) List<String> permissions,
  }) = _LoginResponseDto;

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseDtoFromJson(json);
}
