import 'package:happfest_core/core/error/result.dart';
import 'package:happfest_fornecedor/features/orders/domain/repositories/orders_repository.dart';

class AcceptOrderUseCase {
  const AcceptOrderUseCase(this._repository);

  final OrdersRepository _repository;

  Future<Result<void>> call(String id) => _repository.accept(id);
}
