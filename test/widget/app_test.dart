import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:happfest/app/app.dart';
import 'package:happfest/app/di/providers.dart';
import 'package:happfest/core/config/env.dart';
import 'package:happfest/core/config/flavor.dart';

void main() {
  testWidgets('HappFestApp shows the setup placeholder page', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          envProvider.overrideWithValue(Env.fromFlavor(Flavor.dev)),
        ],
        child: const HappFestApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('HappFest'), findsOneWidget);
  });
}
