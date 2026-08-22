import 'package:happfest/core/error/result.dart';
import 'package:happfest/features/account/domain/entities/customer_address.dart';
import 'package:happfest/features/account/domain/repositories/account_repository.dart';

class CreateAddressUseCase {
  const CreateAddressUseCase(this._repository);

  final AccountRepository _repository;

  Future<Result<CustomerAddress>> call({
    required String label,
    required String street,
    required String number,
    required String neighborhood,
    required int cityCodigoIbge,
    required int stateCodigoUf,
    required String zipCode,
    String? complement,
  }) {
    return _repository.createAddress(
      label: label,
      street: street,
      number: number,
      complement: complement,
      neighborhood: neighborhood,
      cityCodigoIbge: cityCodigoIbge,
      stateCodigoUf: stateCodigoUf,
      zipCode: zipCode,
    );
  }
}
