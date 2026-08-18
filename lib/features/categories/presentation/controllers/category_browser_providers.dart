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
