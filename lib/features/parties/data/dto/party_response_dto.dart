import 'package:freezed_annotation/freezed_annotation.dart';

part 'party_response_dto.freezed.dart';
part 'party_response_dto.g.dart';

enum PartyStatusDto {
  @JsonValue('ACTIVE')
  active,
  @JsonValue('ARCHIVED')
  archived,
}

/// Corresponde a `PartyResponse` em `docs/api/openapi.json`. Só `id` é
/// obrigatório — o schema não declara nenhum campo `required` (mesma
/// cautela do bug de token nulo no login: nunca assumir não-nulo sem o
/// contrato garantir).
@freezed
abstract class PartyResponseDto with _$PartyResponseDto {
  const factory PartyResponseDto({
    required String id,
    String? name,
    String? street,
    String? number,
    String? complement,
    String? neighborhood,
    String? cityNome,
    String? stateUf,
    String? zipCode,
    String? startDate,
    String? endDate,
    @Default(0) int guestCount,
    PartyStatusDto? status,
  }) = _PartyResponseDto;

  factory PartyResponseDto.fromJson(Map<String, dynamic> json) =>
      _$PartyResponseDtoFromJson(json);
}
