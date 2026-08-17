import 'package:freezed_annotation/freezed_annotation.dart';

part 'cart_item_request_dto.freezed.dart';
part 'cart_item_request_dto.g.dart';

/// Corresponde a `CartItemRequest` em `docs/api/openapi.json`.
@freezed
abstract class CartItemRequestDto with _$CartItemRequestDto {
  const factory CartItemRequestDto({
    required String productVariantId,
    required int quantity,
    required double pricingUnitQuantity,
    String? preferredDate,
    String? preferredTime,
  }) = _CartItemRequestDto;

  factory CartItemRequestDto.fromJson(Map<String, dynamic> json) =>
      _$CartItemRequestDtoFromJson(json);
}
