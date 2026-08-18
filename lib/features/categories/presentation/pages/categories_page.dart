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
class CategoriesPage extends ConsumerStatefulWidget {
  const CategoriesPage({super.key});

  @override
  ConsumerState<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends ConsumerState<CategoriesPage> {
  final List<Category> _trail = [];

  void _open(Category category) {
    if (category.hasChildren) {
      setState(() => _trail.add(category));
    } else {
      unawaited(
        context.push<void>(
          '/categorias/produtos/${Uri.encodeComponent(category.path)}',
          extra: category.name,
        ),
      );
    }
  }

  void _goToTrailIndex(int index) {
    setState(() => _trail.removeRange(index + 1, _trail.length));
  }

  @override
  Widget build(BuildContext context) {
    final currentPath = _trail.isEmpty ? null : _trail.last.path;
    final childrenAsync = ref.watch(categoryChildrenProvider(currentPath));

    return AppScaffold(
      title: 'Categorias',
      body: Column(
        children: [
          if (_trail.isNotEmpty)
            _Breadcrumb(trail: _trail, onTap: _goToTrailIndex),
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
                      onTap: () => _open(category),
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
