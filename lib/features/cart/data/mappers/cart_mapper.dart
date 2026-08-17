import 'package:happfest/features/cart/data/dto/cart_item_response_dto.dart';
import 'package:happfest/features/cart/data/dto/cart_response_dto.dart';
import 'package:happfest/features/cart/domain/entities/cart.dart';
import 'package:happfest/features/cart/domain/entities/cart_item.dart';

extension CartResponseDtoMapper on CartResponseDto {
  Cart toEntity() {
    return Cart(
      id: id,
      items: items.map((item) => item.toEntity()).toList(),
      totalItems: totalItems,
      subtotal: subtotal,
    );
  }
}

extension CartItemResponseDtoMapper on CartItemResponseDto {
  CartItem toEntity() {
    return CartItem(
      id: id,
      productId: productId,
      productName: productName,
      storeName: storeName,
      quantity: quantity,
      pricingUnitQuantity: pricingUnitQuantity,
      unitPrice: unitPrice,
      lineTotal: lineTotal,
      preferredDate: preferredDate,
      preferredTime: preferredTime,
    );
  }
}
