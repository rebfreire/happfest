import 'package:happfest_core/core/error/result.dart';
import 'package:happfest_core/core/network/paged_response.dart';
import 'package:happfest_fornecedor/features/products/domain/entities/product.dart';
import 'package:happfest_fornecedor/features/products/domain/entities/product_list_item.dart';
import 'package:happfest_fornecedor/features/products/domain/entities/product_status.dart';

abstract interface class ProductsRepository {
  Future<Result<PagedResponse<ProductListItem>>> listMine({
    ProductStatus? status,
    int page = 0,
    int size = 20,
  });

  Future<Result<Product>> getById(String id);

  Future<Result<void>> setStatus(String id, ProductStatus status);

  Future<Result<void>> setFeatured(String id, {required bool featured});
}
