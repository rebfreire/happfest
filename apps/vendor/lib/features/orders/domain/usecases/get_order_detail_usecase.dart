import 'package:happfest_core/core/error/result.dart';
import 'package:happfest_fornecedor/features/orders/domain/entities/sub_order.dart';
import 'package:happfest_fornecedor/features/orders/domain/repositories/orders_repository.dart';

class GetOrderDetailUseCase {
  const GetOrderDetailUseCase(this._repository);

  final OrdersRepository _repository;

  Future<Result<SubOrder>> call(String id) => _repository.getById(id);
}
