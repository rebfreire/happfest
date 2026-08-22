import 'package:happfest/core/error/result.dart';
import 'package:happfest/features/account/domain/repositories/account_repository.dart';

class DeleteAddressUseCase {
  const DeleteAddressUseCase(this._repository);

  final AccountRepository _repository;

  Future<Result<void>> call(String id) => _repository.deleteAddress(id);
}
