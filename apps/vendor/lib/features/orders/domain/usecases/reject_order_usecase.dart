import 'package:happfest_core/core/error/result.dart';
import 'package:happfest_fornecedor/features/orders/domain/repositories/orders_repository.dart';

class RejectOrderUseCase {
  const RejectOrderUseCase(this._repository);

  final OrdersRepository _repository;

  Future<Result<void>> call(String id, {String? reason}) {
    return _repository.reject(id, reason: reason);
  }
}
