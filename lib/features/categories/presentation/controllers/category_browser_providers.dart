import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/features/categories/data/category_providers.dart';
import 'package:happfest/features/categories/domain/entities/category.dart';

/// `null` representa a raiz (`GET /categories`); qualquer outro valor busca
/// as filhas diretas daquele path (`GET /categories/path/{path}/children`).
// `FutureProviderFamily` não é exportado publicamente pelo flutter_riverpod
// (ver riverpod/src/providers/future_provider.dart), então o tipo não pode
// ser anotado explicitamente aqui.
// ignore: specify_nonobvious_property_types
final categoryChildrenProvider =
    FutureProvider.family<Result<List<Category>>, String?>((ref, path) {
      if (path == null) {
        return ref.watch(getRootCategoriesUseCaseProvider)();
      }
      return ref.watch(getCategoryChildrenUseCaseProvider)(path);
    });

/// Caminho percorrido na aba Categorias (raiz → subcategorias). Fica num
/// provider para o shell poder voltar à raiz quando a aba é tocada de novo.
final categoryTrailProvider =
    NotifierProvider<CategoryTrailController, List<Category>>(
      CategoryTrailController.new,
    );

class CategoryTrailController extends Notifier<List<Category>> {
  @override
  List<Category> build() => const [];

  void push(Category category) => state = [...state, category];

  void pop() {
    if (state.isEmpty) return;
    state = state.sublist(0, state.length - 1);
  }

  /// Mantém até o índice [index] (inclusive); `-1` volta para a raiz.
  void goTo(int index) => state = state.sublist(0, index + 1);

  void reset() => state = const [];
}
