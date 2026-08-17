import 'package:happfest/core/error/result.dart';
import 'package:happfest/features/categories/domain/entities/category.dart';

abstract interface class CategoryRepository {
  Future<Result<List<Category>>> getRootCategories();
}
