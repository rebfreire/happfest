import 'package:flutter/material.dart';
import 'package:happfest/design_system/components/app_badge.dart';
import 'package:happfest/design_system/components/app_card.dart';
import 'package:happfest/design_system/tokens/app_radius.dart';
import 'package:happfest/design_system/tokens/app_spacing.dart';
import 'package:happfest/features/products/domain/entities/product_summary.dart';
import 'package:happfest/features/products/domain/entities/product_type.dart';
import 'package:intl/intl.dart';

class ProductSummaryCard extends StatelessWidget {
  const ProductSummaryCard({required this.product, super.key, this.onTap});

  final ProductSummary product;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: r'R$');

    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.lg),
              ),
              child: _CoverImage(url: product.coverImageUrl),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  product.storeName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.minPrice != null
                          ? currency.format(product.minPrice)
                          : '—',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    AppBadge(
                      label: product.productType == ProductType.service
                          ? 'SERVIÇO'
                          : 'PRODUTO',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CoverImage extends StatelessWidget {
  const _CoverImage({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Center(child: Icon(Icons.image_outlined)),
      );
    }
    return Image.network(
      url!,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Center(child: Icon(Icons.image_outlined)),
      ),
    );
  }
}
