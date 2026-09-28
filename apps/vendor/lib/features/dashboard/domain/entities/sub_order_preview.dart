import 'package:freezed_annotation/freezed_annotation.dart';

part 'sub_order_preview.freezed.dart';

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

/// Resumo de sub-pedido para a lista de pendentes do dashboard — a
/// feature `orders` (Fase seguinte) terá sua própria entidade completa.
@freezed
abstract class SubOrderPreview with _$SubOrderPreview {
  const factory SubOrderPreview({
    required String id,
    required SubOrderStatus status,
    required double supplierAmount,
    DateTime? deliveryDate,
  }) = _SubOrderPreview;
}
