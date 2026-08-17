import 'package:happfest/features/products/data/dto/product_image_response_dto.dart';
import 'package:happfest/features/products/data/dto/product_response_dto.dart';
import 'package:happfest/features/products/data/mappers/product_summary_mapper.dart';
import 'package:happfest/features/products/domain/entities/product_detail.dart';

extension ProductResponseDtoDetailMapper on ProductResponseDto {
  /// `storeName` não vem de `ProductResponse` — é preenchido pela camada de
  /// apresentação a partir do card que originou a navegação.
  ProductDetail toDetailEntity(List<ProductImageResponseDto> images) {
    final sortedImages = [...images]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return ProductDetail(
      id: id,
      name: name,
      storeId: storeId,
      productType: productType.toEntity(),
      imageUrls: sortedImages.map((image) => image.url).toList(),
      description: description,
      pricingUnitLabel: pricingUnitLabel,
      pricingUnitMin: pricingUnitMin,
      pricingUnitMax: pricingUnitMax,
      averageRating: averageRating,
    );
  }
}
