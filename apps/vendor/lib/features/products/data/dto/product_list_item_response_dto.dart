import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_list_item_response_dto.freezed.dart';
part 'product_list_item_response_dto.g.dart';

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

enum ProductTypeDto {
  @JsonValue('PHYSICAL')
  physical,
  @JsonValue('SERVICE')
  service,
}

/// Corresponde a `ProductMeListItem` em `docs/api/openapi.json` — item da
/// listagem paginada `GET /products/me`.
@freezed
abstract class ProductListItemResponseDto with _$ProductListItemResponseDto {
  const factory ProductListItemResponseDto({
    required String id,
    required String name,
    required ProductStatusDto status,
    required ProductTypeDto productType,
    required bool featured,
    String? coverImageUrl,
    double? priceFrom,
    double? priceTo,
    double? ratingAverage,
    int? reviewCount,
    int? salesCount,
  }) = _ProductListItemResponseDto;

  factory ProductListItemResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ProductListItemResponseDtoFromJson(json);
}
