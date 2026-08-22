import 'package:happfest/core/error/result.dart';
import 'package:happfest/features/parties/domain/entities/party.dart';

abstract interface class PartyRepository {
  Future<Result<List<Party>>> getParties(String customerId);

  Future<Result<Party>> createParty({
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
  });
}
