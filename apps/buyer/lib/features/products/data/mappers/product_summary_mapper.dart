import 'package:happfest/features/products/data/dto/product_response_dto.dart';
import 'package:happfest/features/products/data/dto/product_search_response_dto.dart';
import 'package:happfest/features/products/domain/entities/product_summary.dart';
import 'package:happfest/features/products/domain/entities/product_type.dart';

extension ProductSearchResponseDtoMapper on ProductSearchResponseDto {
  ProductSummary toEntity() {
    return ProductSummary(
      id: id,
      name: name,
      slug: slug,
      storeName: storeName,
      productType: productType.toEntity(),
      coverImageUrl: coverImageUrl,
      minPrice: minPrice,
    );
  }
}

extension ProductTypeDtoMapper on ProductTypeDto {
  ProductType toEntity() {
    return switch (this) {
      ProductTypeDto.physical => ProductType.physical,
      ProductTypeDto.service => ProductType.service,
    };
  }
}
