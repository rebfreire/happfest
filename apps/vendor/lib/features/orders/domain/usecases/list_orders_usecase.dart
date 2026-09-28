import 'package:happfest_core/core/error/result.dart';
import 'package:happfest_core/core/network/paged_response.dart';
import 'package:happfest_fornecedor/features/orders/domain/entities/sub_order.dart';
import 'package:happfest_fornecedor/features/orders/domain/entities/sub_order_status.dart';
import 'package:happfest_fornecedor/features/orders/domain/repositories/orders_repository.dart';

class ListOrdersUseCase {
  const ListOrdersUseCase(this._repository);

  final OrdersRepository _repository;

  Future<Result<PagedResponse<SubOrder>>> call({
    SubOrderStatus? status,
    int page = 0,
    int size = 20,
  }) {
    return _repository.list(status: status, page: page, size: size);
  }
}
