import 'package:freezed_annotation/freezed_annotation.dart';

part 'sub_order_item_response_dto.freezed.dart';
part 'sub_order_item_response_dto.g.dart';

/// Corresponde a `SubOrderItemResponse` em `docs/api/openapi.json`. Só
/// `id` é obrigatório — o schema não declara nenhum campo `required`.
@freezed
abstract class SubOrderItemResponseDto with _$SubOrderItemResponseDto {
  const factory SubOrderItemResponseDto({
    required String id,
    String? productName,
    @Default(0) int quantity,
    @Default(0) double unitPrice,
    @Default(0) double lineTotal,
  }) = _SubOrderItemResponseDto;

  factory SubOrderItemResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SubOrderItemResponseDtoFromJson(json);
}
