import 'package:freezed_annotation/freezed_annotation.dart';

part 'checkout_result.freezed.dart';

enum PaymentStatus {
  pending,
  approved,
  failed,
  cancelled,
  partiallyRefunded,
  refunded,
}

@freezed
abstract class CheckoutResult with _$CheckoutResult {
  const factory CheckoutResult({
    String? orderId,
    @Default(0) double orderTotal,
    PaymentStatus? paymentStatus,
    String? paymentLink,
    String? failureReason,
  }) = _CheckoutResult;
}
