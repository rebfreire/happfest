import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happfest_core/core/di/app_providers.dart';
import 'package:happfest_fornecedor/features/products/data/repositories/products_repository_impl.dart';
import 'package:happfest_fornecedor/features/products/domain/repositories/products_repository.dart';
import 'package:happfest_fornecedor/features/products/domain/usecases/get_product_detail_usecase.dart';
import 'package:happfest_fornecedor/features/products/domain/usecases/list_my_products_usecase.dart';
import 'package:happfest_fornecedor/features/products/domain/usecases/set_product_featured_usecase.dart';
import 'package:happfest_fornecedor/features/products/domain/usecases/set_product_status_usecase.dart';

final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  return ProductsRepositoryImpl(ref.watch(dioProvider));
});

final listMyProductsUseCaseProvider = Provider<ListMyProductsUseCase>(
  (ref) => ListMyProductsUseCase(ref.watch(productsRepositoryProvider)),
);

final getProductDetailUseCaseProvider = Provider<GetProductDetailUseCase>(
  (ref) => GetProductDetailUseCase(ref.watch(productsRepositoryProvider)),
);

final setProductStatusUseCaseProvider = Provider<SetProductStatusUseCase>(
  (ref) => SetProductStatusUseCase(ref.watch(productsRepositoryProvider)),
);

final setProductFeaturedUseCaseProvider = Provider<SetProductFeaturedUseCase>(
  (ref) => SetProductFeaturedUseCase(ref.watch(productsRepositoryProvider)),
);
