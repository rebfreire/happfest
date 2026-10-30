import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:happfest/core/error/failure.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/design_system/components/app_list_tile.dart';
import 'package:happfest/design_system/components/app_scaffold.dart';
import 'package:happfest/design_system/feedback/app_empty_state.dart';
import 'package:happfest/design_system/feedback/app_error_state.dart';
import 'package:happfest/design_system/feedback/app_loading.dart';
import 'package:happfest/design_system/tokens/app_spacing.dart';
import 'package:happfest/features/categories/domain/entities/category.dart';
import 'package:happfest/features/categories/presentation/controllers/category_browser_providers.dart';

/// Navegação por categorias: raiz → subcategorias → lista de produtos da
/// categoria folha (sem filhas). O caminho percorrido vira breadcrumb
/// tocável no topo.
class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  void _open(BuildContext context, WidgetRef ref, Category category) {
    if (category.hasChildren) {
      ref.read(categoryTrailProvider.notifier).push(category);
    } else {
      unawaited(
        context.push<void>(
          '/categorias/produtos/${Uri.encodeComponent(category.path)}',
          extra: category.name,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trail = ref.watch(categoryTrailProvider);
    final trailController = ref.read(categoryTrailProvider.notifier);
    final currentPath = trail.isEmpty ? null : trail.last.path;
    final childrenAsync = ref.watch(categoryChildrenProvider(currentPath));

    return PopScope(
      canPop: trail.isEmpty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) trailController.pop();
      },
      child: AppScaffold(
        title: trail.isEmpty ? 'Categorias' : trail.last.name,
        leading: trail.isEmpty
            ? null
            : BackButton(onPressed: trailController.pop),
        body: Column(
          children: [
            if (trail.isNotEmpty)
              _Breadcrumb(trail: trail, onTap: trailController.goTo),
            Expanded(
              child: childrenAsync.when(
                loading: () => const AppLoading.skeleton(),
                error: (error, stackTrace) => AppErrorState(
                  failure: const UnknownFailure(),
                  onRetry: () =>
                      ref.invalidate(categoryChildrenProvider(currentPath)),
                ),
                data: (result) => switch (result) {
                  Ok(:final value) when value.isEmpty => const AppEmptyState(
                    message: 'Nenhuma categoria encontrada.',
                  ),
                  Ok(:final value) => ListView.separated(
                    itemCount: value.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final category = value[index];
                      return AppListTile(
                        title: category.name,
                        trailing: category.hasChildren
                            ? const Icon(Icons.chevron_right)
                            : null,
                        onTap: () => _open(context, ref, category),
                      );
                    },
                  ),
                  Err(:final failure) => AppErrorState(
                    failure: failure,
                    onRetry: () =>
                        ref.invalidate(categoryChildrenProvider(currentPath)),
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb({required this.trail, required this.onTap});

  final List<Category> trail;
  final void Function(int index) onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        children: [
          TextButton(
            onPressed: () => onTap(-1),
            child: const Text('Categorias'),
          ),
          for (var i = 0; i < trail.length; i++) ...[
            const Icon(Icons.chevron_right, size: 16),
            TextButton(
              onPressed: () => onTap(i),
              child: Text(trail[i].name),
            ),
          ],
        ],
      ),
    );
  }
}
