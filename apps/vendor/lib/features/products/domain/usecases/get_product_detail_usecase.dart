import 'package:happfest_core/core/error/result.dart';
import 'package:happfest_fornecedor/features/products/domain/entities/product.dart';
import 'package:happfest_fornecedor/features/products/domain/repositories/products_repository.dart';

class GetProductDetailUseCase {
  const GetProductDetailUseCase(this._repository);

  final ProductsRepository _repository;

  Future<Result<Product>> call(String id) => _repository.getById(id);
}
