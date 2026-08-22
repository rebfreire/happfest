import 'package:happfest/core/error/result.dart';
import 'package:happfest/features/account/domain/entities/customer_address.dart';
import 'package:happfest/features/account/domain/repositories/account_repository.dart';

class SetDefaultAddressUseCase {
  const SetDefaultAddressUseCase(this._repository);

  final AccountRepository _repository;

  Future<Result<CustomerAddress>> call(String id) =>
      _repository.setDefaultAddress(id);
}
