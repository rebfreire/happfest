import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:happfest_fornecedor/features/auth/presentation/pages/login_page.dart';
import 'package:happfest_fornecedor/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:happfest_fornecedor/features/orders/presentation/pages/order_detail_page.dart';
import 'package:happfest_fornecedor/features/orders/presentation/pages/orders_page.dart';
import 'package:happfest_fornecedor/features/products/presentation/pages/product_detail_page.dart';
import 'package:happfest_fornecedor/features/products/presentation/pages/products_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/', builder: (context, state) => const DashboardPage()),
      GoRoute(
        path: '/orders',
        builder: (context, state) => const OrdersPage(),
      ),
      GoRoute(
        path: '/orders/:id',
        builder: (context, state) =>
            OrderDetailPage(orderId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/products',
        builder: (context, state) => const ProductsPage(),
      ),
      GoRoute(
        path: '/products/:id',
        builder: (context, state) =>
            ProductDetailPage(productId: state.pathParameters['id']!),
      ),
    ],
  );
});
