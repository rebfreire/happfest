import 'package:freezed_annotation/freezed_annotation.dart';

part 'registration_address_request_dto.freezed.dart';
part 'registration_address_request_dto.g.dart';

/// Corresponde a `RegistrationAddressRequest` em `docs/api/openapi.json` —
/// endereço exigido no cadastro (`POST /customers`) e na ativação
/// (`POST /customers/me/activate`), usado para provisionar a subconta
/// financeira Asaas do cliente.
@freezed
abstract class RegistrationAddressRequestDto
    with _$RegistrationAddressRequestDto {
  const factory RegistrationAddressRequestDto({
    required String street,
    required String number,
    required String neighborhood,
    required int cityCodigoIbge,
    required int stateCodigoUf,
    required String zipCode,
    String? complement,
  }) = _RegistrationAddressRequestDto;

  factory RegistrationAddressRequestDto.fromJson(Map<String, dynamic> json) =>
      _$RegistrationAddressRequestDtoFromJson(json);
}
