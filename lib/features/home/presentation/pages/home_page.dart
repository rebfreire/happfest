import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:happfest/core/error/failure.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/design_system/components/app_chip.dart';
import 'package:happfest/design_system/components/app_form_fields.dart';
import 'package:happfest/design_system/feedback/app_empty_state.dart';
import 'package:happfest/design_system/feedback/app_error_state.dart';
import 'package:happfest/design_system/feedback/app_loading.dart';
import 'package:happfest/design_system/tokens/app_spacing.dart';
import 'package:happfest/features/home/presentation/controllers/home_providers.dart';
import 'package:happfest/features/home/presentation/widgets/product_summary_card.dart';
import 'package:happfest/l10n/generated/app_localizations.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: SvgPicture.asset(
          'assets/images/happ_logo.svg',
          height: 36,
          semanticsLabel: l10n.appName,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            tooltip: 'Carrinho',
            onPressed: () => context.push('/cart'),
          ),
          if (kDebugMode)
            IconButton(
              icon: const Icon(Icons.palette_outlined),
              tooltip: 'Design System',
              onPressed: () => context.push('/dev/design-system'),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: AppSearchField(
                hint: l10n.searchPlaceholder,
                onSubmitted: (value) =>
                    ref.read(homeFiltersProvider.notifier).setTerm(value),
              ),
            ),
            const _CategoryChips(),
            const SizedBox(height: AppSpacing.sm),
            const Expanded(child: _ProductGrid()),
          ],
        ),
      ),
    );
  }
}

class _CategoryChips extends ConsumerWidget {
  const _CategoryChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(rootCategoriesProvider);
    final selected = ref.watch(homeFiltersProvider).categoryPath;

    return SizedBox(
      height: 40,
      child: switch (categoriesAsync) {
        AsyncData(value: Err()) || AsyncError() => const SizedBox.shrink(),
        AsyncData(value: Ok(value: final categories)) when categories.isEmpty =>
          const SizedBox.shrink(),
        AsyncData(value: Ok(value: final categories)) => ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          itemCount: categories.length,
          separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = selected == category.path;
            return AppChip(
              label: category.name,
              selected: isSelected,
              onSelected: (_) => ref
                  .read(homeFiltersProvider.notifier)
                  .toggleCategory(category.path),
            );
          },
        ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

class _ProductGrid extends ConsumerWidget {
  const _ProductGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(homeProductsProvider);

    return productsAsync.when(
      loading: () => const AppLoading.skeleton(),
      error: (error, stackTrace) => AppErrorState(
        failure: const UnknownFailure(),
        onRetry: () => ref.invalidate(homeProductsProvider),
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
                onTap: () => context.push(
                  '/products/${product.id}',
                  extra: product.storeName,
                ),
              );
            },
          ),
          Err(:final failure) => AppErrorState(
            failure: failure,
            onRetry: () => ref.invalidate(homeProductsProvider),
          ),
        };
      },
    );
  }
}
