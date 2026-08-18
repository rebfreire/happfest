import 'package:freezed_annotation/freezed_annotation.dart';

part 'party.freezed.dart';

enum PartyStatus { active, archived }

@freezed
abstract class Party with _$Party {
  const factory Party({
    required String id,
    required String name,
    String? cityName,
    String? stateUf,
    DateTime? startDate,
    DateTime? endDate,
    @Default(0) int guestCount,
    PartyStatus? status,
  }) = _Party;
}
