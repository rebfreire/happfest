import 'package:dio/dio.dart';
import 'package:happfest/core/error/failure.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/core/network/api_exception.dart';
import 'package:happfest/core/network/paged_response.dart';
import 'package:happfest/features/products/data/dto/product_search_response_dto.dart';
import 'package:happfest/features/products/data/mappers/product_summary_mapper.dart';
import 'package:happfest/features/products/domain/entities/product_summary.dart';
import 'package:happfest/features/products/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<Result<PagedResponse<ProductSummary>>> search({
    String? term,
    String? categoryPath,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/search/products',
        queryParameters: {
          if (term != null && term.isNotEmpty) 'termo': term,
          'categoryPath': ?categoryPath,
          'page': page,
          'size': size,
        },
      );
      final paged = PagedResponse.fromJson(
        response.data!,
        ProductSearchResponseDto.fromJson,
      );
      return Ok(
        PagedResponse<ProductSummary>(
          content: paged.content.map((dto) => dto.toEntity()).toList(),
          page: paged.page,
          totalPages: paged.totalPages,
          totalElements: paged.totalElements,
          isLast: paged.isLast,
        ),
      );
    } on DioException catch (exception) {
      final error = exception.error;
      final failure = error is ApiException
          ? error.failure
          : const UnknownFailure();
      return Err(failure);
    }
  }
}
