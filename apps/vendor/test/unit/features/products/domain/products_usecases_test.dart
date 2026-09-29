import 'package:flutter_test/flutter_test.dart';
import 'package:happfest_core/core/error/failure.dart';
import 'package:happfest_core/core/error/result.dart';
import 'package:happfest_core/core/network/paged_response.dart';
import 'package:happfest_fornecedor/features/products/domain/entities/pricing_unit_type.dart';
import 'package:happfest_fornecedor/features/products/domain/entities/product.dart';
import 'package:happfest_fornecedor/features/products/domain/entities/product_list_item.dart';
import 'package:happfest_fornecedor/features/products/domain/entities/product_status.dart';
import 'package:happfest_fornecedor/features/products/domain/entities/product_type.dart';
import 'package:happfest_fornecedor/features/products/domain/repositories/products_repository.dart';
import 'package:happfest_fornecedor/features/products/domain/usecases/get_product_detail_usecase.dart';
import 'package:happfest_fornecedor/features/products/domain/usecases/list_my_products_usecase.dart';
import 'package:happfest_fornecedor/features/products/domain/usecases/set_product_featured_usecase.dart';
import 'package:happfest_fornecedor/features/products/domain/usecases/set_product_status_usecase.dart';
import 'package:mocktail/mocktail.dart';

class _MockProductsRepository extends Mock implements ProductsRepository {}

void main() {
  late _MockProductsRepository repository;

  setUp(() {
    repository = _MockProductsRepository();
  });

  test('ListMyProductsUseCase forwards the status filter', () async {
    when(
      () => repository.listMine(status: ProductStatus.published),
    ).thenAnswer(
      (_) async => const Ok(
        PagedResponse(
          content: [],
          page: 0,
          totalPages: 0,
          totalElements: 0,
          isLast: true,
        ),
      ),
    );

    final result = await ListMyProductsUseCase(repository)(
      status: ProductStatus.published,
    );

    expect(result, isA<Ok<PagedResponse<ProductListItem>>>());
    verify(
      () => repository.listMine(status: ProductStatus.published),
    ).called(1);
  });

  test('GetProductDetailUseCase returns the repository result', () async {
    const product = Product(
      id: 'p1',
      categoryId: 'c1',
      name: 'Bolo de chocolate',
      productType: ProductType.physical,
      status: ProductStatus.published,
      hasVariants: false,
      featured: false,
      pricingUnitType: PricingUnitType.un,
      pricingUnitMin: 50,
      pricingUnitMax: 50,
      pricingUnitStep: 1,
    );
    when(
      () => repository.getById('p1'),
    ).thenAnswer((_) async => const Ok(product));

    final result = await GetProductDetailUseCase(repository)('p1');

    expect(result, const Ok(product));
  });

  test('SetProductStatusUseCase delegates to the repository', () async {
    when(
      () => repository.setStatus('p1', ProductStatus.paused),
    ).thenAnswer((_) async => const Ok(null));

    final result = await SetProductStatusUseCase(repository)(
      'p1',
      ProductStatus.paused,
    );

    expect(result, const Ok<void>(null));
    verify(() => repository.setStatus('p1', ProductStatus.paused)).called(1);
  });

  test(
    'SetProductFeaturedUseCase forwards the flag and propagates a failure',
    () async {
      when(
        () => repository.setFeatured('p1', featured: true),
      ).thenAnswer((_) async => const Err(ServerFailure()));

      final result = await SetProductFeaturedUseCase(repository)(
        'p1',
        featured: true,
      );

      expect(result, isA<Err<void>>());
    },
  );
}
