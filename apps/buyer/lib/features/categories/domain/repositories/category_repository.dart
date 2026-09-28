import 'package:happfest/features/categories/domain/entities/category.dart';
import 'package:happfest_core/core/error/result.dart';

abstract interface class CategoryRepository {
  Future<Result<List<Category>>> getRootCategories();
}
