import 'package:dio/dio.dart';
import 'package:happfest/core/error/failure.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/core/network/api_exception.dart';
import 'package:happfest/core/network/paged_response.dart';
import 'package:happfest/features/account/data/dto/customer_address_request_dto.dart';
import 'package:happfest/features/account/data/dto/customer_address_response_dto.dart';
import 'package:happfest/features/account/data/dto/customer_context_response_dto.dart';
import 'package:happfest/features/account/data/dto/order_detail_response_dto.dart';
import 'package:happfest/features/account/data/dto/order_summary_response_dto.dart';
import 'package:happfest/features/account/data/mappers/account_mapper.dart';
import 'package:happfest/features/account/domain/entities/customer_account.dart';
import 'package:happfest/features/account/domain/entities/customer_address.dart';
import 'package:happfest/features/account/domain/entities/order_detail.dart';
import 'package:happfest/features/account/domain/entities/order_summary.dart';
import 'package:happfest/features/account/domain/repositories/account_repository.dart';

class AccountRepositoryImpl implements AccountRepository {
  const AccountRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<Result<CustomerAccount>> getContext() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/customers/me/context',
      );
      final dto = CustomerContextResponseDto.fromJson(response.data!);
      return Ok(dto.toEntity());
    } on DioException catch (exception) {
      return Err(_failureOf(exception));
    }
  }

  @override
  Future<Result<List<CustomerAddress>>> getAddresses() async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/customers/me/addresses',
      );
      final addresses = response.data!
          .cast<Map<String, dynamic>>()
          .map(CustomerAddressResponseDto.fromJson)
          .map((dto) => dto.toEntity())
          .toList();
      return Ok(addresses);
    } on DioException catch (exception) {
      return Err(_failureOf(exception));
    }
  }

  @override
  Future<Result<PagedResponse<OrderSummary>>> getOrders({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/orders',
        queryParameters: {'page': page, 'size': size},
      );
      final paged = PagedResponse.fromJson(
        response.data!,
        OrderSummaryResponseDto.fromJson,
      );
      return Ok(
        PagedResponse<OrderSummary>(
          content: paged.content.map((dto) => dto.toEntity()).toList(),
          page: paged.page,
          totalPages: paged.totalPages,
          totalElements: paged.totalElements,
          isLast: paged.isLast,
        ),
      );
    } on DioException catch (exception) {
      return Err(_failureOf(exception));
    }
  }

  @override
  Future<Result<CustomerAddress>> createAddress({
    required String label,
    required String street,
    required String number,
    required String neighborhood,
    required int cityCodigoIbge,
    required int stateCodigoUf,
    required String zipCode,
    String? complement,
  }) async {
    try {
      final request = CustomerAddressRequestDto(
        label: label,
        street: street,
        number: number,
        complement: complement,
        neighborhood: neighborhood,
        cityCodigoIbge: cityCodigoIbge,
        stateCodigoUf: stateCodigoUf,
        zipCode: zipCode,
      );
      final response = await _dio.post<Map<String, dynamic>>(
        '/customers/me/addresses',
        data: request.toJson(),
      );
      final dto = CustomerAddressResponseDto.fromJson(response.data!);
      return Ok(dto.toEntity());
    } on DioException catch (exception) {
      return Err(_failureOf(exception));
    }
  }

  @override
  Future<Result<OrderDetail>> getOrder(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/orders/$id');
      final dto = OrderDetailResponseDto.fromJson(response.data!);
      return Ok(dto.toEntity());
    } on DioException catch (exception) {
      return Err(_failureOf(exception));
    }
  }

  Failure _failureOf(DioException exception) {
    final error = exception.error;
    return error is ApiException ? error.failure : const UnknownFailure();
  }
}
