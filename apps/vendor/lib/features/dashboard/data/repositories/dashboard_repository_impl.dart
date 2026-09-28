import 'package:dio/dio.dart';
import 'package:happfest_core/core/error/failure.dart';
import 'package:happfest_core/core/error/result.dart';
import 'package:happfest_core/core/network/api_exception.dart';
import 'package:happfest_core/core/network/paged_response.dart';
import 'package:happfest_fornecedor/features/dashboard/data/dto/sub_order_response_dto.dart';
import 'package:happfest_fornecedor/features/dashboard/data/dto/supplier_me_response_dto.dart';
import 'package:happfest_fornecedor/features/dashboard/data/dto/supplier_metrics_response_dto.dart';
import 'package:happfest_fornecedor/features/dashboard/data/mappers/dashboard_mappers.dart';
import 'package:happfest_fornecedor/features/dashboard/domain/entities/sub_order_preview.dart';
import 'package:happfest_fornecedor/features/dashboard/domain/entities/supplier_metrics.dart';
import 'package:happfest_fornecedor/features/dashboard/domain/entities/supplier_profile.dart';
import 'package:happfest_fornecedor/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<Result<SupplierProfile>> getProfile() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/suppliers/me');
      final dto = SupplierMeResponseDto.fromJson(response.data!);
      return Ok(dto.toEntity());
    } on DioException catch (exception) {
      return Err(_mapError(exception));
    }
  }

  @override
  Future<Result<SupplierMetrics>> getMetrics() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/suppliers/me/metrics',
      );
      final dto = SupplierMetricsResponseDto.fromJson(response.data!);
      return Ok(dto.toEntity());
    } on DioException catch (exception) {
      return Err(_mapError(exception));
    }
  }

  @override
  Future<Result<PagedResponse<SubOrderPreview>>> getPendingOrders({
    int page = 0,
    int size = 5,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/sub-orders',
        queryParameters: {'status': 'PENDING', 'page': page, 'size': size},
      );
      final paged = PagedResponse.fromJson(
        response.data!,
        SubOrderResponseDto.fromJson,
      );
      return Ok(
        PagedResponse<SubOrderPreview>(
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

  Failure _mapError(DioException exception) {
    final error = exception.error;
    return error is ApiException ? error.failure : const UnknownFailure();
  }
}
