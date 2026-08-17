import 'package:flutter/material.dart';
import 'package:happfest/design_system/tokens/app_radius.dart';
import 'package:happfest/design_system/tokens/app_spacing.dart';

class AppLoading extends StatelessWidget {
  const AppLoading({super.key}) : _skeletonLines = 0;

  const AppLoading.skeleton({super.key, int lines = 4})
    : _skeletonLines = lines;

  final int _skeletonLines;

  @override
  Widget build(BuildContext context) {
    if (_skeletonLines == 0) {
      return const Center(child: CircularProgressIndicator());
    }

    final baseColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: _skeletonLines,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) => Container(
        height: 64,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }
}

class AppLoadingOverlay extends StatelessWidget {
  const AppLoadingOverlay({
    required this.isLoading,
    required this.child,
    super.key,
  });

  final bool isLoading;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: ColoredBox(
              color: Colors.black.withValues(alpha: 0.1),
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}
