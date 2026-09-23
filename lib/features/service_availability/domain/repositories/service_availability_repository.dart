import 'package:happfest/core/error/result.dart';
import 'package:happfest/features/service_availability/domain/entities/service_availability.dart';

abstract interface class ServiceAvailabilityRepository {
  Future<Result<ServiceAvailability>> getAvailability({
    required String productId,
    int quantity = 1,
    double pricingUnitQuantity = 1,
  });
}
