import 'package:dio/dio.dart';
import 'package:happfest/core/error/failure.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/core/network/api_exception.dart';
import 'package:happfest/features/products/data/dto/product_image_response_dto.dart';
import 'package:happfest/features/products/data/dto/product_response_dto.dart';
import 'package:happfest/features/products/data/dto/product_variant_response_dto.dart';
import 'package:happfest/features/products/data/mappers/product_detail_mapper.dart';
import 'package:happfest/features/products/domain/entities/product_detail.dart';
import 'package:happfest/features/products/domain/repositories/product_detail_repository.dart';

class ProductDetailRepositoryImpl implements ProductDetailRepository {
  const ProductDetailRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<Result<ProductDetail>> getById(String id) async {
    try {
      final results = await Future.wait([
        _dio.get<Map<String, dynamic>>('/products/$id'),
        _dio.get<List<dynamic>>('/products/$id/images'),
        _dio.get<List<dynamic>>('/products/$id/variants'),
      ]);

      final product = ProductResponseDto.fromJson(
        results[0].data! as Map<String, dynamic>,
      );
      final images = (results[1].data! as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(ProductImageResponseDto.fromJson)
          .toList();
      final variants = (results[2].data! as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(ProductVariantResponseDto.fromJson)
          .toList();

      return Ok(product.toDetailEntity(images, variants));
    } on DioException catch (exception) {
      final error = exception.error;
      final failure = error is ApiException
          ? error.failure
          : const UnknownFailure();
      return Err(failure);
    }
  }
}
