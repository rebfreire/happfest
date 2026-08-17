import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:happfest/core/error/failure.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/core/network/paged_response.dart';
import 'package:happfest/design_system/theme/app_theme.dart';
import 'package:happfest/features/categories/data/category_providers.dart';
import 'package:happfest/features/categories/domain/entities/category.dart';
import 'package:happfest/features/categories/domain/repositories/category_repository.dart';
import 'package:happfest/features/categories/domain/usecases/get_root_categories_usecase.dart';
import 'package:happfest/features/home/presentation/pages/home_page.dart';
import 'package:happfest/features/products/data/product_providers.dart';
import 'package:happfest/features/products/domain/entities/product_summary.dart';
import 'package:happfest/features/products/domain/entities/product_type.dart';
import 'package:happfest/features/products/domain/repositories/product_repository.dart';
import 'package:happfest/features/products/domain/usecases/search_products_usecase.dart';
import 'package:happfest/l10n/generated/app_localizations.dart';

class _FakeCategoryRepository implements CategoryRepository {
  _FakeCategoryRepository(this.result);

  final Result<List<Category>> result;

  @override
  Future<Result<List<Category>>> getRootCategories() async => result;
}

class _FakeProductRepository implements ProductRepository {
  _FakeProductRepository(this.result);

  final Result<PagedResponse<ProductSummary>> result;

  @override
  Future<Result<PagedResponse<ProductSummary>>> search({
    String? term,
    String? categoryPath,
    int page = 0,
    int size = 20,
  }) async => result;
}

Widget _wrap({
  required Result<List<Category>> categories,
  required Result<PagedResponse<ProductSummary>> products,
}) {
  return ProviderScope(
    overrides: [
      getRootCategoriesUseCaseProvider.overrideWithValue(
        GetRootCategoriesUseCase(_FakeCategoryRepository(categories)),
      ),
      searchProductsUseCaseProvider.overrideWithValue(
        SearchProductsUseCase(_FakeProductRepository(products)),
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HomePage(),
    ),
  );
}

void main() {
  testWidgets('shows the product grid when the search succeeds', (
    tester,
  ) async {
    const product = ProductSummary(
      id: '1',
      name: 'DJ para Casamentos e Festas',
      slug: 'dj-para-casamentos-e-festas',
      storeName: 'Fests',
      productType: ProductType.service,
      minPrice: 400,
    );
    await tester.pumpWidget(
      _wrap(
        categories: const Ok([]),
        products: const Ok(
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

    expect(find.text('DJ para Casamentos e Festas'), findsOneWidget);
    expect(find.text('Fests'), findsOneWidget);
    expect(find.text('SERVIÇO'), findsOneWidget);
  });

  testWidgets('shows an empty state when there are no products', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        categories: const Ok([]),
        products: const Ok(
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

  testWidgets('shows an error state when the search fails', (tester) async {
    await tester.pumpWidget(
      _wrap(
        categories: const Ok([]),
        products: const Err(ServerFailure()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(const ServerFailure().message), findsOneWidget);
  });
}
