import 'package:dio/dio.dart';
import 'package:happfest_core/core/error/failure.dart';
import 'package:happfest_core/core/error/result.dart';
import 'package:happfest_core/core/network/api_exception.dart';
import 'package:happfest_core/core/network/paged_response.dart';
import 'package:happfest_fornecedor/features/orders/data/dto/sub_order_response_dto.dart';
import 'package:happfest_fornecedor/features/orders/data/mappers/sub_order_mapper.dart';
import 'package:happfest_fornecedor/features/orders/domain/entities/sub_order.dart';
import 'package:happfest_fornecedor/features/orders/domain/entities/sub_order_status.dart';
import 'package:happfest_fornecedor/features/orders/domain/repositories/orders_repository.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  const OrdersRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<Result<PagedResponse<SubOrder>>> list({
    SubOrderStatus? status,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/sub-orders',
        queryParameters: {
          if (status != null) 'status': status.toApiValue(),
          'page': page,
          'size': size,
        },
      );
      final paged = PagedResponse.fromJson(
        response.data!,
        SubOrderResponseDto.fromJson,
      );
      return Ok(
        PagedResponse<SubOrder>(
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
  Future<Result<SubOrder>> getById(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/sub-orders/$id',
      );
      return Ok(SubOrderResponseDto.fromJson(response.data!).toEntity());
    } on DioException catch (exception) {
      return Err(_mapError(exception));
    }
  }

  @override
  Future<Result<void>> accept(String id) async {
    try {
      await _dio.post<void>('/sub-orders/$id/accept');
      return const Ok(null);
    } on DioException catch (exception) {
      return Err(_mapError(exception));
    }
  }

  @override
  Future<Result<void>> reject(String id, {String? reason}) async {
    try {
      await _dio.post<void>(
        '/sub-orders/$id/reject',
        data: {if (reason != null && reason.isNotEmpty) 'reason': reason},
      );
      return const Ok(null);
    } on DioException catch (exception) {
      return Err(_mapError(exception));
    }
  }

  @override
  Future<Result<void>> deliver(String id) async {
    try {
      await _dio.post<void>('/sub-orders/$id/deliver');
      return const Ok(null);
    } on DioException catch (exception) {
      return Err(_mapError(exception));
    }
  }

  @override
  Future<Result<void>> cancel(String id, {String? reason}) async {
    try {
      await _dio.post<void>(
        '/sub-orders/$id/cancel/supplier',
        data: {if (reason != null && reason.isNotEmpty) 'reason': reason},
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
