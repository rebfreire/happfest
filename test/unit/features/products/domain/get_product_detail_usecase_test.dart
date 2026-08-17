import 'package:flutter_test/flutter_test.dart';
import 'package:happfest/core/error/failure.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/features/products/domain/entities/product_detail.dart';
import 'package:happfest/features/products/domain/entities/product_type.dart';
import 'package:happfest/features/products/domain/repositories/product_detail_repository.dart';
import 'package:happfest/features/products/domain/usecases/get_product_detail_usecase.dart';
import 'package:mocktail/mocktail.dart';

class _MockProductDetailRepository extends Mock
    implements ProductDetailRepository {}

void main() {
  late _MockProductDetailRepository repository;
  late GetProductDetailUseCase useCase;

  setUp(() {
    repository = _MockProductDetailRepository();
    useCase = GetProductDetailUseCase(repository);
  });

  test('returns the product detail for the given id', () async {
    const detail = ProductDetail(
      id: '1',
      name: 'DJ para Casamentos',
      storeId: 's1',
      productType: ProductType.service,
      pricingUnitLabel: 'hora',
      pricingUnitMin: 400,
    );
    when(
      () => repository.getById('1'),
    ).thenAnswer((_) async => const Ok(detail));

    final result = await useCase('1');

    expect(result, const Ok(detail));
  });

  test('propagates NotFoundFailure from the repository', () async {
    when(
      () => repository.getById('missing'),
    ).thenAnswer((_) async => const Err(NotFoundFailure()));

    final result = await useCase('missing');

    expect(result, isA<Err<ProductDetail>>());
  });
}
