import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:happfest/core/error/failure.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/design_system/components/app_button.dart';
import 'package:happfest/design_system/feedback/app_dialog.dart';
import 'package:happfest/design_system/feedback/app_empty_state.dart';
import 'package:happfest/design_system/feedback/app_error_state.dart';
import 'package:happfest/design_system/feedback/app_loading.dart';
import 'package:happfest/design_system/feedback/app_snackbar.dart';
import 'package:happfest/design_system/tokens/app_spacing.dart';
import 'package:happfest/features/cart/data/cart_providers.dart';
import 'package:happfest/features/cart/domain/entities/cart.dart';
import 'package:happfest/features/cart/domain/entities/cart_item.dart';
import 'package:happfest/features/cart/presentation/controllers/cart_providers.dart';
import 'package:happfest/features/cart/presentation/widgets/cart_item_tile.dart';
import 'package:intl/intl.dart';

class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  String? _busyItemId;

  Future<void> _updateQuantity(CartItem item, int newQuantity) async {
    if (newQuantity < 1) return;
    setState(() => _busyItemId = item.id);
    final result = await ref
        .read(updateCartItemUseCaseProvider)
        .call(
          itemId: item.id,
          quantity: newQuantity,
          pricingUnitQuantity: item.pricingUnitQuantity,
        );
    if (!mounted) return;
    setState(() => _busyItemId = null);
    _handleResult(result);
  }

  Future<void> _remove(CartItem item) async {
    final confirmed = await AppDialog.destructive(
      context,
      title: 'Remover item',
      message: 'Remover "${item.productName}" do carrinho?',
    );
    if (!confirmed || !mounted) return;

    setState(() => _busyItemId = item.id);
    final result = await ref.read(removeCartItemUseCaseProvider).call(item.id);
    if (!mounted) return;
    setState(() => _busyItemId = null);
    _handleResult(result);
  }

  void _handleResult(Result<Cart> result) {
    switch (result) {
      case Ok():
        ref.invalidate(cartProvider);
      case Err(:final failure):
        AppSnackbar.error(context, failure.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartAsync = ref.watch(cartProvider);
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: r'R$');

    return Scaffold(
      appBar: AppBar(title: const Text('Carrinho')),
      body: cartAsync.when(
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
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.sm,
                  ),
                  itemCount: value.items.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = value.items[index];
                    return CartItemTile(
                      item: item,
                      isBusy: _busyItemId == item.id,
                      onIncrement: () =>
                          _updateQuantity(item, item.quantity + 1),
                      onDecrement: () =>
                          _updateQuantity(item, item.quantity - 1),
                      onRemove: () => _remove(item),
                    );
                  },
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      Row(
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
                      const SizedBox(height: AppSpacing.sm),
                      AppButton.confirm(
                        label: 'Finalizar compra',
                        expanded: true,
                        onPressed: () => context.push('/checkout'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Err(:final failure) => AppErrorState(
            failure: failure,
            onRetry: () => ref.invalidate(cartProvider),
          ),
        },
      ),
    );
  }
}
