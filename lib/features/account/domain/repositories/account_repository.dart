import 'package:happfest/core/error/result.dart';
import 'package:happfest/core/network/paged_response.dart';
import 'package:happfest/features/account/domain/entities/customer_account.dart';
import 'package:happfest/features/account/domain/entities/customer_address.dart';
import 'package:happfest/features/account/domain/entities/order_detail.dart';
import 'package:happfest/features/account/domain/entities/order_summary.dart';

abstract interface class AccountRepository {
  Future<Result<CustomerAccount>> getContext();

  Future<Result<List<CustomerAddress>>> getAddresses();

  Future<Result<PagedResponse<OrderSummary>>> getOrders({
    int page = 0,
    int size = 20,
  });

  Future<Result<OrderDetail>> getOrder(String id);

  Future<Result<CustomerAddress>> createAddress({
    required String label,
    required String street,
    required String number,
    required String neighborhood,
    required int cityCodigoIbge,
    required int stateCodigoUf,
    required String zipCode,
    String? complement,
  });
}
