import 'package:happfest/core/error/result.dart';
import 'package:happfest/features/parties/domain/entities/party.dart';

abstract interface class PartyRepository {
  Future<Result<List<Party>>> getParties(String customerId);
}
