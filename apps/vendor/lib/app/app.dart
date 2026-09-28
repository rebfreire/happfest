import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happfest_design_system/design_system/theme/app_theme.dart';
import 'package:happfest_fornecedor/app/router/app_router.dart';
import 'package:happfest_fornecedor/l10n/generated/app_localizations.dart';

class HappFestFornecedorApp extends ConsumerWidget {
  const HappFestFornecedorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'HappFest Fornecedor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
