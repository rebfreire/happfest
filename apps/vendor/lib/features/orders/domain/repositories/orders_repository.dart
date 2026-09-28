import 'package:happfest_core/core/error/result.dart';
import 'package:happfest_core/core/network/paged_response.dart';
import 'package:happfest_fornecedor/features/orders/domain/entities/sub_order.dart';
import 'package:happfest_fornecedor/features/orders/domain/entities/sub_order_status.dart';

abstract interface class OrdersRepository {
  Future<Result<PagedResponse<SubOrder>>> list({
    SubOrderStatus? status,
    int page = 0,
    int size = 20,
  });

  Future<Result<SubOrder>> getById(String id);

  Future<Result<void>> accept(String id);

  Future<Result<void>> reject(String id, {String? reason});

  Future<Result<void>> deliver(String id);

  Future<Result<void>> cancel(String id, {String? reason});
}
