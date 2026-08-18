import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happfest/app/di/providers.dart';
import 'package:happfest/features/categories/data/repositories/category_repository_impl.dart';
import 'package:happfest/features/categories/domain/repositories/category_repository.dart';
import 'package:happfest/features/categories/domain/usecases/get_category_children_usecase.dart';
import 'package:happfest/features/categories/domain/usecases/get_root_categories_usecase.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepositoryImpl(ref.watch(dioProvider));
});

final getRootCategoriesUseCaseProvider = Provider<GetRootCategoriesUseCase>((
  ref,
) {
  return GetRootCategoriesUseCase(ref.watch(categoryRepositoryProvider));
});

final getCategoryChildrenUseCaseProvider = Provider<GetCategoryChildrenUseCase>(
  (ref) {
    return GetCategoryChildrenUseCase(ref.watch(categoryRepositoryProvider));
  },
);
