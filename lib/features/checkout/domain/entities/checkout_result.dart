import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:happfest/features/checkout/domain/entities/payment.dart';

part 'checkout_result.freezed.dart';

@freezed
abstract class CheckoutResult with _$CheckoutResult {
  const factory CheckoutResult({
    String? orderId,
    @Default(0) double orderTotal,
    Payment? payment,
    String? paymentAttemptId,
    String? paymentStatusUrl,
    @Default(false) bool paymentProcessingAsync,
  }) = _CheckoutResult;
}
