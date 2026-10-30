import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/core/network/paged_response.dart';
import 'package:happfest/features/account/data/account_providers.dart';
import 'package:happfest/features/account/domain/entities/customer_account.dart';
import 'package:happfest/features/account/domain/entities/customer_address.dart';
import 'package:happfest/features/account/domain/entities/order_summary.dart';

final accountContextProvider = FutureProvider<Result<CustomerAccount>>((ref) {
  return ref.watch(getAccountContextUseCaseProvider)();
});

final accountAddressesProvider = FutureProvider<Result<List<CustomerAddress>>>(
  (ref) {
    return ref.watch(getAddressesUseCaseProvider)();
  },
);

final accountOrdersProvider =
    FutureProvider<Result<PagedResponse<OrderSummary>>>((ref) {
      return ref.watch(getOrdersUseCaseProvider)();
    });

/// Descarta tudo que depende da sessão do cliente (perfil, endereços,
/// pedidos e, por dependência, festas). Chamar após login e logout.
void invalidateAccountScopedProviders(Ref ref) {
  ref
    ..invalidate(accountContextProvider)
    ..invalidate(accountAddressesProvider)
    ..invalidate(accountOrdersProvider);
}
