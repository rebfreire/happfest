import 'package:happfest/features/service_availability/data/dto/service_availability_response_dto.dart';
import 'package:happfest/features/service_availability/domain/entities/service_availability.dart';

extension ServiceAvailabilityResponseDtoMapper
    on ServiceAvailabilityResponseDto {
  ServiceAvailability toEntity() {
    return ServiceAvailability(
      timeSelectionRequired: timeSelectionRequired,
      availableDates: availableDates
          .map((dto) => dto.toEntity())
          .whereType<ServiceAvailabilityDate>()
          .toList(),
    );
  }
}

extension ServiceAvailabilityDateResponseDtoMapper
    on ServiceAvailabilityDateResponseDto {
  ServiceAvailabilityDate? toEntity() {
    final rawDate = date;
    if (rawDate == null) return null;
    final parsed = DateTime.tryParse(rawDate);
    if (parsed == null) return null;
    return ServiceAvailabilityDate(
      date: parsed,
      availableTimes: availableTimes,
    );
  }
}
