import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:happfest_core/core/error/failure.dart';
import 'package:happfest_core/core/error/result.dart';
import 'package:happfest_core/core/network/paged_response.dart';
import 'package:happfest_design_system/design_system/theme/app_theme.dart';
import 'package:happfest_fornecedor/features/products/data/products_providers.dart';
import 'package:happfest_fornecedor/features/products/domain/entities/pricing_unit_type.dart';
import 'package:happfest_fornecedor/features/products/domain/entities/product.dart';
import 'package:happfest_fornecedor/features/products/domain/entities/product_list_item.dart';
import 'package:happfest_fornecedor/features/products/domain/entities/product_status.dart';
import 'package:happfest_fornecedor/features/products/domain/entities/product_type.dart';
import 'package:happfest_fornecedor/features/products/domain/repositories/products_repository.dart';
import 'package:happfest_fornecedor/features/products/domain/usecases/get_product_detail_usecase.dart';
import 'package:happfest_fornecedor/features/products/domain/usecases/set_product_featured_usecase.dart';
import 'package:happfest_fornecedor/features/products/domain/usecases/set_product_status_usecase.dart';
import 'package:happfest_fornecedor/features/products/presentation/pages/product_detail_page.dart';

const _product = Product(
  id: 'p1',
  categoryId: 'c1',
  name: 'Bolo de chocolate',
  productType: ProductType.physical,
  status: ProductStatus.draft,
  hasVariants: false,
  featured: false,
  pricingUnitType: PricingUnitType.un,
  pricingUnitMin: 50,
  pricingUnitMax: 50,
  pricingUnitStep: 1,
);

class _ScriptedProductsRepository implements ProductsRepository {
  _ScriptedProductsRepository({this.setStatusResult = const Ok(null)});

  Product product = _product;
  final Result<void> setStatusResult;
  bool setStatusCalled = false;

  @override
  Future<Result<Product>> getById(String id) async => Ok(product);

  @override
  Future<Result<void>> setStatus(String id, ProductStatus status) async {
    setStatusCalled = true;
    if (setStatusResult is Ok<void>) {
      product = product.copyWith(status: status);
    }
    return setStatusResult;
  }

  @override
  Future<Result<void>> setFeatured(String id, {required bool featured}) =>
      throw UnimplementedError();

  @override
  Future<Result<PagedResponse<ProductListItem>>> listMine({
    ProductStatus? status,
    int page = 0,
    int size = 20,
  }) => throw UnimplementedError();
}

Widget _wrap(_ScriptedProductsRepository repository) {
  final router = GoRouter(
    initialLocation: '/products/${_product.id}',
    routes: [
      GoRoute(
        path: '/products',
        builder: (context, state) => const Scaffold(body: Text('products')),
      ),
      GoRoute(
        path: '/products/:id',
        builder: (context, state) =>
            ProductDetailPage(productId: state.pathParameters['id']!),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      getProductDetailUseCaseProvider.overrideWithValue(
        GetProductDetailUseCase(repository),
      ),
      setProductStatusUseCaseProvider.overrideWithValue(
        SetProductStatusUseCase(repository),
      ),
      setProductFeaturedUseCaseProvider.overrideWithValue(
        SetProductFeaturedUseCase(repository),
      ),
    ],
    child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
  );
}

void main() {
  testWidgets('shows product info and the publish action when draft', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(_ScriptedProductsRepository()));
    await tester.pumpAndSettle();

    expect(find.text('Bolo de chocolate'), findsOneWidget);
    expect(find.text('Publicar'), findsOneWidget);
  });

  testWidgets('publishing calls the repository and refreshes the status', (
    tester,
  ) async {
    final repository = _ScriptedProductsRepository();
    await tester.pumpWidget(_wrap(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Publicar'));
    await tester.pumpAndSettle();

    expect(repository.setStatusCalled, isTrue);
    expect(find.text('Pausar'), findsOneWidget);
  });

  testWidgets('shows a snackbar when publishing fails', (tester) async {
    final repository = _ScriptedProductsRepository(
      setStatusResult: const Err(ServerFailure()),
    );
    await tester.pumpWidget(_wrap(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Publicar'));
    await tester.pumpAndSettle();

    expect(repository.setStatusCalled, isTrue);
    expect(find.text(const ServerFailure().message), findsOneWidget);
  });
}
