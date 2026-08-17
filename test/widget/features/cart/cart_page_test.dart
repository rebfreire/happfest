import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/design_system/theme/app_theme.dart';
import 'package:happfest/features/cart/data/cart_providers.dart';
import 'package:happfest/features/cart/domain/entities/cart.dart';
import 'package:happfest/features/cart/domain/entities/cart_item.dart';
import 'package:happfest/features/cart/domain/repositories/cart_repository.dart';
import 'package:happfest/features/cart/domain/usecases/add_cart_item_usecase.dart';
import 'package:happfest/features/cart/domain/usecases/get_cart_usecase.dart';
import 'package:happfest/features/cart/domain/usecases/remove_cart_item_usecase.dart';
import 'package:happfest/features/cart/domain/usecases/update_cart_item_usecase.dart';
import 'package:happfest/features/cart/presentation/pages/cart_page.dart';
import 'package:happfest/l10n/generated/app_localizations.dart';

class _FakeCartRepository implements CartRepository {
  _FakeCartRepository(this.cart);

  Cart cart;

  @override
  Future<Result<Cart>> getCart() async => Ok(cart);

  @override
  Future<Result<Cart>> addItem({
    required String productVariantId,
    required int quantity,
    required double pricingUnitQuantity,
  }) async => Ok(cart);

  @override
  Future<Result<Cart>> updateItem({
    required String itemId,
    required int quantity,
    required double pricingUnitQuantity,
  }) async => Ok(cart);

  @override
  Future<Result<Cart>> removeItem(String itemId) async {
    cart = cart.copyWith(
      items: cart.items.where((item) => item.id != itemId).toList(),
    );
    return Ok(cart);
  }
}

Widget _wrap(Cart cart) {
  final repository = _FakeCartRepository(cart);
  return ProviderScope(
    overrides: [
      getCartUseCaseProvider.overrideWithValue(GetCartUseCase(repository)),
      addCartItemUseCaseProvider.overrideWithValue(
        AddCartItemUseCase(repository),
      ),
      updateCartItemUseCaseProvider.overrideWithValue(
        UpdateCartItemUseCase(repository),
      ),
      removeCartItemUseCaseProvider.overrideWithValue(
        RemoveCartItemUseCase(repository),
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const CartPage(),
    ),
  );
}

void main() {
  testWidgets('shows cart items and the subtotal', (tester) async {
    const cart = Cart(
      id: 'cart-1',
      items: [
        CartItem(
          id: 'item-1',
          productId: 'p1',
          productName: 'DJ para Casamentos',
          storeName: 'Fests',
          quantity: 1,
          pricingUnitQuantity: 1,
          unitPrice: 400,
          lineTotal: 400,
        ),
      ],
      totalItems: 1,
      subtotal: 400,
    );
    await tester.pumpWidget(_wrap(cart));
    await tester.pumpAndSettle();

    expect(find.text('DJ para Casamentos'), findsOneWidget);
    expect(find.text('Fests'), findsOneWidget);
    expect(find.text('Subtotal'), findsOneWidget);
  });

  testWidgets('shows an empty state when the cart has no items', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const Cart(id: 'cart-1')));
    await tester.pumpAndSettle();

    expect(find.text('Seu carrinho está vazio.'), findsOneWidget);
  });
}
