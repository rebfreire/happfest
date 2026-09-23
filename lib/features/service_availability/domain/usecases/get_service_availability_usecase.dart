import 'package:happfest/core/error/result.dart';
import 'package:happfest/features/service_availability/domain/entities/service_availability.dart';
import 'package:happfest/features/service_availability/domain/repositories/service_availability_repository.dart';

class GetServiceAvailabilityUseCase {
  const GetServiceAvailabilityUseCase(this._repository);

  final ServiceAvailabilityRepository _repository;

  Future<Result<ServiceAvailability>> call({
    required String productId,
    int quantity = 1,
    double pricingUnitQuantity = 1,
  }) {
    return _repository.getAvailability(
      productId: productId,
      quantity: quantity,
      pricingUnitQuantity: pricingUnitQuantity,
    );
  }
}
