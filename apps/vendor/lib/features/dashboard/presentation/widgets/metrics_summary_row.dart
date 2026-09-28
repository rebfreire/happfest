import 'package:flutter/material.dart';
import 'package:happfest_design_system/design_system/components/app_card.dart';
import 'package:happfest_design_system/design_system/tokens/app_spacing.dart';
import 'package:happfest_fornecedor/features/dashboard/domain/entities/supplier_metrics.dart';

class MetricsSummaryRow extends StatelessWidget {
  const MetricsSummaryRow({required this.metrics, super.key});

  final SupplierMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            label: 'Taxa de aceite',
            value: '${metrics.acceptanceRatePercent.toStringAsFixed(0)}%',
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _MetricCard(
            label: 'Avaliação',
            value: metrics.totalReviews == 0
                ? '—'
                : metrics.averageRating.toStringAsFixed(1),
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xxs),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
