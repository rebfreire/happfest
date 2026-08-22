import 'package:happfest/core/error/result.dart';
import 'package:happfest/features/checkout/domain/entities/checkout_result.dart';
import 'package:happfest/features/checkout/domain/entities/payment_method.dart';
import 'package:happfest/features/checkout/domain/repositories/checkout_repository.dart';

class SubmitCheckoutUseCase {
  const SubmitCheckoutUseCase(this._repository);

  final CheckoutRepository _repository;

  Future<Result<CheckoutResult>> call({
    required String partyId,
    required PaymentMethod paymentMethod,
  }) {
    return _repository.checkout(
      partyId: partyId,
      paymentMethod: paymentMethod,
    );
  }
}
