import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:happfest/app/shell/app_shell_page.dart';
import 'package:happfest/design_system/design_system_storybook_page.dart';
import 'package:happfest/features/account/presentation/pages/account_page.dart';
import 'package:happfest/features/auth/presentation/pages/login_page.dart';
import 'package:happfest/features/cart/presentation/pages/cart_page.dart';
import 'package:happfest/features/categories/presentation/pages/categories_page.dart';
import 'package:happfest/features/categories/presentation/pages/category_products_page.dart';
import 'package:happfest/features/home/presentation/pages/home_page.dart';
import 'package:happfest/features/parties/presentation/pages/parties_page.dart';
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
                builder: (context, state) => const CategoriesPage(),
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
                builder: (context, state) => const PartiesPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/perfil',
                builder: (context, state) => const AccountPage(),
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
      GoRoute(
        path: '/categorias/produtos/:path',
        builder: (context, state) => CategoryProductsPage(
          categoryPath: Uri.decodeComponent(state.pathParameters['path']!),
          categoryName: state.extra as String?,
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
