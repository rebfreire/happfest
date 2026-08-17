import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_variant_response_dto.freezed.dart';
part 'product_variant_response_dto.g.dart';

/// Corresponde a `ProductVariantResponse` em `docs/api/openapi.json`.
@freezed
abstract class ProductVariantResponseDto with _$ProductVariantResponseDto {
  const factory ProductVariantResponseDto({
    required String id,
    required String productId,
    String? sku,
    double? price,
    double? finalPrice,
    @Default(true) bool active,
  }) = _ProductVariantResponseDto;

  factory ProductVariantResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ProductVariantResponseDtoFromJson(json);
}
