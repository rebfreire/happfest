import 'package:happfest/core/error/result.dart';
import 'package:happfest/features/parties/domain/entities/party.dart';
import 'package:happfest/features/parties/domain/repositories/party_repository.dart';

class CreatePartyUseCase {
  const CreatePartyUseCase(this._repository);

  final PartyRepository _repository;

  Future<Result<Party>> call({
    required String customerId,
    required String street,
    required String number,
    required String neighborhood,
    required int cityCodigoIbge,
    required int stateCodigoUf,
    required String zipCode,
    required DateTime startDate,
    required DateTime endDate,
    required int guestCount,
    String? name,
    String? complement,
  }) {
    return _repository.createParty(
      customerId: customerId,
      name: name,
      street: street,
      number: number,
      complement: complement,
      neighborhood: neighborhood,
      cityCodigoIbge: cityCodigoIbge,
      stateCodigoUf: stateCodigoUf,
      zipCode: zipCode,
      startDate: startDate,
      endDate: endDate,
      guestCount: guestCount,
    );
  }
}
