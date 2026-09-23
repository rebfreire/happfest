import 'package:happfest/core/error/result.dart';
import 'package:happfest/features/checkout/domain/entities/checkout_preview.dart';
import 'package:happfest/features/checkout/domain/entities/checkout_result.dart';
import 'package:happfest/features/checkout/domain/entities/payment.dart';
import 'package:happfest/features/checkout/domain/entities/payment_method.dart';

abstract interface class CheckoutRepository {
  Future<Result<CheckoutPreview>> preview({
    required String partyId,
    PaymentMethod? paymentMethod,
  });

  Future<Result<CheckoutResult>> checkout({
    required String partyId,
    required PaymentMethod paymentMethod,
    required String idempotencyKey,
    double? useBalanceAmount,
  });

  /// `GET /payments/order/{orderId}` — usado tanto pelo `paymentStatusUrl`
  /// retornado no checkout assíncrono quanto pelo polling de acompanhamento.
  Future<Result<Payment>> getPaymentStatus(String orderId);
}
