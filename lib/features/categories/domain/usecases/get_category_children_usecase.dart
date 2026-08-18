import 'package:happfest/core/error/result.dart';
import 'package:happfest/features/categories/domain/entities/category.dart';
import 'package:happfest/features/categories/domain/repositories/category_repository.dart';

class GetCategoryChildrenUseCase {
  const GetCategoryChildrenUseCase(this._repository);

  final CategoryRepository _repository;

  Future<Result<List<Category>>> call(String path) =>
      _repository.getChildren(path);
}
