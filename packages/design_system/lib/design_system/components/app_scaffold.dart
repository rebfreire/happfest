import 'package:flutter/material.dart';

/// AppBar padrão + `SafeArea` + gestão de teclado + pull-to-refresh + FAB —
/// nenhuma tela monta um `Scaffold` cru.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.body,
    super.key,
    this.title,
    this.actions,
    this.onRefresh,
    this.floatingActionButton,
    this.resizeToAvoidBottomInset = true,
  });

  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Future<void> Function()? onRefresh;
  final Widget? floatingActionButton;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    final content = SafeArea(
      child: onRefresh != null
          ? RefreshIndicator(onRefresh: onRefresh!, child: body)
          : body,
    );

    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: title != null
          ? AppBar(title: Text(title!), actions: actions)
          : null,
      body: content,
      floatingActionButton: floatingActionButton,
    );
  }
}
