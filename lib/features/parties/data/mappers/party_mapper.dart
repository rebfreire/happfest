import 'package:happfest/features/parties/data/dto/party_response_dto.dart';
import 'package:happfest/features/parties/domain/entities/party.dart';

extension PartyResponseDtoMapper on PartyResponseDto {
  Party toEntity() {
    return Party(
      id: id,
      name: (name == null || name!.trim().isEmpty) ? 'Festa sem nome' : name!,
      cityName: cityNome,
      stateUf: stateUf,
      startDate: _tryParseDate(startDate),
      endDate: _tryParseDate(endDate),
      guestCount: guestCount,
      status: switch (status) {
        PartyStatusDto.active => PartyStatus.active,
        PartyStatusDto.archived => PartyStatus.archived,
        null => null,
      },
    );
  }
}

DateTime? _tryParseDate(String? value) {
  if (value == null) return null;
  return DateTime.tryParse(value);
}
