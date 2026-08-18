import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:happfest/core/error/failure.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/design_system/components/app_avatar.dart';
import 'package:happfest/design_system/components/app_button.dart';
import 'package:happfest/design_system/components/app_card.dart';
import 'package:happfest/design_system/components/app_list_tile.dart';
import 'package:happfest/design_system/components/app_scaffold.dart';
import 'package:happfest/design_system/feedback/app_empty_state.dart';
import 'package:happfest/design_system/feedback/app_error_state.dart';
import 'package:happfest/design_system/feedback/app_loading.dart';
import 'package:happfest/design_system/tokens/app_spacing.dart';
import 'package:happfest/features/account/domain/entities/customer_account.dart';
import 'package:happfest/features/account/presentation/controllers/account_providers.dart';
import 'package:happfest/features/auth/data/auth_providers.dart';
import 'package:intl/intl.dart';

class AccountPage extends ConsumerWidget {
  const AccountPage({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    await ref.read(authRepositoryProvider).logout();
    if (context.mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contextAsync = ref.watch(accountContextProvider);

    return AppScaffold(
      title: 'Perfil',
      onRefresh: () async {
        ref
          ..invalidate(accountContextProvider)
          ..invalidate(accountAddressesProvider)
          ..invalidate(accountOrdersProvider);
      },
      body: contextAsync.when(
        loading: () => const AppLoading.skeleton(),
        error: (error, stackTrace) => AppErrorState(
          failure: const UnknownFailure(),
          onRetry: () => ref.invalidate(accountContextProvider),
        ),
        data: (result) => switch (result) {
          Ok(:final value) => ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              _AccountHeader(account: value),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Endereços',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              const _AddressesSection(),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Meus pedidos',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              const _OrdersSection(),
              const SizedBox(height: AppSpacing.lg),
              AppButton.delete(
                label: 'Sair',
                onPressed: () => _logout(context, ref),
              ),
            ],
          ),
          Err(:final failure) => AppErrorState(
            failure: failure,
            onRetry: () => ref.invalidate(accountContextProvider),
          ),
        },
      ),
    );
  }
}

class _AccountHeader extends StatelessWidget {
  const _AccountHeader({required this.account});

  final CustomerAccount account;

  @override
  Widget build(BuildContext context) {
    final label = account.name ?? account.email ?? '?';

    return AppCard(
      child: Row(
        children: [
          AppAvatar(initials: label.substring(0, 1).toUpperCase()),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.name ?? 'Cliente HappFest',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (account.email != null) Text(account.email!),
                if (account.phone != null) Text(account.phone!),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressesSection extends ConsumerWidget {
  const _AddressesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressesAsync = ref.watch(accountAddressesProvider);

    return addressesAsync.when(
      loading: () => const AppLoading.skeleton(),
      error: (error, stackTrace) => AppErrorState(
        failure: const UnknownFailure(),
        onRetry: () => ref.invalidate(accountAddressesProvider),
      ),
      data: (result) => switch (result) {
        Ok(:final value) when value.isEmpty => const AppEmptyState(
          message: 'Nenhum endereço cadastrado.',
          icon: Icons.location_on_outlined,
        ),
        Ok(:final value) => Column(
          children: [
            for (final address in value)
              AppCard(
                padding: EdgeInsets.zero,
                child: AppListTile(
                  title: address.label,
                  subtitle:
                      '${address.street}, ${address.number} — '
                      '${address.neighborhood}',
                  trailing: address.isDefault
                      ? const Icon(Icons.star, size: 18)
                      : null,
                ),
              ),
          ],
        ),
        Err(:final failure) => AppErrorState(
          failure: failure,
          onRetry: () => ref.invalidate(accountAddressesProvider),
        ),
      },
    );
  }
}

class _OrdersSection extends ConsumerWidget {
  const _OrdersSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(accountOrdersProvider);
    final currency = NumberFormat.simpleCurrency(locale: 'pt_BR');

    return ordersAsync.when(
      loading: () => const AppLoading.skeleton(),
      error: (error, stackTrace) => AppErrorState(
        failure: const UnknownFailure(),
        onRetry: () => ref.invalidate(accountOrdersProvider),
      ),
      data: (result) => switch (result) {
        Ok(:final value) when value.content.isEmpty => const AppEmptyState(
          message: 'Você ainda não fez nenhum pedido.',
          icon: Icons.receipt_long_outlined,
        ),
        Ok(:final value) => Column(
          children: [
            for (final order in value.content)
              AppCard(
                padding: EdgeInsets.zero,
                child: AppListTile(
                  title: currency.format(order.totalAmount),
                  subtitle: order.createdAt != null
                      ? DateFormat('dd/MM/yyyy').format(order.createdAt!)
                      : null,
                ),
              ),
          ],
        ),
        Err(:final failure) => AppErrorState(
          failure: failure,
          onRetry: () => ref.invalidate(accountOrdersProvider),
        ),
      },
    );
  }
}
