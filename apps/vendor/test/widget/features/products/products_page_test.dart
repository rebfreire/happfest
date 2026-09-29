import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:happfest_core/core/error/failure.dart';
import 'package:happfest_core/core/error/result.dart';
import 'package:happfest_core/core/network/paged_response.dart';
import 'package:happfest_design_system/design_system/theme/app_theme.dart';
import 'package:happfest_fornecedor/features/products/data/products_providers.dart';
import 'package:happfest_fornecedor/features/products/domain/entities/product.dart';
import 'package:happfest_fornecedor/features/products/domain/entities/product_list_item.dart';
import 'package:happfest_fornecedor/features/products/domain/entities/product_status.dart';
import 'package:happfest_fornecedor/features/products/domain/entities/product_type.dart';
import 'package:happfest_fornecedor/features/products/domain/repositories/products_repository.dart';
import 'package:happfest_fornecedor/features/products/domain/usecases/list_my_products_usecase.dart';
import 'package:happfest_fornecedor/features/products/presentation/pages/products_page.dart';

class _FakeProductsRepository implements ProductsRepository {
  _FakeProductsRepository(this.result);

  final Result<PagedResponse<ProductListItem>> result;

  @override
  Future<Result<PagedResponse<ProductListItem>>> listMine({
    ProductStatus? status,
    int page = 0,
    int size = 20,
  }) async => result;

  @override
  Future<Result<Product>> getById(String id) => throw UnimplementedError();

  @override
  Future<Result<void>> setStatus(String id, ProductStatus status) =>
      throw UnimplementedError();

  @override
  Future<Result<void>> setFeatured(String id, {required bool featured}) =>
      throw UnimplementedError();
}

Widget _wrap(Result<PagedResponse<ProductListItem>> result) {
  final router = GoRouter(
    initialLocation: '/products',
    routes: [
      GoRoute(
        path: '/products',
        builder: (context, state) => const ProductsPage(),
      ),
      GoRoute(
        path: '/products/:id',
        builder: (context, state) => const Scaffold(body: Text('detail')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      listMyProductsUseCaseProvider.overrideWithValue(
        ListMyProductsUseCase(_FakeProductsRepository(result)),
      ),
    ],
    child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
  );
}

void main() {
  testWidgets('shows the product list on success', (tester) async {
    const product = ProductListItem(
      id: 'p1',
      name: 'Bolo de chocolate',
      status: ProductStatus.published,
      productType: ProductType.physical,
      featured: false,
    );
    await tester.pumpWidget(
      _wrap(
        const Ok(
          PagedResponse(
            content: [product],
            page: 0,
            totalPages: 1,
            totalElements: 1,
            isLast: true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bolo de chocolate'), findsOneWidget);
  });

  testWidgets('shows an empty state when there are no products', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const Ok(
          PagedResponse(
            content: [],
            page: 0,
            totalPages: 0,
            totalElements: 0,
            isLast: true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nenhum produto encontrado.'), findsOneWidget);
  });

  testWidgets('shows an error state when the list call fails', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const Err(ServerFailure())));
    await tester.pumpAndSettle();

    expect(find.text(const ServerFailure().message), findsOneWidget);
  });
}
