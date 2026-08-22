import 'package:flutter_test/flutter_test.dart';
import 'package:happfest/core/error/failure.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/features/parties/domain/entities/party.dart';
import 'package:happfest/features/parties/domain/repositories/party_repository.dart';
import 'package:happfest/features/parties/domain/usecases/create_party_usecase.dart';
import 'package:happfest/features/parties/domain/usecases/get_parties_usecase.dart';
import 'package:mocktail/mocktail.dart';

class _MockPartyRepository extends Mock implements PartyRepository {}

void main() {
  late _MockPartyRepository repository;
  late GetPartiesUseCase useCase;

  setUp(() {
    repository = _MockPartyRepository();
    useCase = GetPartiesUseCase(repository);
  });

  test('returns the parties for the given customer', () async {
    const parties = [Party(id: 'p1', name: 'Aniversário da Ana')];
    when(
      () => repository.getParties('c1'),
    ).thenAnswer((_) async => const Ok(parties));

    final result = await useCase('c1');

    expect(result, const Ok(parties));
    verify(() => repository.getParties('c1')).called(1);
  });

  test('propagates a failure from the repository', () async {
    when(
      () => repository.getParties(any()),
    ).thenAnswer((_) async => const Err(UnauthorizedFailure()));

    final result = await useCase('c1');

    expect(result, isA<Err<List<Party>>>());
  });

  test(
    'CreatePartyUseCase forwards the fields and returns the created party',
    () async {
      const created = Party(id: 'p1', name: 'Aniversário da Ana');
      when(
        () => repository.createParty(
          customerId: any(named: 'customerId'),
          street: any(named: 'street'),
          number: any(named: 'number'),
          neighborhood: any(named: 'neighborhood'),
          cityCodigoIbge: any(named: 'cityCodigoIbge'),
          stateCodigoUf: any(named: 'stateCodigoUf'),
          zipCode: any(named: 'zipCode'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          guestCount: any(named: 'guestCount'),
          name: any(named: 'name'),
          complement: any(named: 'complement'),
        ),
      ).thenAnswer((_) async => const Ok(created));

      final startDate = DateTime(2026, 12);
      final endDate = DateTime(2026, 12);
      final result = await CreatePartyUseCase(repository)(
        customerId: 'c1',
        street: 'Rua 1',
        number: '10',
        neighborhood: 'Centro',
        cityCodigoIbge: 3550308,
        stateCodigoUf: 35,
        zipCode: '01001000',
        startDate: startDate,
        endDate: endDate,
        guestCount: 30,
        name: 'Aniversário da Ana',
      );

      expect(result, const Ok(created));
      verify(
        () => repository.createParty(
          customerId: 'c1',
          street: 'Rua 1',
          number: '10',
          neighborhood: 'Centro',
          cityCodigoIbge: 3550308,
          stateCodigoUf: 35,
          zipCode: '01001000',
          startDate: startDate,
          endDate: endDate,
          guestCount: 30,
          name: 'Aniversário da Ana',
        ),
      ).called(1);
    },
  );
}
