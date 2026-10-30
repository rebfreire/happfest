import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:happfest/design_system/components/app_text_field.dart';
import 'package:happfest/design_system/feedback/app_loading.dart';
import 'package:happfest/design_system/theme/app_theme.dart';

void main() {
  // BUG-009/014: um campo comum que reaproveita o State de um campo de
  // senha não pode continuar mascarado.
  testWidgets('does not inherit obscureText from a previous password field', (
    tester,
  ) async {
    final showPassword = ValueNotifier(true);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: ValueListenableBuilder(
            valueListenable: showPassword,
            builder: (context, isPassword, _) => isPassword
                ? const AppTextField(label: 'Senha', obscureText: true)
                : const AppTextField(label: 'Complemento'),
          ),
        ),
      ),
    );
    expect(tester.widget<TextField>(find.byType(TextField)).obscureText, true);

    showPassword.value = false;
    await tester.pump();

    expect(tester.widget<TextField>(find.byType(TextField)).obscureText, false);
  });

  // BUG-004: skeleton dentro de outro ListView não pode estourar a altura.
  testWidgets('skeleton renders inside a parent ListView', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: ListView(children: const [AppLoading.skeleton()]),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  // BUG-001: TextButton do tema dentro de Row não pode ter largura infinita.
  testWidgets('themed TextButton fits inside a Row', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Endereços'),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('Adicionar'),
              ),
            ],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
