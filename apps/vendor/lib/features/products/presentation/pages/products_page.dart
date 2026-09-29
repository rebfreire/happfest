import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:happfest_core/core/error/failure.dart';
import 'package:happfest_core/core/error/result.dart';
import 'package:happfest_design_system/design_system/components/app_chip.dart';
import 'package:happfest_design_system/design_system/feedback/app_empty_state.dart';
import 'package:happfest_design_system/design_system/feedback/app_error_state.dart';
import 'package:happfest_design_system/design_system/feedback/app_loading.dart';
import 'package:happfest_design_system/design_system/tokens/app_spacing.dart';
import 'package:happfest_fornecedor/features/products/domain/entities/product_status.dart';
import 'package:happfest_fornecedor/features/products/presentation/controllers/products_providers.dart';
import 'package:happfest_fornecedor/features/products/presentation/widgets/product_status_label.dart';
import 'package:happfest_fornecedor/features/products/presentation/widgets/product_tile.dart';

const List<ProductStatus?> _filterableStatuses = [
  null,
  ProductStatus.draft,
  ProductStatus.published,
  ProductStatus.paused,
  ProductStatus.archived,
];

class ProductsPage extends ConsumerWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Produtos')),
      body: const SafeArea(
        child: Column(
          children: [
            SizedBox(height: AppSpacing.sm),
            _StatusFilterChips(),
            SizedBox(height: AppSpacing.sm),
            Expanded(child: _ProductsList()),
          ],
        ),
      ),
    );
  }
}

class _StatusFilterChips extends ConsumerWidget {
  const _StatusFilterChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(productStatusFilterProvider);

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: _filterableStatuses.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final status = _filterableStatuses[index];
          return AppChip(
            label: status == null ? 'Todos' : productStatusLabel(status),
            selected: selected == status,
            onSelected: (_) => ref
                .read(productStatusFilterProvider.notifier)
                .setStatus(status),
          );
        },
      ),
    );
  }
}

class _ProductsList extends ConsumerWidget {
  const _ProductsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsListProvider);

    return productsAsync.when(
      loading: () => const AppLoading.skeleton(),
      error: (error, stackTrace) => AppErrorState(
        failure: const UnknownFailure(),
        onRetry: () => ref.invalidate(productsListProvider),
      ),
      data: (result) => switch (result) {
        Ok(:final value) when value.content.isEmpty => const AppEmptyState(
          message: 'Nenhum produto encontrado.',
        ),
        Ok(:final value) => ListView.builder(
          itemCount: value.content.length,
          itemBuilder: (context, index) {
            final product = value.content[index];
            return ProductTile(
              product: product,
              onTap: () => context.push('/products/${product.id}'),
            );
          },
        ),
        Err(:final failure) => AppErrorState(
          failure: failure,
          onRetry: () => ref.invalidate(productsListProvider),
        ),
      },
    );
  }
}
