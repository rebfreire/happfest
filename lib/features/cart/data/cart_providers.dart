import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happfest/app/di/providers.dart';
import 'package:happfest/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:happfest/features/cart/domain/repositories/cart_repository.dart';
import 'package:happfest/features/cart/domain/usecases/add_cart_item_usecase.dart';
import 'package:happfest/features/cart/domain/usecases/get_cart_usecase.dart';
import 'package:happfest/features/cart/domain/usecases/merge_cart_usecase.dart';
import 'package:happfest/features/cart/domain/usecases/remove_cart_item_usecase.dart';
import 'package:happfest/features/cart/domain/usecases/update_cart_item_usecase.dart';

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepositoryImpl(ref.watch(dioProvider));
});

final getCartUseCaseProvider = Provider<GetCartUseCase>((ref) {
  return GetCartUseCase(ref.watch(cartRepositoryProvider));
});

final addCartItemUseCaseProvider = Provider<AddCartItemUseCase>((ref) {
  return AddCartItemUseCase(ref.watch(cartRepositoryProvider));
});

final updateCartItemUseCaseProvider = Provider<UpdateCartItemUseCase>((ref) {
  return UpdateCartItemUseCase(ref.watch(cartRepositoryProvider));
});

final removeCartItemUseCaseProvider = Provider<RemoveCartItemUseCase>((ref) {
  return RemoveCartItemUseCase(ref.watch(cartRepositoryProvider));
});

final mergeCartUseCaseProvider = Provider<MergeCartUseCase>((ref) {
  return MergeCartUseCase(ref.watch(cartRepositoryProvider));
});
