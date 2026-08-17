import 'package:freezed_annotation/freezed_annotation.dart';

part 'cart_item.freezed.dart';

@freezed
abstract class CartItem with _$CartItem {
  const factory CartItem({
    required String id,
    required String productId,
    required String productName,
    required String storeName,
    required int quantity,
    required double pricingUnitQuantity,
    required double unitPrice,
    required double lineTotal,
    String? preferredDate,
    String? preferredTime,
  }) = _CartItem;
}
