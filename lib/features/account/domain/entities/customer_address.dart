import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer_address.freezed.dart';

@freezed
abstract class CustomerAddress with _$CustomerAddress {
  const factory CustomerAddress({
    required String id,
    required String label,
    required String street,
    required String number,
    required String neighborhood,
    required String zipCode,
    String? complement,
    String? cityName,
    String? stateUf,
    @Default(false) bool isDefault,
  }) = _CustomerAddress;
}
