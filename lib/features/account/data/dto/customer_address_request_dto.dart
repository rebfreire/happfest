import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer_address_request_dto.freezed.dart';
part 'customer_address_request_dto.g.dart';

/// Corresponde a `CustomerAddressRequest` em `docs/api/openapi.json`.
@freezed
abstract class CustomerAddressRequestDto with _$CustomerAddressRequestDto {
  const factory CustomerAddressRequestDto({
    required String label,
    required String street,
    required String number,
    required String neighborhood,
    required int cityCodigoIbge,
    required int stateCodigoUf,
    required String zipCode,
    String? complement,
  }) = _CustomerAddressRequestDto;

  factory CustomerAddressRequestDto.fromJson(Map<String, dynamic> json) =>
      _$CustomerAddressRequestDtoFromJson(json);
}
