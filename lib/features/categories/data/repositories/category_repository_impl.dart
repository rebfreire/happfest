import 'package:dio/dio.dart';
import 'package:happfest/core/error/failure.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/core/network/api_exception.dart';
import 'package:happfest/features/categories/data/dto/category_response_dto.dart';
import 'package:happfest/features/categories/data/mappers/category_mapper.dart';
import 'package:happfest/features/categories/domain/entities/category.dart';
import 'package:happfest/features/categories/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  const CategoryRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<Result<List<Category>>> getRootCategories() {
    return _run(() => _dio.get<List<dynamic>>('/categories'));
  }

  @override
  Future<Result<List<Category>>> getChildren(String path) {
    return _run(
      () => _dio.get<List<dynamic>>('/categories/path/$path/children'),
    );
  }

  Future<Result<List<Category>>> _run(
    Future<Response<List<dynamic>>> Function() request,
  ) async {
    try {
      final response = await request();
      final categories = response.data!
          .cast<Map<String, dynamic>>()
          .map(CategoryResponseDto.fromJson)
          .map((dto) => dto.toEntity())
          .toList();
      return Ok(categories);
    } on DioException catch (exception) {
      final error = exception.error;
      final failure = error is ApiException
          ? error.failure
          : const UnknownFailure();
      return Err(failure);
    }
  }
}
