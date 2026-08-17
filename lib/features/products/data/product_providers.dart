import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happfest/app/di/providers.dart';
import 'package:happfest/features/products/data/repositories/product_detail_repository_impl.dart';
import 'package:happfest/features/products/data/repositories/product_repository_impl.dart';
import 'package:happfest/features/products/domain/repositories/product_detail_repository.dart';
import 'package:happfest/features/products/domain/repositories/product_repository.dart';
import 'package:happfest/features/products/domain/usecases/get_product_detail_usecase.dart';
import 'package:happfest/features/products/domain/usecases/search_products_usecase.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(ref.watch(dioProvider));
});

final searchProductsUseCaseProvider = Provider<SearchProductsUseCase>((ref) {
  return SearchProductsUseCase(ref.watch(productRepositoryProvider));
});

final productDetailRepositoryProvider = Provider<ProductDetailRepository>((
  ref,
) {
  return ProductDetailRepositoryImpl(ref.watch(dioProvider));
});

final getProductDetailUseCaseProvider = Provider<GetProductDetailUseCase>((
  ref,
) {
  return GetProductDetailUseCase(ref.watch(productDetailRepositoryProvider));
});
