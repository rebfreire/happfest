import 'package:freezed_annotation/freezed_annotation.dart';

part 'supplier_metrics.freezed.dart';

@freezed
abstract class SupplierMetrics with _$SupplierMetrics {
  const factory SupplierMetrics({
    required double acceptanceRatePercent,
    required double averageRating,
    required int totalReviews,
    required int acceptedCount,
    required int totalDecisions,
  }) = _SupplierMetrics;
}
