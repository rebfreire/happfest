import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happfest/app/di/providers.dart';
import 'package:happfest/features/service_availability/data/repositories/service_availability_repository_impl.dart';
import 'package:happfest/features/service_availability/domain/repositories/service_availability_repository.dart';
import 'package:happfest/features/service_availability/domain/usecases/get_service_availability_usecase.dart';

final serviceAvailabilityRepositoryProvider =
    Provider<ServiceAvailabilityRepository>((ref) {
      return ServiceAvailabilityRepositoryImpl(ref.watch(dioProvider));
    });

final getServiceAvailabilityUseCaseProvider =
    Provider<GetServiceAvailabilityUseCase>((ref) {
      return GetServiceAvailabilityUseCase(
        ref.watch(serviceAvailabilityRepositoryProvider),
      );
    });
