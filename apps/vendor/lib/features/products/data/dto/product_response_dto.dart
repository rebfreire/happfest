import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:happfest_fornecedor/features/products/data/dto/product_list_item_response_dto.dart';

part 'product_response_dto.freezed.dart';
part 'product_response_dto.g.dart';

enum PricingUnitTypeDto {
  @JsonValue('UN')
  un,
  @JsonValue('PCT')
  pct,
  @JsonValue('CX')
  cx,
  @JsonValue('KIT')
  kit,
  @JsonValue('G')
  g,
  @JsonValue('KG')
  kg,
  @JsonValue('L')
  l,
  @JsonValue('GAL')
  gal,
  @JsonValue('M')
  m,
  @JsonValue('CM')
  cm,
  @JsonValue('HORA')
  hora,
  @JsonValue('DIA')
  dia,
  @JsonValue('SESSAO')
  sessao,
}

@freezed
abstract class ProductAttributeValueResponseDto
    with _$ProductAttributeValueResponseDto {
  const factory ProductAttributeValueResponseDto({
    required String attributeName,
    required String valueText,
  }) = _ProductAttributeValueResponseDto;

  factory ProductAttributeValueResponseDto.fromJson(
    Map<String, dynamic> json,
  ) => _$ProductAttributeValueResponseDtoFromJson(json);
}

/// Corresponde a `ProductResponse` em `docs/api/openapi.json` (subset de
/// campos usados pela tela de detalhe do fornecedor).
@freezed
abstract class ProductResponseDto with _$ProductResponseDto {
  const factory ProductResponseDto({
    required String id,
    required String categoryId,
    required String name,
    required ProductTypeDto productType,
    required ProductStatusDto status,
    required bool hasVariants,
    required bool featured,
    required PricingUnitTypeDto pricingUnitType,
    required double pricingUnitMin,
    required double pricingUnitMax,
    required double pricingUnitStep,
    @Default([]) List<ProductAttributeValueResponseDto> attributes,
    String? categoryPath,
    String? description,
    String? pricingUnitLabel,
    int? weightG,
    int? heightCm,
    int? widthCm,
    int? depthCm,
    int? salesCount,
    double? averageRating,
  }) = _ProductResponseDto;

  factory ProductResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ProductResponseDtoFromJson(json);
}
