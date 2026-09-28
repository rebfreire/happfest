import 'package:happfest_fornecedor/features/orders/data/dto/sub_order_item_response_dto.dart';
import 'package:happfest_fornecedor/features/orders/data/dto/sub_order_response_dto.dart';
import 'package:happfest_fornecedor/features/orders/domain/entities/sub_order.dart';
import 'package:happfest_fornecedor/features/orders/domain/entities/sub_order_item.dart';
import 'package:happfest_fornecedor/features/orders/domain/entities/sub_order_status.dart';

extension SubOrderResponseDtoMapper on SubOrderResponseDto {
  SubOrder toEntity() {
    return SubOrder(
      id: id,
      status: status.toEntity(),
      subtotal: subtotal,
      supplierAmount: supplierAmount,
      items: items.map((dto) => dto.toEntity()).toList(),
      deliveryDate: deliveryDate == null ? null : DateTime.parse(deliveryDate!),
      deliveryTime: deliveryTime,
      deliveryStreet: deliveryStreet,
      deliveryNumber: deliveryNumber,
      deliveryNeighborhood: deliveryNeighborhood,
      deliveryCityName: deliveryCityName,
      cancellationReason: cancellationReason,
    );
  }
}

extension SubOrderStatusDtoMapper on SubOrderStatusDto {
  SubOrderStatus toEntity() {
    return switch (this) {
      SubOrderStatusDto.awaitingPayment => SubOrderStatus.awaitingPayment,
      SubOrderStatusDto.pending => SubOrderStatus.pending,
      SubOrderStatusDto.accepted => SubOrderStatus.accepted,
      SubOrderStatusDto.delivered => SubOrderStatus.delivered,
      SubOrderStatusDto.contested => SubOrderStatus.contested,
      SubOrderStatusDto.completed => SubOrderStatus.completed,
      SubOrderStatusDto.cancelled => SubOrderStatus.cancelled,
      SubOrderStatusDto.rejected => SubOrderStatus.rejected,
    };
  }
}

extension SubOrderItemResponseDtoMapper on SubOrderItemResponseDto {
  SubOrderItem toEntity() {
    return SubOrderItem(
      id: id,
      productName: productName,
      productType: productType.toEntity(),
      quantity: quantity,
      unitPrice: unitPrice,
      lineTotal: lineTotal,
    );
  }
}

extension ProductTypeDtoMapper on ProductTypeDto {
  SubOrderProductType toEntity() {
    return switch (this) {
      ProductTypeDto.physical => SubOrderProductType.physical,
      ProductTypeDto.service => SubOrderProductType.service,
    };
  }
}

extension SubOrderStatusEntityMapper on SubOrderStatus {
  String toApiValue() {
    return switch (this) {
      SubOrderStatus.awaitingPayment => 'AWAITING_PAYMENT',
      SubOrderStatus.pending => 'PENDING',
      SubOrderStatus.accepted => 'ACCEPTED',
      SubOrderStatus.delivered => 'DELIVERED',
      SubOrderStatus.contested => 'CONTESTED',
      SubOrderStatus.completed => 'COMPLETED',
      SubOrderStatus.cancelled => 'CANCELLED',
      SubOrderStatus.rejected => 'REJECTED',
    };
  }
}
