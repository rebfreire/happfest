import 'package:freezed_annotation/freezed_annotation.dart';

part 'cart_item_response_dto.freezed.dart';
part 'cart_item_response_dto.g.dart';

/// Corresponde a `CartItemResponse` em `docs/api/openapi.json`.
@freezed
abstract class CartItemResponseDto with _$CartItemResponseDto {
  const factory CartItemResponseDto({
    required String id,
    required String productId,
    required String productName,
    required String productSlug,
    required String storeId,
    required String storeName,
    required int quantity,
    required double pricingUnitQuantity,
    required double unitPrice,
    required double lineTotal,
    String? productVariantId,
    String? sku,
    String? preferredDate,
    String? preferredTime,
  }) = _CartItemResponseDto;

  factory CartItemResponseDto.fromJson(Map<String, dynamic> json) =>
      _$CartItemResponseDtoFromJson(json);
}
