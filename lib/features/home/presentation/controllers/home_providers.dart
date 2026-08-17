import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/core/network/paged_response.dart';
import 'package:happfest/features/categories/data/category_providers.dart';
import 'package:happfest/features/categories/domain/entities/category.dart';
import 'package:happfest/features/products/data/product_providers.dart';
import 'package:happfest/features/products/domain/entities/product_summary.dart';

final rootCategoriesProvider = FutureProvider<Result<List<Category>>>((ref) {
  return ref.watch(getRootCategoriesUseCaseProvider)();
});

class HomeFilters {
  const HomeFilters({this.term = '', this.categoryPath});

  final String term;
  final String? categoryPath;
}

final homeFiltersProvider =
    NotifierProvider<HomeFiltersController, HomeFilters>(
      HomeFiltersController.new,
    );

class HomeFiltersController extends Notifier<HomeFilters> {
  @override
  HomeFilters build() => const HomeFilters();

  void setTerm(String term) => state = HomeFilters(
    term: term,
    categoryPath: state.categoryPath,
  );

  void toggleCategory(String path) {
    state = HomeFilters(
      term: state.term,
      categoryPath: state.categoryPath == path ? null : path,
    );
  }
}

final homeProductsProvider =
    FutureProvider<Result<PagedResponse<ProductSummary>>>((ref) {
      final filters = ref.watch(homeFiltersProvider);
      return ref.watch(searchProductsUseCaseProvider)(
        term: filters.term.isEmpty ? null : filters.term,
        categoryPath: filters.categoryPath,
      );
    });
