import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer_account.freezed.dart';

@freezed
abstract class CustomerAccount with _$CustomerAccount {
  const factory CustomerAccount({
    required String customerId,
    required bool activated,
    String? name,
    String? email,
    String? phone,
    String? cpf,
  }) = _CustomerAccount;
}
