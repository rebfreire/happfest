import 'package:happfest/core/error/result.dart';
import 'package:happfest/features/checkout/domain/entities/checkout_preview.dart';
import 'package:happfest/features/checkout/domain/repositories/checkout_repository.dart';

class PreviewCheckoutUseCase {
  const PreviewCheckoutUseCase(this._repository);

  final CheckoutRepository _repository;

  Future<Result<CheckoutPreview>> call({required String partyId}) {
    return _repository.preview(partyId: partyId);
  }
}
