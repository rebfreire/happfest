import 'package:happfest/features/categories/domain/entities/category.dart';
import 'package:happfest/features/categories/domain/repositories/category_repository.dart';
import 'package:happfest_core/core/error/result.dart';

class GetRootCategoriesUseCase {
  const GetRootCategoriesUseCase(this._repository);

  final CategoryRepository _repository;

  Future<Result<List<Category>>> call() => _repository.getRootCategories();
}
