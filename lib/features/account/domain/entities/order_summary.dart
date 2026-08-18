import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_summary.freezed.dart';

@freezed
abstract class OrderSummary with _$OrderSummary {
  const factory OrderSummary({
    required String id,
    required double totalAmount,
    DateTime? deliveryDate,
    DateTime? createdAt,
  }) = _OrderSummary;
}
