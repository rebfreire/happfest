import 'package:happfest/core/error/result.dart';
import 'package:happfest/features/checkout/domain/entities/payment.dart';
import 'package:happfest/features/checkout/domain/repositories/checkout_repository.dart';

class GetPaymentStatusUseCase {
  const GetPaymentStatusUseCase(this._repository);

  final CheckoutRepository _repository;

  Future<Result<Payment>> call(String orderId) {
    return _repository.getPaymentStatus(orderId);
  }
}
