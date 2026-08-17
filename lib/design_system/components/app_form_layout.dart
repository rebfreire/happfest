import 'package:flutter/widgets.dart';
import 'package:happfest/design_system/tokens/app_spacing.dart';

/// Espaçamento vertical consistente entre campos de formulário — nenhuma
/// tela decide esse valor sozinha.
class AppFormLayout extends StatelessWidget {
  const AppFormLayout({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.md),
          children[i],
        ],
      ],
    );
  }
}
