import 'package:happfest/core/error/result.dart';
import 'package:happfest/features/account/domain/entities/customer_account.dart';
import 'package:happfest/features/account/domain/repositories/account_repository.dart';

class GetAccountContextUseCase {
  const GetAccountContextUseCase(this._repository);

  final AccountRepository _repository;

  Future<Result<CustomerAccount>> call() => _repository.getContext();
}
