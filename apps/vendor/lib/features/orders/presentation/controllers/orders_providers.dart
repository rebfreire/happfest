import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happfest_core/core/error/result.dart';
import 'package:happfest_core/core/network/paged_response.dart';
import 'package:happfest_fornecedor/features/orders/data/orders_providers.dart';
import 'package:happfest_fornecedor/features/orders/domain/entities/sub_order.dart';
import 'package:happfest_fornecedor/features/orders/domain/entities/sub_order_status.dart';

final orderStatusFilterProvider =
    NotifierProvider<OrderStatusFilterController, SubOrderStatus?>(
      OrderStatusFilterController.new,
    );

class OrderStatusFilterController extends Notifier<SubOrderStatus?> {
  @override
  SubOrderStatus? build() => SubOrderStatus.pending;

  // A setter here reads oddly at the call site (`.notifier.status = x`)
  // ignore: use_setters_to_change_properties
  void setStatus(SubOrderStatus? status) => state = status;
}

final ordersListProvider = FutureProvider<Result<PagedResponse<SubOrder>>>((
  ref,
) {
  final status = ref.watch(orderStatusFilterProvider);
  return ref.watch(listOrdersUseCaseProvider)(status: status);
});

// FutureProviderFamily isn't part of flutter_riverpod's public export surface.
// ignore: specify_nonobvious_property_types
final orderDetailProvider = FutureProvider.family<Result<SubOrder>, String>((
  ref,
  id,
) {
  return ref.watch(getOrderDetailUseCaseProvider)(id);
});
