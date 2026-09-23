import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment.freezed.dart';

enum PaymentStatus {
  pending,
  approved,
  failed,
  cancelled,
  partiallyRefunded,
  refunded,
  chargeback,
}

extension PaymentStatusX on PaymentStatus {
  /// Estados terminais em que o polling de `GET /payments/order/{orderId}`
  /// deve parar — ver `docs/progress/11-checkout.md`.
  bool get isTerminal => switch (this) {
    PaymentStatus.approved ||
    PaymentStatus.failed ||
    PaymentStatus.cancelled ||
    PaymentStatus.partiallyRefunded ||
    PaymentStatus.refunded ||
    PaymentStatus.chargeback => true,
    PaymentStatus.pending => false,
  };
}

enum PaymentActionType { pix, boleto, hostedRedirect, none }

@freezed
abstract class PaymentAction with _$PaymentAction {
  const factory PaymentAction({
    @Default(PaymentActionType.none) PaymentActionType type,
    String? url,
    String? pixCopyPaste,
    String? pixQrCode,
    String? boletoIdentificationField,
    String? boletoPdfUrl,
    DateTime? expiresAt,
  }) = _PaymentAction;
}

@freezed
abstract class Payment with _$Payment {
  const factory Payment({
    required String id,
    String? orderId,
    PaymentStatus? status,
    @Default(0) double amount,
    String? paymentLink,
    String? failureReason,
    PaymentAction? action,
    DateTime? expiresAt,
  }) = _Payment;

  const Payment._();

  bool get isTerminal => status?.isTerminal ?? false;

  bool get hasAction =>
      action != null && action!.type != PaymentActionType.none;
}
