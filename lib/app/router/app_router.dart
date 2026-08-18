import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:happfest/app/shell/app_shell_page.dart';
import 'package:happfest/app/shell/coming_soon_page.dart';
import 'package:happfest/design_system/design_system_storybook_page.dart';
import 'package:happfest/features/auth/presentation/pages/login_page.dart';
import 'package:happfest/features/cart/presentation/pages/cart_page.dart';
import 'package:happfest/features/home/presentation/pages/home_page.dart';
import 'package:happfest/features/products/presentation/pages/product_detail_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShellPage(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/', builder: (context, state) => const HomePage()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/categorias',
                builder: (context, state) => const ComingSoonPage(
                  title: 'Categorias',
                  message: 'Navegação por categorias em breve.',
                  icon: Icons.grid_view_outlined,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cart',
                builder: (context, state) => const CartPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/festas',
                builder: (context, state) => const ComingSoonPage(
                  title: 'Festas',
                  message: 'Gestão das suas festas em breve.',
                  icon: Icons.celebration_outlined,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/perfil',
                builder: (context, state) => const ComingSoonPage(
                  title: 'Perfil',
                  message: 'Sua conta em breve.',
                  icon: Icons.person_outline,
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/products/:id',
        builder: (context, state) => ProductDetailPage(
          productId: state.pathParameters['id']!,
          storeName: state.extra as String?,
        ),
      ),
      if (kDebugMode)
        GoRoute(
          path: '/dev/design-system',
          builder: (context, state) => const DesignSystemStorybookPage(),
        ),
    ],
  );
});
