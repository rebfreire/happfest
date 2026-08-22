import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_detail.freezed.dart';

enum SubOrderStatus {
  awaitingPayment,
  pending,
  accepted,
  delivered,
  contested,
  completed,
  cancelled,
  rejected,
}

extension SubOrderStatusLabel on SubOrderStatus {
  String get label => switch (this) {
    SubOrderStatus.awaitingPayment => 'Aguardando pagamento',
    SubOrderStatus.pending => 'Pendente',
    SubOrderStatus.accepted => 'Aceito',
    SubOrderStatus.delivered => 'Entregue',
    SubOrderStatus.contested => 'Contestado',
    SubOrderStatus.completed => 'Concluído',
    SubOrderStatus.cancelled => 'Cancelado',
    SubOrderStatus.rejected => 'Rejeitado',
  };
}

@freezed
abstract class OrderDetail with _$OrderDetail {
  const factory OrderDetail({
    required String id,
    @Default(0) double totalAmount,
    DateTime? deliveryDate,
    DateTime? createdAt,
    @Default([]) List<SubOrderDetail> subOrders,
  }) = _OrderDetail;
}

@freezed
abstract class SubOrderDetail with _$SubOrderDetail {
  const factory SubOrderDetail({
    required String id,
    required String storeName,
    SubOrderStatus? status,
    @Default(0) double subtotal,
    DateTime? deliveryDate,
    String? deliveryTime,
    @Default([]) List<SubOrderItemDetail> items,
  }) = _SubOrderDetail;
}

@freezed
abstract class SubOrderItemDetail with _$SubOrderItemDetail {
  const factory SubOrderItemDetail({
    required String id,
    required String productName,
    @Default(0) int quantity,
    @Default(0) double unitPrice,
    @Default(0) double lineTotal,
  }) = _SubOrderItemDetail;
}
