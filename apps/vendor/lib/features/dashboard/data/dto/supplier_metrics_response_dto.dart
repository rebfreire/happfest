import 'package:freezed_annotation/freezed_annotation.dart';

part 'supplier_metrics_response_dto.freezed.dart';
part 'supplier_metrics_response_dto.g.dart';

/// Corresponde a `SupplierMetricsResponse` em `docs/api/openapi.json`.
@freezed
abstract class SupplierMetricsResponseDto with _$SupplierMetricsResponseDto {
  const factory SupplierMetricsResponseDto({
    @Default(0) double acceptanceRatePercent,
    @Default(0) double averageRating,
    @Default(0) int totalReviews,
    @Default(0) int acceptedCount,
    @Default(0) int totalDecisions,
  }) = _SupplierMetricsResponseDto;

  factory SupplierMetricsResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SupplierMetricsResponseDtoFromJson(json);
}
