import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happfest/core/error/failure.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/design_system/feedback/app_empty_state.dart';
import 'package:happfest/design_system/feedback/app_error_state.dart';
import 'package:happfest/design_system/feedback/app_loading.dart';
import 'package:happfest/design_system/tokens/app_spacing.dart';
import 'package:happfest/features/cart/presentation/controllers/cart_providers.dart';
import 'package:happfest/features/cart/presentation/widgets/cart_item_tile.dart';
import 'package:happfest/features/checkout/presentation/pages/checkout_page.dart';
import 'package:intl/intl.dart';

class CheckoutItensStep extends ConsumerWidget {
  const CheckoutItensStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(cartProvider);
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: r'R$');

    return cartAsync.when(
      loading: () => const AppLoading.skeleton(),
      error: (error, stackTrace) => AppErrorState(
        failure: const UnknownFailure(),
        onRetry: () => ref.invalidate(cartProvider),
      ),
      data: (result) => switch (result) {
        Ok(:final value) when value.items.isEmpty => const AppEmptyState(
          message: 'Seu carrinho está vazio.',
          icon: Icons.shopping_cart_outlined,
        ),
        Ok(:final value) => Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                itemCount: value.items.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) =>
                    CartItemTile(item: value.items[index]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subtotal',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    currency.format(value.subtotal),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            const CheckoutStepActions(canContinue: true),
          ],
        ),
        Err(:final failure) => AppErrorState(
          failure: failure,
          onRetry: () => ref.invalidate(cartProvider),
        ),
      },
    );
  }
}
