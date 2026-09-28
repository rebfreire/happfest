import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:happfest_core/core/config/env.dart';
import 'package:happfest_core/core/config/flavor.dart';
import 'package:happfest_fornecedor/app/app.dart';
import 'package:happfest_fornecedor/app/di/providers.dart';

void main() {
  testWidgets('HappFestFornecedorApp shows the setup placeholder page', (
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
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
