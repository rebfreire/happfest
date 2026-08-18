import 'package:happfest/core/error/result.dart';
import 'package:happfest/features/cart/domain/entities/cart.dart';
import 'package:happfest/features/cart/domain/repositories/cart_repository.dart';

class MergeCartUseCase {
  const MergeCartUseCase(this._repository);

  final CartRepository _repository;

  Future<Result<Cart>> call() => _repository.mergeAnonymousCart();
}
