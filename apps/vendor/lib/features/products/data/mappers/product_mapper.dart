import 'package:happfest_fornecedor/features/products/data/dto/product_list_item_response_dto.dart';
import 'package:happfest_fornecedor/features/products/data/dto/product_response_dto.dart';
import 'package:happfest_fornecedor/features/products/domain/entities/pricing_unit_type.dart';
import 'package:happfest_fornecedor/features/products/domain/entities/product.dart';
import 'package:happfest_fornecedor/features/products/domain/entities/product_attribute_value.dart';
import 'package:happfest_fornecedor/features/products/domain/entities/product_list_item.dart';
import 'package:happfest_fornecedor/features/products/domain/entities/product_status.dart';
import 'package:happfest_fornecedor/features/products/domain/entities/product_type.dart';

extension ProductListItemResponseDtoMapper on ProductListItemResponseDto {
  ProductListItem toEntity() {
    return ProductListItem(
      id: id,
      name: name,
      status: status.toEntity(),
      productType: productType.toEntity(),
      featured: featured,
      coverImageUrl: coverImageUrl,
      priceFrom: priceFrom,
      priceTo: priceTo,
      ratingAverage: ratingAverage,
      reviewCount: reviewCount,
      salesCount: salesCount,
    );
  }
}

extension ProductResponseDtoMapper on ProductResponseDto {
  Product toEntity() {
    return Product(
      id: id,
      categoryId: categoryId,
      name: name,
      productType: productType.toEntity(),
      status: status.toEntity(),
      hasVariants: hasVariants,
      featured: featured,
      pricingUnitType: pricingUnitType.toEntity(),
      pricingUnitMin: pricingUnitMin,
      pricingUnitMax: pricingUnitMax,
      pricingUnitStep: pricingUnitStep,
      attributes: attributes.map((dto) => dto.toEntity()).toList(),
      categoryPath: categoryPath,
      description: description,
      pricingUnitLabel: pricingUnitLabel,
      weightG: weightG,
      heightCm: heightCm,
      widthCm: widthCm,
      depthCm: depthCm,
      salesCount: salesCount,
      averageRating: averageRating,
    );
  }
}

extension ProductAttributeValueResponseDtoMapper
    on ProductAttributeValueResponseDto {
  ProductAttributeValue toEntity() {
    return ProductAttributeValue(
      attributeName: attributeName,
      valueText: valueText,
    );
  }
}

extension ProductStatusDtoMapper on ProductStatusDto {
  ProductStatus toEntity() {
    return switch (this) {
      ProductStatusDto.draft => ProductStatus.draft,
      ProductStatusDto.published => ProductStatus.published,
      ProductStatusDto.paused => ProductStatus.paused,
      ProductStatusDto.archived => ProductStatus.archived,
    };
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

extension PricingUnitTypeDtoMapper on PricingUnitTypeDto {
  PricingUnitType toEntity() {
    return switch (this) {
      PricingUnitTypeDto.un => PricingUnitType.un,
      PricingUnitTypeDto.pct => PricingUnitType.pct,
      PricingUnitTypeDto.cx => PricingUnitType.cx,
      PricingUnitTypeDto.kit => PricingUnitType.kit,
      PricingUnitTypeDto.g => PricingUnitType.g,
      PricingUnitTypeDto.kg => PricingUnitType.kg,
      PricingUnitTypeDto.l => PricingUnitType.l,
      PricingUnitTypeDto.gal => PricingUnitType.gal,
      PricingUnitTypeDto.m => PricingUnitType.m,
      PricingUnitTypeDto.cm => PricingUnitType.cm,
      PricingUnitTypeDto.hora => PricingUnitType.hora,
      PricingUnitTypeDto.dia => PricingUnitType.dia,
      PricingUnitTypeDto.sessao => PricingUnitType.sessao,
    };
  }
}

extension ProductStatusEntityMapper on ProductStatus {
  String toApiValue() {
    return switch (this) {
      ProductStatus.draft => 'DRAFT',
      ProductStatus.published => 'PUBLISHED',
      ProductStatus.paused => 'PAUSED',
      ProductStatus.archived => 'ARCHIVED',
    };
  }
}
