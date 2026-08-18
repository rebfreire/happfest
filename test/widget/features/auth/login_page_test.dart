import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:happfest/core/error/failure.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/design_system/theme/app_theme.dart';
import 'package:happfest/features/auth/data/auth_providers.dart';
import 'package:happfest/features/auth/domain/entities/auth_session.dart';
import 'package:happfest/features/auth/domain/entities/profile_type.dart';
import 'package:happfest/features/auth/domain/repositories/auth_repository.dart';
import 'package:happfest/features/auth/domain/usecases/login_usecase.dart';
import 'package:happfest/features/auth/presentation/pages/login_page.dart';
import 'package:happfest/features/cart/data/cart_providers.dart';
import 'package:happfest/features/cart/domain/entities/cart.dart';
import 'package:happfest/features/cart/domain/repositories/cart_repository.dart';
import 'package:happfest/features/cart/domain/usecases/merge_cart_usecase.dart';
import 'package:happfest/l10n/generated/app_localizations.dart';

class _ScriptedAuthRepository implements AuthRepository {
  _ScriptedAuthRepository(this._result);

  final Result<AuthSession> _result;

  @override
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return _result;
  }

  @override
  Future<void> logout() async {}
}

class _FakeCartRepository implements CartRepository {
  @override
  Future<Result<Cart>> mergeAnonymousCart() async => const Ok(Cart(id: 'c1'));

  @override
  Future<Result<Cart>> getCart() async => throw UnimplementedError();

  @override
  Future<Result<Cart>> addItem({
    required String productVariantId,
    required int quantity,
    required double pricingUnitQuantity,
  }) async => throw UnimplementedError();

  @override
  Future<Result<Cart>> updateItem({
    required String itemId,
    required int quantity,
    required double pricingUnitQuantity,
  }) async => throw UnimplementedError();

  @override
  Future<Result<Cart>> removeItem(String itemId) async =>
      throw UnimplementedError();
}

Widget _wrap(Result<AuthSession> result) {
  final router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(body: Text('home')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      loginUseCaseProvider.overrideWithValue(
        LoginUseCase(_ScriptedAuthRepository(result)),
      ),
      mergeCartUseCaseProvider.overrideWithValue(
        MergeCartUseCase(_FakeCartRepository()),
      ),
    ],
    child: MaterialApp.router(
      theme: AppTheme.light,
      locale: const Locale('pt'),
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
}

void main() {
  testWidgets('shows email and password fields and submit button', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const Err(UnauthorizedFailure())));

    expect(find.text('E-mail'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });

  testWidgets('shows an error snackbar on failed login', (tester) async {
    await tester.pumpWidget(_wrap(const Err(UnauthorizedFailure())));

    await tester.enterText(find.byType(TextField).first, 'a@b.com');
    await tester.enterText(find.byType(TextField).last, 'wrong-password');
    await tester.tap(find.text('Entrar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));

    expect(find.text('Sessão expirada.'), findsOneWidget);
  });

  testWidgets('navigates to home on successful login', (tester) async {
    const session = AuthSession(
      token: 't',
      userId: 'u',
      profileType: ProfileType.customer,
      permissions: [],
    );
    await tester.pumpWidget(_wrap(const Ok(session)));

    await tester.enterText(find.byType(TextField).first, 'a@b.com');
    await tester.enterText(find.byType(TextField).last, '123456');
    await tester.tap(find.text('Entrar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));
    await tester.pumpAndSettle();

    expect(find.text('home'), findsOneWidget);
  });
}
