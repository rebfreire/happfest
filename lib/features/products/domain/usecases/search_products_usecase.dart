import 'package:happfest/core/error/result.dart';
import 'package:happfest/core/network/paged_response.dart';
import 'package:happfest/features/products/domain/entities/product_summary.dart';
import 'package:happfest/features/products/domain/repositories/product_repository.dart';

class SearchProductsUseCase {
  const SearchProductsUseCase(this._repository);

  final ProductRepository _repository;

  Future<Result<PagedResponse<ProductSummary>>> call({
    String? term,
    String? categoryPath,
    int page = 0,
    int size = 20,
  }) {
    return _repository.search(
      term: term,
      categoryPath: categoryPath,
      page: page,
      size: size,
    );
  }
}
