import 'package:flutter_test/flutter_test.dart';
import 'package:happfest/core/error/failure.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/features/cart/domain/entities/cart.dart';
import 'package:happfest/features/cart/domain/entities/cart_item.dart';
import 'package:happfest/features/cart/domain/repositories/cart_repository.dart';
import 'package:happfest/features/cart/domain/usecases/add_cart_item_usecase.dart';
import 'package:happfest/features/cart/domain/usecases/get_cart_usecase.dart';
import 'package:happfest/features/cart/domain/usecases/merge_cart_usecase.dart';
import 'package:happfest/features/cart/domain/usecases/remove_cart_item_usecase.dart';
import 'package:happfest/features/cart/domain/usecases/update_cart_item_usecase.dart';
import 'package:mocktail/mocktail.dart';

class _MockCartRepository extends Mock implements CartRepository {}

void main() {
  late _MockCartRepository repository;

  const cartItem = CartItem(
    id: 'item-1',
    productId: 'p1',
    productName: 'DJ para Casamentos',
    storeName: 'Fests',
    quantity: 1,
    pricingUnitQuantity: 1,
    unitPrice: 400,
    lineTotal: 400,
  );
  const cart = Cart(
    id: 'cart-1',
    items: [cartItem],
    totalItems: 1,
    subtotal: 400,
  );

  setUp(() {
    repository = _MockCartRepository();
  });

  test('GetCartUseCase returns the cart from the repository', () async {
    when(() => repository.getCart()).thenAnswer((_) async => const Ok(cart));

    final result = await GetCartUseCase(repository)();

    expect(result, const Ok(cart));
  });

  test('AddCartItemUseCase forwards the variant and quantities', () async {
    when(
      () => repository.addItem(
        productVariantId: any(named: 'productVariantId'),
        quantity: any(named: 'quantity'),
        pricingUnitQuantity: any(named: 'pricingUnitQuantity'),
      ),
    ).thenAnswer((_) async => const Ok(cart));

    final result = await AddCartItemUseCase(repository)(
      productVariantId: 'variant-1',
      pricingUnitQuantity: 1,
    );

    expect(result, const Ok(cart));
    verify(
      () => repository.addItem(
        productVariantId: 'variant-1',
        quantity: 1,
        pricingUnitQuantity: 1,
      ),
    ).called(1);
  });

  test('UpdateCartItemUseCase forwards the new quantities', () async {
    when(
      () => repository.updateItem(
        itemId: any(named: 'itemId'),
        quantity: any(named: 'quantity'),
        pricingUnitQuantity: any(named: 'pricingUnitQuantity'),
      ),
    ).thenAnswer((_) async => const Ok(cart));

    final result = await UpdateCartItemUseCase(repository)(
      itemId: 'item-1',
      quantity: 2,
      pricingUnitQuantity: 2,
    );

    expect(result, const Ok(cart));
  });

  test('RemoveCartItemUseCase propagates a failure', () async {
    when(
      () => repository.removeItem(any()),
    ).thenAnswer((_) async => const Err(NotFoundFailure()));

    final result = await RemoveCartItemUseCase(repository)('item-1');

    expect(result, isA<Err<Cart>>());
  });

  test(
    'MergeCartUseCase returns the merged cart from the repository',
    () async {
      when(
        () => repository.mergeAnonymousCart(),
      ).thenAnswer((_) async => const Ok(cart));

      final result = await MergeCartUseCase(repository)();

      expect(result, const Ok(cart));
      verify(() => repository.mergeAnonymousCart()).called(1);
    },
  );
}
