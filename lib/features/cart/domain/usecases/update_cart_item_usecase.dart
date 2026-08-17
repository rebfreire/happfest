import 'package:happfest/core/error/result.dart';
import 'package:happfest/features/cart/domain/entities/cart.dart';
import 'package:happfest/features/cart/domain/repositories/cart_repository.dart';

class UpdateCartItemUseCase {
  const UpdateCartItemUseCase(this._repository);

  final CartRepository _repository;

  Future<Result<Cart>> call({
    required String itemId,
    required int quantity,
    required double pricingUnitQuantity,
  }) {
    return _repository.updateItem(
      itemId: itemId,
      quantity: quantity,
      pricingUnitQuantity: pricingUnitQuantity,
    );
  }
}
