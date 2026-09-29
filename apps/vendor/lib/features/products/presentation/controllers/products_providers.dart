import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happfest_core/core/error/result.dart';
import 'package:happfest_core/core/network/paged_response.dart';
import 'package:happfest_fornecedor/features/products/data/products_providers.dart';
import 'package:happfest_fornecedor/features/products/domain/entities/product.dart';
import 'package:happfest_fornecedor/features/products/domain/entities/product_list_item.dart';
import 'package:happfest_fornecedor/features/products/domain/entities/product_status.dart';

final productStatusFilterProvider =
    NotifierProvider<ProductStatusFilterController, ProductStatus?>(
      ProductStatusFilterController.new,
    );

class ProductStatusFilterController extends Notifier<ProductStatus?> {
  @override
  ProductStatus? build() => null;

  // A setter here reads oddly at the call site (`.notifier.status = x`)
  // ignore: use_setters_to_change_properties
  void setStatus(ProductStatus? status) => state = status;
}

final productsListProvider =
    FutureProvider<Result<PagedResponse<ProductListItem>>>((ref) {
      final status = ref.watch(productStatusFilterProvider);
      return ref.watch(listMyProductsUseCaseProvider)(status: status);
    });

// FutureProviderFamily isn't part of flutter_riverpod's public export surface.
// ignore: specify_nonobvious_property_types
final productDetailProvider = FutureProvider.family<Result<Product>, String>((
  ref,
  id,
) {
  return ref.watch(getProductDetailUseCaseProvider)(id);
});
