import 'package:dio/dio.dart';
import 'package:happfest/core/error/failure.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/core/network/api_exception.dart';
import 'package:happfest/features/service_availability/data/dto/service_availability_response_dto.dart';
import 'package:happfest/features/service_availability/data/mappers/service_availability_mapper.dart';
import 'package:happfest/features/service_availability/domain/entities/service_availability.dart';
import 'package:happfest/features/service_availability/domain/repositories/service_availability_repository.dart';

class ServiceAvailabilityRepositoryImpl
    implements ServiceAvailabilityRepository {
  const ServiceAvailabilityRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<Result<ServiceAvailability>> getAvailability({
    required String productId,
    int quantity = 1,
    double pricingUnitQuantity = 1,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/products/$productId/service-availability',
        queryParameters: {
          'quantity': quantity,
          'pricingUnitQuantity': pricingUnitQuantity,
        },
      );
      final dto = ServiceAvailabilityResponseDto.fromJson(response.data!);
      return Ok(dto.toEntity());
    } on DioException catch (exception) {
      final error = exception.error;
      final failure = error is ApiException
          ? error.failure
          : const UnknownFailure();
      return Err(failure);
    }
  }
}
