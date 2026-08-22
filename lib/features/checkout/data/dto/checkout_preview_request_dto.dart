import 'package:freezed_annotation/freezed_annotation.dart';

part 'checkout_preview_request_dto.freezed.dart';
part 'checkout_preview_request_dto.g.dart';

/// Corresponde a `CheckoutPreviewRequest` em `docs/api/openapi.json`.
@freezed
abstract class CheckoutPreviewRequestDto with _$CheckoutPreviewRequestDto {
  const factory CheckoutPreviewRequestDto({required String partyId}) =
      _CheckoutPreviewRequestDto;

  factory CheckoutPreviewRequestDto.fromJson(Map<String, dynamic> json) =>
      _$CheckoutPreviewRequestDtoFromJson(json);
}
