import 'package:freezed_annotation/freezed_annotation.dart';

part 'sub_order_item_response_dto.freezed.dart';
part 'sub_order_item_response_dto.g.dart';

enum ProductTypeDto {
  @JsonValue('PHYSICAL')
  physical,
  @JsonValue('SERVICE')
  service,
}

/// Corresponde a `SubOrderItemResponse` em `docs/api/openapi.json`.
@freezed
abstract class SubOrderItemResponseDto with _$SubOrderItemResponseDto {
  const factory SubOrderItemResponseDto({
    required String id,
    required String productName,
    required ProductTypeDto productType,
    required int quantity,
    required double unitPrice,
    required double lineTotal,
  }) = _SubOrderItemResponseDto;

  factory SubOrderItemResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SubOrderItemResponseDtoFromJson(json);
}
