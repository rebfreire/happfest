import 'package:happfest/core/error/result.dart';
import 'package:happfest/features/cart/domain/entities/cart.dart';
import 'package:happfest/features/cart/domain/repositories/cart_repository.dart';

class AddCartItemUseCase {
  const AddCartItemUseCase(this._repository);

  final CartRepository _repository;

  Future<Result<Cart>> call({
    required String productVariantId,
    required double pricingUnitQuantity,
    int quantity = 1,
  }) {
    return _repository.addItem(
      productVariantId: productVariantId,
      quantity: quantity,
      pricingUnitQuantity: pricingUnitQuantity,
    );
  }
}
