import 'package:flutter_test/flutter_test.dart';
import 'package:happfest/core/error/failure.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/features/checkout/domain/entities/checkout_preview.dart';
import 'package:happfest/features/checkout/domain/entities/checkout_result.dart';
import 'package:happfest/features/checkout/domain/entities/payment_method.dart';
import 'package:happfest/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:happfest/features/checkout/domain/usecases/preview_checkout_usecase.dart';
import 'package:happfest/features/checkout/domain/usecases/submit_checkout_usecase.dart';
import 'package:mocktail/mocktail.dart';

class _MockCheckoutRepository extends Mock implements CheckoutRepository {}

void main() {
  late _MockCheckoutRepository repository;

  setUpAll(() {
    registerFallbackValue(PaymentMethod.pix);
  });

  setUp(() {
    repository = _MockCheckoutRepository();
  });

  test(
    'PreviewCheckoutUseCase returns the preview from the repository',
    () async {
      const preview = CheckoutPreview(total: 100);
      when(
        () => repository.preview(partyId: 'p1'),
      ).thenAnswer((_) async => const Ok(preview));

      final result = await PreviewCheckoutUseCase(repository)(partyId: 'p1');

      expect(result, const Ok(preview));
      verify(() => repository.preview(partyId: 'p1')).called(1);
    },
  );

  test(
    'SubmitCheckoutUseCase forwards the party/method and propagates failures',
    () async {
      when(
        () => repository.checkout(
          partyId: any(named: 'partyId'),
          paymentMethod: any(named: 'paymentMethod'),
        ),
      ).thenAnswer((_) async => const Err(ServerFailure()));

      final result = await SubmitCheckoutUseCase(repository)(
        partyId: 'p1',
        paymentMethod: PaymentMethod.pix,
      );

      expect(result, isA<Err<CheckoutResult>>());
      verify(
        () => repository.checkout(
          partyId: 'p1',
          paymentMethod: PaymentMethod.pix,
        ),
      ).called(1);
    },
  );
}
