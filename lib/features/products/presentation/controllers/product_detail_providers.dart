import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/features/products/data/product_providers.dart';
import 'package:happfest/features/products/domain/entities/product_detail.dart';

// The generated FutureProviderFamily type isn't publicly exported by
// riverpod, so it can't be spelled out explicitly here.
// ignore: specify_nonobvious_property_types
final productDetailProvider =
    FutureProvider.family<Result<ProductDetail>, String>(
      (ref, id) => ref.watch(getProductDetailUseCaseProvider)(id),
    );
