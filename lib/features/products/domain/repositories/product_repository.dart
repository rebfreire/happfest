import 'package:happfest/core/error/result.dart';
import 'package:happfest/core/network/paged_response.dart';
import 'package:happfest/features/products/domain/entities/product_summary.dart';

abstract interface class ProductRepository {
  Future<Result<PagedResponse<ProductSummary>>> search({
    String? term,
    String? categoryPath,
    int page = 0,
    int size = 20,
  });
}
