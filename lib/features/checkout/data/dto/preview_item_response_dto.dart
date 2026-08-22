import 'package:freezed_annotation/freezed_annotation.dart';

part 'preview_item_response_dto.freezed.dart';
part 'preview_item_response_dto.g.dart';

/// Corresponde a `PreviewItemResponse` em `docs/api/openapi.json`. Nenhum
/// campo é `required` no schema — só `cartItemId` é tratado como
/// obrigatório aqui (ver `docs/progress/03-auth.md` sobre o bug de token
/// nulo causado por assumir campos como não-nulos sem o contrato garantir).
@freezed
abstract class PreviewItemResponseDto with _$PreviewItemResponseDto {
  const factory PreviewItemResponseDto({
    required String cartItemId,
    String? productName,
    @Default(0) int quantity,
    @Default(0) double pricingUnitQuantity,
    @Default(0) double unitPrice,
    @Default(0) double lineTotal,
  }) = _PreviewItemResponseDto;

  factory PreviewItemResponseDto.fromJson(Map<String, dynamic> json) =>
      _$PreviewItemResponseDtoFromJson(json);
}
