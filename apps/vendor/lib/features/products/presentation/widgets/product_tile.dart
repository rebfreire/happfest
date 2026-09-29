import 'package:flutter/material.dart';
import 'package:happfest_design_system/design_system/components/app_badge.dart';
import 'package:happfest_design_system/design_system/components/app_list_tile.dart';
import 'package:happfest_fornecedor/features/products/domain/entities/product_list_item.dart';
import 'package:happfest_fornecedor/features/products/presentation/widgets/product_status_label.dart';
import 'package:intl/intl.dart';

class ProductTile extends StatelessWidget {
  const ProductTile({required this.product, super.key, this.onTap});

  final ProductListItem product;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.simpleCurrency(locale: 'pt_BR');
    final priceFrom = product.priceFrom;

    return AppListTile(
      title: product.name,
      subtitle: priceFrom == null
          ? null
          : 'A partir de ${currency.format(priceFrom)}',
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          AppBadge(label: productStatusLabel(product.status)),
          if (product.featured) ...[
            const SizedBox(height: 4),
            const Icon(Icons.star, size: 16),
          ],
        ],
      ),
      onTap: onTap,
    );
  }
}
