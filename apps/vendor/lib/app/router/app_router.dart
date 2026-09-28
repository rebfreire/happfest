import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:happfest_fornecedor/app/router/setup_placeholder_page.dart';
import 'package:happfest_fornecedor/features/auth/presentation/pages/login_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/',
        builder: (context, state) => const SetupPlaceholderPage(),
      ),
    ],
  );
});
