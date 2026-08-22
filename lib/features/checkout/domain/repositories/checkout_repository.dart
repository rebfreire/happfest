import 'package:happfest/core/error/result.dart';
import 'package:happfest/features/checkout/domain/entities/checkout_preview.dart';
import 'package:happfest/features/checkout/domain/entities/checkout_result.dart';
import 'package:happfest/features/checkout/domain/entities/payment_method.dart';

abstract interface class CheckoutRepository {
  Future<Result<CheckoutPreview>> preview({required String partyId});

  Future<Result<CheckoutResult>> checkout({
    required String partyId,
    required PaymentMethod paymentMethod,
  });
}
