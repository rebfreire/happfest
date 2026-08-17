import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:happfest/features/products/domain/entities/product_type.dart';

part 'product_detail.freezed.dart';

/// Combina `ProductResponse` + `ProductImageResponse` (dois endpoints) numa
/// única entidade para a tela de detalhe. `ProductResponse` não traz o nome
/// da loja — vem via `storeName` (passado pela navegação a partir do card
/// da Home, que já tem esse dado, evitando uma chamada extra).
@freezed
abstract class ProductDetail with _$ProductDetail {
  const factory ProductDetail({
    required String id,
    required String name,
    required String storeId,
    required ProductType productType,
    @Default([]) List<String> imageUrls,
    String? storeName,
    String? description,
    String? pricingUnitLabel,
    double? pricingUnitMin,
    double? pricingUnitMax,
    @Default(0) double averageRating,
  }) = _ProductDetail;
}
