import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer_address_response_dto.freezed.dart';
part 'customer_address_response_dto.g.dart';

/// Corresponde a `CustomerAddressResponse` em `docs/api/openapi.json`. Só
/// `id` é obrigatório — o schema da API não declara nenhum campo como
/// `required` (mesma cautela do bug de token nulo no login).
@freezed
abstract class CustomerAddressResponseDto with _$CustomerAddressResponseDto {
  const factory CustomerAddressResponseDto({
    required String id,
    String? label,
    String? street,
    String? number,
    String? complement,
    String? neighborhood,
    String? cityNome,
    String? stateUf,
    String? zipCode,
    @Default(false) bool isDefault,
  }) = _CustomerAddressResponseDto;

  factory CustomerAddressResponseDto.fromJson(Map<String, dynamic> json) =>
      _$CustomerAddressResponseDtoFromJson(json);
}
