import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:happfest/design_system/tokens/app_spacing.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const _SetupPlaceholderPage(),
      ),
    ],
  );
});

/// Tela temporária da Fase 0 — confirma que Riverpod, go_router e o tema
/// estão funcionando. Será substituída pela Home real (feature `home`) na
/// próxima fase.
class _SetupPlaceholderPage extends StatelessWidget {
  const _SetupPlaceholderPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset('assets/images/happ_logo.svg', height: 64),
              const SizedBox(height: AppSpacing.md),
              Text(
                'HappFest',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Setup da Fase 0 concluído.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
