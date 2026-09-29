import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happfest_core/core/error/failure.dart';
import 'package:happfest_core/core/error/result.dart';
import 'package:happfest_design_system/design_system/components/app_badge.dart';
import 'package:happfest_design_system/design_system/components/app_button.dart';
import 'package:happfest_design_system/design_system/components/app_chip.dart';
import 'package:happfest_design_system/design_system/feedback/app_error_state.dart';
import 'package:happfest_design_system/design_system/feedback/app_loading.dart';
import 'package:happfest_design_system/design_system/feedback/app_snackbar.dart';
import 'package:happfest_design_system/design_system/tokens/app_spacing.dart';
import 'package:happfest_fornecedor/features/products/data/products_providers.dart';
import 'package:happfest_fornecedor/features/products/domain/entities/product.dart';
import 'package:happfest_fornecedor/features/products/domain/entities/product_status.dart';
import 'package:happfest_fornecedor/features/products/presentation/controllers/products_providers.dart';
import 'package:happfest_fornecedor/features/products/presentation/widgets/product_status_label.dart';
import 'package:intl/intl.dart';

class ProductDetailPage extends ConsumerStatefulWidget {
  const ProductDetailPage({required this.productId, super.key});

  final String productId;

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  bool _isProcessing = false;

  Future<void> _runAction(Future<Result<void>> Function() action) async {
    setState(() => _isProcessing = true);
    final result = await action();
    if (!mounted) return;
    setState(() => _isProcessing = false);

    switch (result) {
      case Ok():
        ref
          ..invalidate(productDetailProvider(widget.productId))
          ..invalidate(productsListProvider);
      case Err(:final failure):
        if (mounted) AppSnackbar.error(context, failure.message);
    }
  }

  Future<void> _setStatus(ProductStatus status) {
    return _runAction(
      () => ref.read(setProductStatusUseCaseProvider)(
        widget.productId,
        status,
      ),
    );
  }

  Future<void> _toggleFeatured({required bool featured}) {
    return _runAction(
      () => ref.read(setProductFeaturedUseCaseProvider)(
        widget.productId,
        featured: featured,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider(widget.productId));

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhe do produto')),
      body: SafeArea(
        child: productAsync.when(
          loading: () => const AppLoading(),
          error: (error, stackTrace) => AppErrorState(
            failure: const UnknownFailure(),
            onRetry: () =>
                ref.invalidate(productDetailProvider(widget.productId)),
          ),
          data: (result) => switch (result) {
            Ok(:final value) => _ProductDetailBody(
              product: value,
              isProcessing: _isProcessing,
              onSetStatus: _setStatus,
              onToggleFeatured: _toggleFeatured,
            ),
            Err(:final failure) => AppErrorState(
              failure: failure,
              onRetry: () =>
                  ref.invalidate(productDetailProvider(widget.productId)),
            ),
          },
        ),
      ),
    );
  }
}

class _ProductDetailBody extends StatelessWidget {
  const _ProductDetailBody({
    required this.product,
    required this.isProcessing,
    required this.onSetStatus,
    required this.onToggleFeatured,
  });

  final Product product;
  final bool isProcessing;
  final void Function(ProductStatus status) onSetStatus;
  final void Function({required bool featured}) onToggleFeatured;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.simpleCurrency(locale: 'pt_BR');
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Text(product.name, style: theme.textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            AppBadge(label: productStatusLabel(product.status)),
            if (product.featured) ...[
              const SizedBox(width: AppSpacing.sm),
              const AppChip(label: 'Destaque', selected: true),
            ],
          ],
        ),
        if (product.categoryPath != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(product.categoryPath!, style: theme.textTheme.bodyMedium),
        ],
        const SizedBox(height: AppSpacing.lg),
        Text(_priceRange(product, currency), style: theme.textTheme.bodyLarge),
        if (product.description != null) ...[
          const SizedBox(height: AppSpacing.lg),
          Text('Descrição', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(product.description!),
        ],
        if (product.attributes.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          Text('Atributos', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final attribute in product.attributes)
                AppChip(
                  label: '${attribute.attributeName}: ${attribute.valueText}',
                ),
            ],
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        ..._actionsFor(product.status),
      ],
    );
  }

  List<Widget> _actionsFor(ProductStatus status) {
    final publishOrPause = switch (status) {
      ProductStatus.draft || ProductStatus.paused => AppButton.confirm(
        label: 'Publicar',
        onPressed: isProcessing
            ? null
            : () => onSetStatus(ProductStatus.published),
        isLoading: isProcessing,
        expanded: true,
      ),
      ProductStatus.published => AppButton.cancel(
        label: 'Pausar',
        onPressed: isProcessing
            ? null
            : () => onSetStatus(ProductStatus.paused),
      ),
      ProductStatus.archived => null,
    };

    final featuredToggle = status == ProductStatus.archived
        ? null
        : AppButton.cancel(
            label: product.featured
                ? 'Remover destaque'
                : 'Marcar como destaque',
            onPressed: isProcessing
                ? null
                : () => onToggleFeatured(featured: !product.featured),
          );

    return [
      ?publishOrPause,
      if (publishOrPause != null && featuredToggle != null)
        const SizedBox(height: AppSpacing.sm),
      ?featuredToggle,
    ];
  }
}

String _priceRange(Product product, NumberFormat currency) {
  final from = currency.format(product.pricingUnitMin);
  final to = currency.format(product.pricingUnitMax);
  final label = product.pricingUnitLabel;
  return 'Preço de $from a $to${label != null ? ' / $label' : ''}';
}
