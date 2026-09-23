import 'package:freezed_annotation/freezed_annotation.dart';

part 'service_availability_response_dto.freezed.dart';
part 'service_availability_response_dto.g.dart';

/// Corresponde a `ServiceAvailabilityDateResponse` em
/// `docs/api/openapi.json`.
@freezed
abstract class ServiceAvailabilityDateResponseDto
    with _$ServiceAvailabilityDateResponseDto {
  const factory ServiceAvailabilityDateResponseDto({
    String? date,
    @Default([]) List<String> availableTimes,
  }) = _ServiceAvailabilityDateResponseDto;

  factory ServiceAvailabilityDateResponseDto.fromJson(
    Map<String, dynamic> json,
  ) => _$ServiceAvailabilityDateResponseDtoFromJson(json);
}

/// Corresponde a `ServiceAvailabilityResponse` em `docs/api/openapi.json`.
@freezed
abstract class ServiceAvailabilityResponseDto
    with _$ServiceAvailabilityResponseDto {
  const factory ServiceAvailabilityResponseDto({
    String? productId,
    String? startDate,
    String? endDate,
    @Default(false) bool timeSelectionRequired,
    @Default([]) List<ServiceAvailabilityDateResponseDto> availableDates,
  }) = _ServiceAvailabilityResponseDto;

  factory ServiceAvailabilityResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ServiceAvailabilityResponseDtoFromJson(json);
}
