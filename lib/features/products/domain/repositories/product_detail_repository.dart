import 'package:happfest/core/error/result.dart';
import 'package:happfest/features/products/domain/entities/product_detail.dart';

abstract interface class ProductDetailRepository {
  Future<Result<ProductDetail>> getById(String id);
}
