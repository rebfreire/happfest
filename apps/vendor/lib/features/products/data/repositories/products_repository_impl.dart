import 'package:dio/dio.dart';
import 'package:happfest_core/core/error/failure.dart';
import 'package:happfest_core/core/error/result.dart';
import 'package:happfest_core/core/network/api_exception.dart';
import 'package:happfest_core/core/network/paged_response.dart';
import 'package:happfest_fornecedor/features/products/data/dto/product_list_item_response_dto.dart';
import 'package:happfest_fornecedor/features/products/data/dto/product_response_dto.dart';
import 'package:happfest_fornecedor/features/products/data/mappers/product_mapper.dart';
import 'package:happfest_fornecedor/features/products/domain/entities/product.dart';
import 'package:happfest_fornecedor/features/products/domain/entities/product_list_item.dart';
import 'package:happfest_fornecedor/features/products/domain/entities/product_status.dart';
import 'package:happfest_fornecedor/features/products/domain/repositories/products_repository.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  const ProductsRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<Result<PagedResponse<ProductListItem>>> listMine({
    ProductStatus? status,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/products/me',
        queryParameters: {
          if (status != null) 'status': status.toApiValue(),
          'page': page,
          'size': size,
        },
      );
      final paged = PagedResponse.fromJson(
        response.data!,
        ProductListItemResponseDto.fromJson,
      );
      return Ok(
        PagedResponse<ProductListItem>(
          content: paged.content.map((dto) => dto.toEntity()).toList(),
          page: paged.page,
          totalPages: paged.totalPages,
          totalElements: paged.totalElements,
          isLast: paged.isLast,
        ),
      );
    } on DioException catch (exception) {
      return Err(_mapError(exception));
    }
  }

  @override
  Future<Result<Product>> getById(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/products/$id');
      return Ok(ProductResponseDto.fromJson(response.data!).toEntity());
    } on DioException catch (exception) {
      return Err(_mapError(exception));
    }
  }

  @override
  Future<Result<void>> setStatus(String id, ProductStatus status) async {
    try {
      await _dio.patch<void>(
        '/products/$id/status',
        data: {'status': status.toApiValue()},
      );
      return const Ok(null);
    } on DioException catch (exception) {
      return Err(_mapError(exception));
    }
  }

  @override
  Future<Result<void>> setFeatured(String id, {required bool featured}) async {
    try {
      await _dio.patch<void>(
        '/products/$id/featured',
        data: {'featured': featured},
      );
      return const Ok(null);
    } on DioException catch (exception) {
      return Err(_mapError(exception));
    }
  }

  Failure _mapError(DioException exception) {
    final error = exception.error;
    return error is ApiException ? error.failure : const UnknownFailure();
  }
}
