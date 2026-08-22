import 'package:dio/dio.dart';
import 'package:happfest/core/error/failure.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/core/network/api_exception.dart';
import 'package:happfest/features/checkout/data/dto/checkout_preview_request_dto.dart';
import 'package:happfest/features/checkout/data/dto/checkout_preview_response_dto.dart';
import 'package:happfest/features/checkout/data/dto/checkout_request_dto.dart';
import 'package:happfest/features/checkout/data/dto/checkout_response_dto.dart';
import 'package:happfest/features/checkout/data/mappers/checkout_mapper.dart';
import 'package:happfest/features/checkout/domain/entities/checkout_preview.dart';
import 'package:happfest/features/checkout/domain/entities/checkout_result.dart';
import 'package:happfest/features/checkout/domain/entities/payment_method.dart';
import 'package:happfest/features/checkout/domain/repositories/checkout_repository.dart';

class CheckoutRepositoryImpl implements CheckoutRepository {
  const CheckoutRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<Result<CheckoutPreview>> preview({required String partyId}) async {
    try {
      final request = CheckoutPreviewRequestDto(partyId: partyId);
      final response = await _dio.post<Map<String, dynamic>>(
        '/orders/checkout/preview',
        data: request.toJson(),
      );
      final dto = CheckoutPreviewResponseDto.fromJson(response.data!);
      return Ok(dto.toEntity());
    } on DioException catch (exception) {
      return Err(_failureOf(exception));
    }
  }

  @override
  Future<Result<CheckoutResult>> checkout({
    required String partyId,
    required PaymentMethod paymentMethod,
  }) async {
    try {
      final request = CheckoutRequestDto(
        partyId: partyId,
        paymentMethod: paymentMethod.apiValue,
      );
      final response = await _dio.post<Map<String, dynamic>>(
        '/orders/checkout',
        data: request.toJson(),
      );
      final dto = CheckoutResponseDto.fromJson(response.data!);
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
