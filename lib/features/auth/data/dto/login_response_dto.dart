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

/// Corresponde a `LoginResponse` em `docs/api/openapi.json`.
///
/// Note: a API não retorna um refresh token separado — `token` é trocado
/// por um novo via `POST /auth/refresh?token=...`.
@freezed
abstract class LoginResponseDto with _$LoginResponseDto {
  const factory LoginResponseDto({
    required String token,
    required String userId,
    required ProfileTypeDto profileType,
    @Default([]) List<String> permissions,
  }) = _LoginResponseDto;

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseDtoFromJson(json);
}
