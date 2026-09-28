import 'package:happfest_core/core/error/result.dart';
import 'package:happfest_fornecedor/features/orders/domain/repositories/orders_repository.dart';

class CancelOrderUseCase {
  const CancelOrderUseCase(this._repository);

  final OrdersRepository _repository;

  Future<Result<void>> call(String id, {String? reason}) {
    return _repository.cancel(id, reason: reason);
  }
}
