import 'package:happfest/core/error/result.dart';
import 'package:happfest/features/account/domain/entities/customer_address.dart';
import 'package:happfest/features/account/domain/repositories/account_repository.dart';

class GetAddressesUseCase {
  const GetAddressesUseCase(this._repository);

  final AccountRepository _repository;

  Future<Result<List<CustomerAddress>>> call() => _repository.getAddresses();
}
