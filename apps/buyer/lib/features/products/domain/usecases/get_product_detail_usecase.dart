import 'package:happfest/features/products/domain/entities/product_detail.dart';
import 'package:happfest/features/products/domain/repositories/product_detail_repository.dart';
import 'package:happfest_core/core/error/result.dart';

class GetProductDetailUseCase {
  const GetProductDetailUseCase(this._repository);

  final ProductDetailRepository _repository;

  Future<Result<ProductDetail>> call(String id) => _repository.getById(id);
}
