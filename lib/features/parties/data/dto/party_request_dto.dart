import 'package:freezed_annotation/freezed_annotation.dart';

part 'party_request_dto.freezed.dart';
part 'party_request_dto.g.dart';

/// Corresponde a `PartyRequest` em `docs/api/openapi.json`. Datas no
/// formato `yyyy-MM-dd` (ISO 8601 sem hora).
@freezed
abstract class PartyRequestDto with _$PartyRequestDto {
  const factory PartyRequestDto({
    required String street,
    required String number,
    required String neighborhood,
    required int cityCodigoIbge,
    required int stateCodigoUf,
    required String zipCode,
    required String startDate,
    required String endDate,
    required int guestCount,
    String? name,
    String? complement,
  }) = _PartyRequestDto;

  factory PartyRequestDto.fromJson(Map<String, dynamic> json) =>
      _$PartyRequestDtoFromJson(json);
}
