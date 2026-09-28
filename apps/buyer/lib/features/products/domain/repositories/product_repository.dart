import 'package:happfest/features/products/domain/entities/product_summary.dart';
import 'package:happfest_core/core/error/result.dart';
import 'package:happfest_core/core/network/paged_response.dart';

abstract interface class ProductRepository {
  Future<Result<PagedResponse<ProductSummary>>> search({
    String? term,
    String? categoryPath,
    int page = 0,
    int size = 20,
  });
}
