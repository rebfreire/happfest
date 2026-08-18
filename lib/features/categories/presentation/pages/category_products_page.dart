import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/core/network/paged_response.dart';
import 'package:happfest/design_system/components/app_scaffold.dart';
import 'package:happfest/features/products/data/product_providers.dart';
import 'package:happfest/features/products/domain/entities/product_summary.dart';
import 'package:happfest/features/products/presentation/widgets/product_results_grid.dart';

// AutoDisposeFutureProviderFamily não é exportado publicamente pelo
// flutter_riverpod, então o tipo não pode ser anotado explicitamente aqui.
// ignore: specify_nonobvious_property_types
final _categoryProductsProvider = FutureProvider.autoDispose
    .family<Result<PagedResponse<ProductSummary>>, String>((
      ref,
      categoryPath,
    ) {
      return ref.watch(searchProductsUseCaseProvider)(
        categoryPath: categoryPath,
      );
    });

class CategoryProductsPage extends ConsumerWidget {
  const CategoryProductsPage({
    required this.categoryPath,
    this.categoryName,
    super.key,
  });

  final String categoryPath;
  final String? categoryName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(_categoryProductsProvider(categoryPath));

    return AppScaffold(
      title: categoryName ?? categoryPath.split('.').last,
      body: ProductResultsGrid(
        productsAsync: productsAsync,
        onRetry: () => ref.invalidate(_categoryProductsProvider(categoryPath)),
        onTapProduct: (product) => context.push(
          '/products/${product.id}',
          extra: product.storeName,
        ),
      ),
    );
  }
}
