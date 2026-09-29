import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:happfest_fornecedor/features/products/domain/entities/product_status.dart';
import 'package:happfest_fornecedor/features/products/domain/entities/product_type.dart';

part 'product_list_item.freezed.dart';

/// Item da listagem `/products/me` — subset de campos usados na lista,
/// sem os detalhes completos (categoria, dimensões, atributos etc.), que
/// só a tela de detalhe carrega via `Product`.
@freezed
abstract class ProductListItem with _$ProductListItem {
  const factory ProductListItem({
    required String id,
    required String name,
    required ProductStatus status,
    required ProductType productType,
    required bool featured,
    String? coverImageUrl,
    double? priceFrom,
    double? priceTo,
    double? ratingAverage,
    int? reviewCount,
    int? salesCount,
  }) = _ProductListItem;
}
