import 'package:flutter_test/flutter_test.dart';
import 'package:happfest/features/products/data/dto/product_response_dto.dart';
import 'package:happfest/features/products/data/dto/product_variant_response_dto.dart';
import 'package:happfest/features/products/data/mappers/product_detail_mapper.dart';

void main() {
  // BUG-003: o preço vem da variante, não de `pricingUnitMin` (quantidade).
  const product = ProductResponseDto(
    id: 'p1',
    name: 'Bolo Decorado',
    storeId: 's1',
    categoryId: 'c1',
    slug: 'bolo-decorado',
    productType: ProductTypeDto.physical,
    status: ProductStatusDto.published,
    pricingUnitMin: 1,
  );

  test('uses the default variant finalPrice as the price', () {
    final detail = product.toDetailEntity(const [], const [
      ProductVariantResponseDto(
        id: 'v1',
        productId: 'p1',
        price: 160,
        finalPrice: 150,
      ),
    ]);

    expect(detail.price, 150);
    expect(detail.pricingUnitMin, 1);
  });

  test('falls back to price when there is no finalPrice', () {
    final detail = product.toDetailEntity(const [], const [
      ProductVariantResponseDto(id: 'v1', productId: 'p1', price: 95),
    ]);

    expect(detail.price, 95);
  });

  test('ignores inactive variants', () {
    final detail = product.toDetailEntity(const [], const [
      ProductVariantResponseDto(
        id: 'v0',
        productId: 'p1',
        price: 10,
        active: false,
      ),
      ProductVariantResponseDto(id: 'v1', productId: 'p1', price: 95),
    ]);

    expect(detail.price, 95);
    expect(detail.defaultVariantId, 'v1');
  });
}
