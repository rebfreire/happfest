import 'package:happfest/core/error/result.dart';
import 'package:happfest/features/account/domain/entities/order_detail.dart';
import 'package:happfest/features/account/domain/repositories/account_repository.dart';

class GetOrderUseCase {
  const GetOrderUseCase(this._repository);

  final AccountRepository _repository;

  Future<Result<OrderDetail>> call(String id) => _repository.getOrder(id);
}
