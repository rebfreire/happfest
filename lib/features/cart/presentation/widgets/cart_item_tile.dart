import 'package:flutter/material.dart';
import 'package:happfest/design_system/tokens/app_spacing.dart';
import 'package:happfest/features/cart/domain/entities/cart_item.dart';
import 'package:intl/intl.dart';

class CartItemTile extends StatelessWidget {
  const CartItemTile({
    required this.item,
    super.key,
    this.isBusy = false,
    this.onIncrement,
    this.onDecrement,
    this.onRemove,
  });

  final CartItem item;
  final bool isBusy;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: r'R$');

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  item.storeName,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (item.preferredDate != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _scheduleLabel(item.preferredDate!, item.preferredTime),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: AppSpacing.xs),
                Text(
                  currency.format(item.lineTotal),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: isBusy ? null : onRemove,
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: isBusy ? null : onDecrement,
                  ),
                  SizedBox(
                    width: 24,
                    child: Text(
                      '${item.quantity}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: isBusy ? null : onIncrement,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _scheduleLabel(String date, String? time) {
    final parsed = DateTime.tryParse(date);
    final formattedDate = parsed != null
        ? DateFormat('dd/MM/yyyy').format(parsed)
        : date;
    if (time == null || time.isEmpty) return formattedDate;
    return '$formattedDate às ${time.substring(0, 5)}';
  }
}
