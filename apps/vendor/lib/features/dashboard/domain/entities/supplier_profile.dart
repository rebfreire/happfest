import 'package:freezed_annotation/freezed_annotation.dart';

part 'supplier_profile.freezed.dart';

enum SupplierApprovalStatus {
  awaitingDocuments,
  inReview,
  documentsPending,
  approved,
  suspended,
  rejected,
}

@freezed
abstract class SupplierProfile with _$SupplierProfile {
  const factory SupplierProfile({
    required String id,
    required String name,
    required SupplierApprovalStatus approvalStatus,
    String? tradeName,
    String? storeId,
    String? storeSlug,
  }) = _SupplierProfile;
}
