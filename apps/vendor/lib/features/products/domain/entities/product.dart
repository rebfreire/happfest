import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:happfest_fornecedor/features/products/domain/entities/pricing_unit_type.dart';
import 'package:happfest_fornecedor/features/products/domain/entities/product_attribute_value.dart';
import 'package:happfest_fornecedor/features/products/domain/entities/product_status.dart';
import 'package:happfest_fornecedor/features/products/domain/entities/product_type.dart';

part 'product.freezed.dart';

/// Detalhe completo de um produto (`ProductResponse` no
/// `docs/api/openapi.json`). CRUD (criar/editar) fica para uma iteração
/// seguinte — precisa de seleção de categoria, que é um fluxo próprio
/// (ver `docs/vendor-app-progress.md`).
@freezed
abstract class Product with _$Product {
  const factory Product({
    required String id,
    required String categoryId,
    required String name,
    required ProductType productType,
    required ProductStatus status,
    required bool hasVariants,
    required bool featured,
    required PricingUnitType pricingUnitType,
    required double pricingUnitMin,
    required double pricingUnitMax,
    required double pricingUnitStep,
    @Default([]) List<ProductAttributeValue> attributes,
    String? categoryPath,
    String? description,
    String? pricingUnitLabel,
    int? weightG,
    int? heightCm,
    int? widthCm,
    int? depthCm,
    int? salesCount,
    double? averageRating,
  }) = _Product;
}
