import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:happfest_fornecedor/features/orders/domain/entities/sub_order_item.dart';
import 'package:happfest_fornecedor/features/orders/domain/entities/sub_order_status.dart';

part 'sub_order.freezed.dart';

@freezed
abstract class SubOrder with _$SubOrder {
  const factory SubOrder({
    required String id,
    required SubOrderStatus status,
    required double subtotal,
    required double supplierAmount,
    required List<SubOrderItem> items,
    DateTime? deliveryDate,
    String? deliveryTime,
    String? deliveryStreet,
    String? deliveryNumber,
    String? deliveryNeighborhood,
    String? deliveryCityName,
    String? cancellationReason,
  }) = _SubOrder;
}
