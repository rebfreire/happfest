import 'package:happfest/core/error/result.dart';
import 'package:happfest/core/network/paged_response.dart';
import 'package:happfest/features/account/domain/entities/customer_account.dart';
import 'package:happfest/features/account/domain/entities/customer_address.dart';
import 'package:happfest/features/account/domain/entities/order_summary.dart';

abstract interface class AccountRepository {
  Future<Result<CustomerAccount>> getContext();

  Future<Result<List<CustomerAddress>>> getAddresses();

  Future<Result<PagedResponse<OrderSummary>>> getOrders({
    int page = 0,
    int size = 20,
  });
}
