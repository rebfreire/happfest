import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happfest/core/error/failure.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/core/network/paged_response.dart';
import 'package:happfest/design_system/feedback/app_empty_state.dart';
import 'package:happfest/design_system/feedback/app_error_state.dart';
import 'package:happfest/design_system/feedback/app_loading.dart';
import 'package:happfest/design_system/tokens/app_spacing.dart';
import 'package:happfest/features/home/presentation/widgets/product_summary_card.dart';
import 'package:happfest/features/products/domain/entities/product_summary.dart';

/// Grid paginado de produtos, compartilhado entre `HomePage` e as telas de
/// categoria — evita duplicar os estados de loading/erro/vazio.
class ProductResultsGrid extends StatelessWidget {
  const ProductResultsGrid({
    required this.productsAsync,
    required this.onTapProduct,
    required this.onRetry,
    super.key,
  });

  final AsyncValue<Result<PagedResponse<ProductSummary>>> productsAsync;
  final void Function(ProductSummary product) onTapProduct;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return productsAsync.when(
      loading: () => const AppLoading.skeleton(),
      error: (error, stackTrace) => AppErrorState(
        failure: const UnknownFailure(),
        onRetry: onRetry,
      ),
      data: (result) {
        return switch (result) {
          Ok(:final value) when value.content.isEmpty => const AppEmptyState(
            message: 'Nenhum produto encontrado.',
          ),
          Ok(:final value) => GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: 0.6,
            ),
            itemCount: value.content.length,
            itemBuilder: (context, index) {
              final product = value.content[index];
              return ProductSummaryCard(
                product: product,
                onTap: () => onTapProduct(product),
              );
            },
          ),
          Err(:final failure) => AppErrorState(
            failure: failure,
            onRetry: onRetry,
          ),
        };
      },
    );
  }
}
