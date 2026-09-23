import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/features/service_availability/data/service_availability_providers.dart';
import 'package:happfest/features/service_availability/domain/entities/service_availability.dart';

typedef ServiceAvailabilityQuery = ({
  String productId,
  int quantity,
  double pricingUnitQuantity,
});

// The generated FutureProviderFamily type isn't publicly exported by
// riverpod, so it can't be spelled out explicitly here.
// ignore: specify_nonobvious_property_types
final serviceAvailabilityProvider = FutureProvider.autoDispose
    .family<Result<ServiceAvailability>, ServiceAvailabilityQuery>((
      ref,
      query,
    ) {
      return ref.watch(getServiceAvailabilityUseCaseProvider)(
        productId: query.productId,
        quantity: query.quantity,
        pricingUnitQuantity: query.pricingUnitQuantity,
      );
    });
