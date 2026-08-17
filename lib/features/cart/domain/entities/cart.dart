import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:happfest/features/cart/domain/entities/cart_item.dart';

part 'cart.freezed.dart';

@freezed
abstract class Cart with _$Cart {
  const factory Cart({
    required String id,
    @Default([]) List<CartItem> items,
    @Default(0) int totalItems,
    @Default(0) double subtotal,
  }) = _Cart;
}
