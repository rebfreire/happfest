import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:happfest/core/error/failure.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/design_system/theme/app_theme.dart';
import 'package:happfest/features/products/data/product_providers.dart';
import 'package:happfest/features/products/domain/entities/product_detail.dart';
import 'package:happfest/features/products/domain/entities/product_type.dart';
import 'package:happfest/features/products/domain/repositories/product_detail_repository.dart';
import 'package:happfest/features/products/domain/usecases/get_product_detail_usecase.dart';
import 'package:happfest/features/products/presentation/pages/product_detail_page.dart';
import 'package:happfest/l10n/generated/app_localizations.dart';

class _FakeProductDetailRepository implements ProductDetailRepository {
  _FakeProductDetailRepository(this.result);

  final Result<ProductDetail> result;

  @override
  Future<Result<ProductDetail>> getById(String id) async => result;
}

Widget _wrap(Result<ProductDetail> result, {String? storeName}) {
  return ProviderScope(
    overrides: [
      getProductDetailUseCaseProvider.overrideWithValue(
        GetProductDetailUseCase(_FakeProductDetailRepository(result)),
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ProductDetailPage(productId: '1', storeName: storeName),
    ),
  );
}

void main() {
  testWidgets('shows the product name, store and price on success', (
    tester,
  ) async {
    const detail = ProductDetail(
      id: '1',
      name: 'DJ para Casamentos e Festas',
      storeId: 's1',
      productType: ProductType.service,
      pricingUnitLabel: 'hora',
      pricingUnitMin: 400,
      description: 'DJ profissional com equipamento completo.',
    );
    // A square (1:1) image gallery is taller than the default 800x600 test
    // surface, pushing the rest of the content out of the built viewport —
    // use a portrait phone-sized surface, like the app is actually used.
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_wrap(const Ok(detail), storeName: 'Fests'));
    await tester.pumpAndSettle();

    expect(find.text('DJ para Casamentos e Festas'), findsOneWidget);
    expect(find.text('Fests'), findsOneWidget);
    expect(find.text('SERVIÇO'), findsOneWidget);
    expect(find.text('por hora'), findsOneWidget);
    expect(find.text('Adicionar ao carrinho'), findsOneWidget);
  });

  testWidgets('shows an error state when the request fails', (tester) async {
    await tester.pumpWidget(_wrap(const Err(NotFoundFailure())));
    await tester.pumpAndSettle();

    expect(find.text(const NotFoundFailure().message), findsOneWidget);
  });
}
