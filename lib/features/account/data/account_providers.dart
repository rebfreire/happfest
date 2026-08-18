import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happfest/app/di/providers.dart';
import 'package:happfest/features/account/data/repositories/account_repository_impl.dart';
import 'package:happfest/features/account/domain/repositories/account_repository.dart';
import 'package:happfest/features/account/domain/usecases/get_account_context_usecase.dart';
import 'package:happfest/features/account/domain/usecases/get_addresses_usecase.dart';
import 'package:happfest/features/account/domain/usecases/get_orders_usecase.dart';

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return AccountRepositoryImpl(ref.watch(dioProvider));
});

final getAccountContextUseCaseProvider = Provider<GetAccountContextUseCase>((
  ref,
) {
  return GetAccountContextUseCase(ref.watch(accountRepositoryProvider));
});

final getAddressesUseCaseProvider = Provider<GetAddressesUseCase>((ref) {
  return GetAddressesUseCase(ref.watch(accountRepositoryProvider));
});

final getOrdersUseCaseProvider = Provider<GetOrdersUseCase>((ref) {
  return GetOrdersUseCase(ref.watch(accountRepositoryProvider));
});
