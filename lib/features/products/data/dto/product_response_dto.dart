import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_response_dto.freezed.dart';
part 'product_response_dto.g.dart';

enum ProductTypeDto {
  @JsonValue('PHYSICAL')
  physical,
  @JsonValue('SERVICE')
  service,
}

enum ProductStatusDto {
  @JsonValue('DRAFT')
  draft,
  @JsonValue('PUBLISHED')
  published,
  @JsonValue('PAUSED')
  paused,
  @JsonValue('ARCHIVED')
  archived,
}

/// Unidade de venda/precificação — bate com o "R\$400.00 / hora" visto na
/// tela de detalhe do produto no site.
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

/// Corresponde a `ProductResponse` em `docs/api/openapi.json`. Não há um
/// campo `price` único — o preço é sempre por unidade
/// (`pricingUnitMin`/`pricingUnitLabel`), consistente com o que a Home e a
/// tela de detalhe do site mostram (ex.: "R\$400,00 / hora").
@freezed
abstract class ProductResponseDto with _$ProductResponseDto {
  const factory ProductResponseDto({
    required String id,
    required String storeId,
    required String categoryId,
    required String name,
    required String slug,
    required ProductTypeDto productType,
    required ProductStatusDto status,
    String? categoryPath,
    String? description,
    @Default(false) bool featured,
    @Default(false) bool hasVariants,
    PricingUnitTypeDto? pricingUnitType,
    String? pricingUnitLabel,
    double? pricingUnitMin,
    double? pricingUnitMax,
    double? pricingUnitStep,
    @Default(0) double averageRating,
    @Default(0) int salesCount,
  }) = _ProductResponseDto;

  factory ProductResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ProductResponseDtoFromJson(json);
}
