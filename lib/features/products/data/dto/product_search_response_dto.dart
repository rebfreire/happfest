import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:happfest/features/products/data/dto/product_response_dto.dart';

part 'product_search_response_dto.freezed.dart';
part 'product_search_response_dto.g.dart';

/// Corresponde a `ProductSearchResponse` em `docs/api/openapi.json` — é o
/// shape usado por `/search/products`, mais enxuto que `ProductResponse`
/// (usado no detalhe do produto), já com `coverImageUrl`/`minPrice`/
/// `storeName` prontos para a grade da Home.
@freezed
abstract class ProductSearchResponseDto with _$ProductSearchResponseDto {
  const factory ProductSearchResponseDto({
    required String id,
    required String name,
    required String slug,
    required String storeId,
    required String storeName,
    required ProductTypeDto productType,
    String? categoryId,
    String? categoryPath,
    String? coverImageUrl,
    double? minPrice,
    @Default(false) bool featured,
    @Default(0) double averageRating,
    @Default(0) int salesCount,
  }) = _ProductSearchResponseDto;

  factory ProductSearchResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ProductSearchResponseDtoFromJson(json);
}
