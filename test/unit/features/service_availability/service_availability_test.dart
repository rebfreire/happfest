import 'package:flutter_test/flutter_test.dart';
import 'package:happfest/core/error/failure.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/features/service_availability/domain/entities/service_availability.dart';
import 'package:happfest/features/service_availability/domain/repositories/service_availability_repository.dart';
import 'package:happfest/features/service_availability/domain/usecases/get_service_availability_usecase.dart';
import 'package:mocktail/mocktail.dart';

class _MockServiceAvailabilityRepository extends Mock
    implements ServiceAvailabilityRepository {}

void main() {
  late _MockServiceAvailabilityRepository repository;

  setUp(() {
    repository = _MockServiceAvailabilityRepository();
  });

  test(
    'GetServiceAvailabilityUseCase forwards quantity/pricingUnitQuantity '
    'and returns the availability from the repository',
    () async {
      final availability = ServiceAvailability(
        timeSelectionRequired: true,
        availableDates: [
          ServiceAvailabilityDate(
            date: DateTime(2026, 10, 15),
            availableTimes: const ['09:00:00', '14:30:00'],
          ),
        ],
      );
      when(
        () => repository.getAvailability(
          productId: 'p1',
          quantity: 2,
          pricingUnitQuantity: 1.5,
        ),
      ).thenAnswer((_) async => Ok(availability));

      final result = await GetServiceAvailabilityUseCase(repository)(
        productId: 'p1',
        quantity: 2,
        pricingUnitQuantity: 1.5,
      );

      expect((result as Ok<ServiceAvailability>).value, availability);
      verify(
        () => repository.getAvailability(
          productId: 'p1',
          quantity: 2,
          pricingUnitQuantity: 1.5,
        ),
      ).called(1);
    },
  );

  test(
    'GetServiceAvailabilityUseCase re-queries when quantity or duration '
    'changes, refetching a fresh window',
    () async {
      when(
        () => repository.getAvailability(productId: 'p1'),
      ).thenAnswer(
        (_) async => Ok(
          ServiceAvailability(
            availableDates: [
              ServiceAvailabilityDate(date: DateTime(2026, 10, 15)),
            ],
          ),
        ),
      );
      when(
        () => repository.getAvailability(
          productId: 'p1',
          quantity: 3,
        ),
      ).thenAnswer((_) async => const Ok(ServiceAvailability()));

      final usecase = GetServiceAvailabilityUseCase(repository);
      final withOneGuest = await usecase(productId: 'p1');
      final withThreeGuests = await usecase(productId: 'p1', quantity: 3);

      expect(
        (withOneGuest as Ok<ServiceAvailability>).value.hasAvailability,
        isTrue,
      );
      expect(
        (withThreeGuests as Ok<ServiceAvailability>).value.hasAvailability,
        isFalse,
      );
    },
  );

  test('GetServiceAvailabilityUseCase propagates a failure', () async {
    when(
      () => repository.getAvailability(
        productId: any(named: 'productId'),
        quantity: any(named: 'quantity'),
        pricingUnitQuantity: any(named: 'pricingUnitQuantity'),
      ),
    ).thenAnswer((_) async => const Err(NotFoundFailure()));

    final result = await GetServiceAvailabilityUseCase(repository)(
      productId: 'missing',
    );

    expect(result, isA<Err<ServiceAvailability>>());
  });

  group('ServiceAvailability entity', () {
    final availability = ServiceAvailability(
      timeSelectionRequired: true,
      availableDates: [
        ServiceAvailabilityDate(
          date: DateTime(2026, 10, 15),
          availableTimes: const ['09:00:00', '14:30:00'],
        ),
      ],
    );

    test('isDateAvailable is true only for dates present in the response', () {
      expect(availability.isDateAvailable(DateTime(2026, 10, 15)), isTrue);
      expect(availability.isDateAvailable(DateTime(2026, 10, 16)), isFalse);
    });

    test('timesFor returns only the times for the matching date', () {
      expect(
        availability.timesFor(DateTime(2026, 10, 15)),
        ['09:00:00', '14:30:00'],
      );
      expect(availability.timesFor(DateTime(2026, 10, 16)), isEmpty);
    });

    test('hasAvailability is false when no dates come back from the API', () {
      const empty = ServiceAvailability();
      expect(empty.hasAvailability, isFalse);
    });
  });
}
