import 'package:happfest_core/core/error/result.dart';
import 'package:happfest_core/core/network/paged_response.dart';
import 'package:happfest_fornecedor/features/dashboard/domain/entities/sub_order_preview.dart';
import 'package:happfest_fornecedor/features/dashboard/domain/repositories/dashboard_repository.dart';

class GetPendingOrdersUseCase {
  const GetPendingOrdersUseCase(this._repository);

  final DashboardRepository _repository;

  Future<Result<PagedResponse<SubOrderPreview>>> call({
    int page = 0,
    int size = 5,
  }) {
    return _repository.getPendingOrders(page: page, size: size);
  }
}
