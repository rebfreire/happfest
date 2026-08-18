import 'package:flutter_test/flutter_test.dart';
import 'package:happfest/core/error/failure.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/features/parties/domain/entities/party.dart';
import 'package:happfest/features/parties/domain/repositories/party_repository.dart';
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
}
