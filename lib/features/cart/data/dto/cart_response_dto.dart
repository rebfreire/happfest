import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:happfest/features/cart/data/dto/cart_item_response_dto.dart';

part 'cart_response_dto.freezed.dart';
part 'cart_response_dto.g.dart';

/// Corresponde a `CartResponse` em `docs/api/openapi.json`.
@freezed
abstract class CartResponseDto with _$CartResponseDto {
  const factory CartResponseDto({
    required String id,
    String? customerId,
    String? sessionId,
    @Default([]) List<CartItemResponseDto> items,
    @Default(0) int totalItems,
    @Default(0) double subtotal,
  }) = _CartResponseDto;

  factory CartResponseDto.fromJson(Map<String, dynamic> json) =>
      _$CartResponseDtoFromJson(json);
}
