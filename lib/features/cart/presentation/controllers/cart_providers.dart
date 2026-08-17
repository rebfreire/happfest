import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/features/cart/data/cart_providers.dart';
import 'package:happfest/features/cart/domain/entities/cart.dart';

final cartProvider = FutureProvider<Result<Cart>>((ref) {
  return ref.watch(getCartUseCaseProvider)();
});
