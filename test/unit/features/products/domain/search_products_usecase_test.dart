import 'package:flutter_test/flutter_test.dart';
import 'package:happfest/core/error/failure.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/core/network/paged_response.dart';
import 'package:happfest/features/products/domain/entities/product_summary.dart';
import 'package:happfest/features/products/domain/entities/product_type.dart';
import 'package:happfest/features/products/domain/repositories/product_repository.dart';
import 'package:happfest/features/products/domain/usecases/search_products_usecase.dart';
import 'package:mocktail/mocktail.dart';

class _MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late _MockProductRepository repository;
  late SearchProductsUseCase useCase;

  setUp(() {
    repository = _MockProductRepository();
    useCase = SearchProductsUseCase(repository);
  });

  test('forwards term/category and returns the paged result', () async {
    const product = ProductSummary(
      id: '1',
      name: 'DJ para Casamentos',
      slug: 'dj-para-casamentos',
      storeName: 'Fests',
      productType: ProductType.service,
      minPrice: 400,
    );
    const paged = PagedResponse<ProductSummary>(
      content: [product],
      page: 0,
      totalPages: 1,
      totalElements: 1,
      isLast: true,
    );
    when(
      () => repository.search(
        term: any(named: 'term'),
        categoryPath: any(named: 'categoryPath'),
        page: any(named: 'page'),
        size: any(named: 'size'),
      ),
    ).thenAnswer((_) async => const Ok(paged));

    final result = await useCase(term: 'dj', categoryPath: 'musica');

    expect(result, isA<Ok<PagedResponse<ProductSummary>>>());
    expect(
      (result as Ok<PagedResponse<ProductSummary>>).value.content.single,
      product,
    );
    verify(
      () => repository.search(
        term: 'dj',
        categoryPath: 'musica',
        page: any(named: 'page'),
        size: any(named: 'size'),
      ),
    ).called(1);
  });

  test('propagates a failure from the repository', () async {
    when(
      () => repository.search(
        term: any(named: 'term'),
        categoryPath: any(named: 'categoryPath'),
        page: any(named: 'page'),
        size: any(named: 'size'),
      ),
    ).thenAnswer((_) async => const Err(ServerFailure()));

    final result = await useCase();

    expect(result, isA<Err<PagedResponse<ProductSummary>>>());
  });
}
