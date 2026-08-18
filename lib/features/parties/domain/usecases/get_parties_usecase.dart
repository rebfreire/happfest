import 'package:happfest/core/error/result.dart';
import 'package:happfest/features/parties/domain/entities/party.dart';
import 'package:happfest/features/parties/domain/repositories/party_repository.dart';

class GetPartiesUseCase {
  const GetPartiesUseCase(this._repository);

  final PartyRepository _repository;

  Future<Result<List<Party>>> call(String customerId) =>
      _repository.getParties(customerId);
}
