import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happfest/features/categories/data/repositories/category_repository_impl.dart';
import 'package:happfest/features/categories/domain/repositories/category_repository.dart';
import 'package:happfest/features/categories/domain/usecases/get_root_categories_usecase.dart';
import 'package:happfest_core/core/di/app_providers.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepositoryImpl(ref.watch(dioProvider));
});

final getRootCategoriesUseCaseProvider = Provider<GetRootCategoriesUseCase>((
  ref,
) {
  return GetRootCategoriesUseCase(ref.watch(categoryRepositoryProvider));
});
