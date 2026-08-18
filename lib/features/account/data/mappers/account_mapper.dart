import 'package:happfest/features/account/data/dto/customer_address_response_dto.dart';
import 'package:happfest/features/account/data/dto/customer_context_response_dto.dart';
import 'package:happfest/features/account/data/dto/order_summary_response_dto.dart';
import 'package:happfest/features/account/domain/entities/customer_account.dart';
import 'package:happfest/features/account/domain/entities/customer_address.dart';
import 'package:happfest/features/account/domain/entities/order_summary.dart';

extension CustomerContextResponseDtoMapper on CustomerContextResponseDto {
  CustomerAccount toEntity() {
    return CustomerAccount(
      customerId: customerId,
      activated: activated,
      name: name,
      email: email,
      phone: phone,
      cpf: cpf,
    );
  }
}

extension CustomerAddressResponseDtoMapper on CustomerAddressResponseDto {
  CustomerAddress toEntity() {
    return CustomerAddress(
      id: id,
      label: label ?? 'Endereço',
      street: street ?? '',
      number: number ?? '',
      complement: complement,
      neighborhood: neighborhood ?? '',
      cityName: cityNome,
      stateUf: stateUf,
      zipCode: zipCode ?? '',
      isDefault: isDefault,
    );
  }
}

extension OrderSummaryResponseDtoMapper on OrderSummaryResponseDto {
  OrderSummary toEntity() {
    return OrderSummary(
      id: id,
      totalAmount: totalAmount,
      deliveryDate: _tryParseDate(deliveryDate),
      createdAt: _tryParseDate(createdAt),
    );
  }
}

DateTime? _tryParseDate(String? value) {
  if (value == null) return null;
  return DateTime.tryParse(value);
}
