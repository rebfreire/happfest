import 'package:happfest_core/core/error/result.dart';
import 'package:happfest_core/core/network/paged_response.dart';
import 'package:happfest_fornecedor/features/products/domain/entities/product_list_item.dart';
import 'package:happfest_fornecedor/features/products/domain/entities/product_status.dart';
import 'package:happfest_fornecedor/features/products/domain/repositories/products_repository.dart';

class ListMyProductsUseCase {
  const ListMyProductsUseCase(this._repository);

  final ProductsRepository _repository;

  Future<Result<PagedResponse<ProductListItem>>> call({
    ProductStatus? status,
    int page = 0,
    int size = 20,
  }) {
    return _repository.listMine(status: status, page: page, size: size);
  }
}
