import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:happfest/design_system/design_system_storybook_page.dart';
import 'package:happfest/features/auth/presentation/pages/login_page.dart';
import 'package:happfest/features/home/presentation/pages/home_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/', builder: (context, state) => const HomePage()),
      if (kDebugMode)
        GoRoute(
          path: '/dev/design-system',
          builder: (context, state) => const DesignSystemStorybookPage(),
        ),
    ],
  );
});
