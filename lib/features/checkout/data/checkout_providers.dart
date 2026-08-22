import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happfest/app/di/providers.dart';
import 'package:happfest/features/checkout/data/repositories/checkout_repository_impl.dart';
import 'package:happfest/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:happfest/features/checkout/domain/usecases/preview_checkout_usecase.dart';
import 'package:happfest/features/checkout/domain/usecases/submit_checkout_usecase.dart';

final checkoutRepositoryProvider = Provider<CheckoutRepository>((ref) {
  return CheckoutRepositoryImpl(ref.watch(dioProvider));
});

final previewCheckoutUseCaseProvider = Provider<PreviewCheckoutUseCase>((
  ref,
) {
  return PreviewCheckoutUseCase(ref.watch(checkoutRepositoryProvider));
});

final submitCheckoutUseCaseProvider = Provider<SubmitCheckoutUseCase>((ref) {
  return SubmitCheckoutUseCase(ref.watch(checkoutRepositoryProvider));
});
