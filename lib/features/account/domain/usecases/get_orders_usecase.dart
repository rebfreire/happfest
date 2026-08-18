import 'package:happfest/core/error/result.dart';
import 'package:happfest/core/network/paged_response.dart';
import 'package:happfest/features/account/domain/entities/order_summary.dart';
import 'package:happfest/features/account/domain/repositories/account_repository.dart';

class GetOrdersUseCase {
  const GetOrdersUseCase(this._repository);

  final AccountRepository _repository;

  Future<Result<PagedResponse<OrderSummary>>> call({
    int page = 0,
    int size = 20,
  }) => _repository.getOrders(page: page, size: size);
}
