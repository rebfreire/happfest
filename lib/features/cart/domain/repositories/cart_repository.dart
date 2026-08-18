import 'package:happfest/core/error/result.dart';
import 'package:happfest/features/cart/domain/entities/cart.dart';

abstract interface class CartRepository {
  Future<Result<Cart>> getCart();

  Future<Result<Cart>> addItem({
    required String productVariantId,
    required int quantity,
    required double pricingUnitQuantity,
  });

  Future<Result<Cart>> updateItem({
    required String itemId,
    required int quantity,
    required double pricingUnitQuantity,
  });

  Future<Result<Cart>> removeItem(String itemId);

  /// Associa o carrinho anônimo (identificado pelo `X-Cart-Session-Id`
  /// atual) ao usuário recém-logado. Chamado uma vez, logo após um login
  /// bem-sucedido — ver `MergeCartUseCase`.
  Future<Result<Cart>> mergeAnonymousCart();
}
