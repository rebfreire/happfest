import 'package:happfest/features/products/domain/entities/product_detail.dart';
import 'package:happfest_core/core/error/result.dart';

abstract interface class ProductDetailRepository {
  Future<Result<ProductDetail>> getById(String id);
}
