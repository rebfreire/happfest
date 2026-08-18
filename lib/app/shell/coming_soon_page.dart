import 'package:flutter/material.dart';
import 'package:happfest/design_system/components/app_scaffold.dart';
import 'package:happfest/design_system/feedback/app_empty_state.dart';

/// Placeholder para abas do shell cuja feature ainda não foi construída.
class ComingSoonPage extends StatelessWidget {
  const ComingSoonPage({
    required this.title,
    required this.message,
    required this.icon,
    super.key,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: title,
      body: AppEmptyState(message: message, icon: icon),
    );
  }
}
