import 'package:happfest_core/core/error/result.dart';
import 'package:happfest_fornecedor/features/products/domain/repositories/products_repository.dart';

class SetProductFeaturedUseCase {
  const SetProductFeaturedUseCase(this._repository);

  final ProductsRepository _repository;

  Future<Result<void>> call(String id, {required bool featured}) {
    return _repository.setFeatured(id, featured: featured);
  }
}
