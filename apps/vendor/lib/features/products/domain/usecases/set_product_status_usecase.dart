import 'package:happfest_core/core/error/result.dart';
import 'package:happfest_fornecedor/features/products/domain/entities/product_status.dart';
import 'package:happfest_fornecedor/features/products/domain/repositories/products_repository.dart';

class SetProductStatusUseCase {
  const SetProductStatusUseCase(this._repository);

  final ProductsRepository _repository;

  Future<Result<void>> call(String id, ProductStatus status) {
    return _repository.setStatus(id, status);
  }
}
