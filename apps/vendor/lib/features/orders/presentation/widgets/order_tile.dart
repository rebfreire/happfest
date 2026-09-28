import 'package:flutter/material.dart';
import 'package:happfest_design_system/design_system/components/app_badge.dart';
import 'package:happfest_design_system/design_system/components/app_list_tile.dart';
import 'package:happfest_fornecedor/features/orders/domain/entities/sub_order.dart';
import 'package:happfest_fornecedor/features/orders/presentation/widgets/sub_order_status_label.dart';
import 'package:intl/intl.dart';

class OrderTile extends StatelessWidget {
  const OrderTile({required this.order, super.key, this.onTap});

  final SubOrder order;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.simpleCurrency(locale: 'pt_BR');
    final deliveryDate = order.deliveryDate;

    return AppListTile(
      title: 'Pedido #${order.id.substring(0, 8)}',
      subtitle: deliveryDate == null
          ? null
          : 'Entrega em ${DateFormat('dd/MM/yyyy').format(deliveryDate)}',
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(currency.format(order.supplierAmount)),
          const SizedBox(height: 4),
          AppBadge(label: subOrderStatusLabel(order.status)),
        ],
      ),
      onTap: onTap,
    );
  }
}
