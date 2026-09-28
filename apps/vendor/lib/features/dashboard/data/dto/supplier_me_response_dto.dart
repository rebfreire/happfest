import 'package:freezed_annotation/freezed_annotation.dart';

part 'supplier_me_response_dto.freezed.dart';
part 'supplier_me_response_dto.g.dart';

enum ApprovalStatusDto {
  @JsonValue('AWAITING_DOCUMENTS')
  awaitingDocuments,
  @JsonValue('IN_REVIEW')
  inReview,
  @JsonValue('DOCUMENTS_PENDING')
  documentsPending,
  @JsonValue('APPROVED')
  approved,
  @JsonValue('SUSPENDED')
  suspended,
  @JsonValue('REJECTED')
  rejected,
}

/// Corresponde a `SupplierMeResponse` em `docs/api/openapi.json`.
@freezed
abstract class SupplierMeResponseDto with _$SupplierMeResponseDto {
  const factory SupplierMeResponseDto({
    required String id,
    required String name,
    required ApprovalStatusDto approvalStatus,
    String? tradeName,
    String? storeId,
    String? storeSlug,
  }) = _SupplierMeResponseDto;

  factory SupplierMeResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SupplierMeResponseDtoFromJson(json);
}
