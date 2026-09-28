import 'package:freezed_annotation/freezed_annotation.dart';

part 'sub_order_item.freezed.dart';

enum SubOrderProductType { physical, service }

@freezed
abstract class SubOrderItem with _$SubOrderItem {
  const factory SubOrderItem({
    required String id,
    required String productName,
    required SubOrderProductType productType,
    required int quantity,
    required double unitPrice,
    required double lineTotal,
  }) = _SubOrderItem;
}
