import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:happfest/features/products/domain/entities/product_type.dart';

part 'product_summary.freezed.dart';

/// Versão enxuta do produto usada em listagens (Home, busca, categoria) —
/// vem de `ProductSearchResponse`, não de `ProductResponse` (detalhe).
@freezed
abstract class ProductSummary with _$ProductSummary {
  const factory ProductSummary({
    required String id,
    required String name,
    required String slug,
    required String storeName,
    required ProductType productType,
    String? coverImageUrl,
    double? minPrice,
  }) = _ProductSummary;
}
