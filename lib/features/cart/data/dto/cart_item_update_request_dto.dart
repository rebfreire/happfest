import 'package:freezed_annotation/freezed_annotation.dart';

part 'cart_item_update_request_dto.freezed.dart';
part 'cart_item_update_request_dto.g.dart';

/// Corresponde a `CartItemUpdateRequest` em `docs/api/openapi.json`.
@freezed
abstract class CartItemUpdateRequestDto with _$CartItemUpdateRequestDto {
  const factory CartItemUpdateRequestDto({
    required int quantity,
    required double pricingUnitQuantity,
  }) = _CartItemUpdateRequestDto;

  factory CartItemUpdateRequestDto.fromJson(Map<String, dynamic> json) =>
      _$CartItemUpdateRequestDtoFromJson(json);
}
