import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/design_system/theme/app_theme.dart';
import 'package:happfest/features/auth/data/auth_providers.dart';
import 'package:happfest/features/auth/domain/entities/auth_session.dart';
import 'package:happfest/features/auth/domain/repositories/auth_repository.dart';
import 'package:happfest/features/auth/domain/usecases/signup_usecase.dart';
import 'package:happfest/features/auth/presentation/pages/signup_page.dart';
import 'package:happfest/l10n/generated/app_localizations.dart';

class _ScriptedAuthRepository implements AuthRepository {
  _ScriptedAuthRepository(this._signupResult);

  final Result<void> _signupResult;

  @override
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
  }) async => throw UnimplementedError();

  @override
  Future<Result<void>> signup({
    required String name,
    required String email,
    required String password,
    required String cpf,
    required String phone,
    required String birthDate,
    required double incomeValue,
    required String street,
    required String number,
    required String neighborhood,
    required int cityCodigoIbge,
    required int stateCodigoUf,
    required String zipCode,
    String? complement,
  }) async => _signupResult;

  @override
  Future<Result<void>> requestPasswordReset(String email) async =>
      const Ok(null);

  @override
  Future<void> logout() async {}
}

Widget _wrap(AuthRepository repository) {
  final router = GoRouter(
    initialLocation: '/cadastro',
    routes: [
      GoRoute(
        path: '/cadastro',
        builder: (context, state) => const SignupPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const Scaffold(body: Text('login')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      signupUseCaseProvider.overrideWithValue(SignupUseCase(repository)),
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
  testWidgets(
    'tapping Avançar on the access step (valid name/email/senha) advances '
    'to the personal-data step',
    (tester) async {
      await tester.pumpWidget(
        _wrap(_ScriptedAuthRepository(const Ok(null))),
      );

      expect(find.text('Nome completo'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextField, 'Nome completo'),
        'Maria Teste',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Email'),
        'maria@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Senha'),
        'SenhaForte123',
      );
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Avançar'));
      await tester.pump();

      expect(find.text('CPF'), findsOneWidget);
      expect(find.text('Renda mensal'), findsOneWidget);
      expect(find.text('Nome completo'), findsNothing);
    },
  );

  testWidgets(
    'Avançar stays disabled on the access step until name/e-mail/senha '
    'are all valid',
    (tester) async {
      await tester.pumpWidget(
        _wrap(_ScriptedAuthRepository(const Ok(null))),
      );

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Avançar'),
      );
      expect(button.onPressed, isNull);

      await tester.enterText(
        find.widgetWithText(TextField, 'Nome completo'),
        'Maria Teste',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Email'),
        'maria@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Senha'),
        'curta',
      );
      await tester.pump();

      final stillDisabled = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Avançar'),
      );
      expect(stillDisabled.onPressed, isNull);
    },
  );
}
