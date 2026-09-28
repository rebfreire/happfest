import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:happfest_core/core/config/env.dart';
import 'package:happfest_core/core/config/flavor.dart';
import 'package:happfest_core/core/di/app_providers.dart';
import 'package:happfest_fornecedor/app/app.dart';

void main() {
  testWidgets('HappFestFornecedorApp boots on the login page', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          envProvider.overrideWithValue(Env.fromFlavor(Flavor.dev)),
        ],
        child: const HappFestFornecedorApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('HappFest Fornecedor'), findsOneWidget);
  });
}
