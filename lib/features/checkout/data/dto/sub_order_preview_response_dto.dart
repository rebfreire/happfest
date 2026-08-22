import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:happfest/features/checkout/data/dto/preview_item_response_dto.dart';

part 'sub_order_preview_response_dto.freezed.dart';
part 'sub_order_preview_response_dto.g.dart';

/// Corresponde a `SubOrderPreviewResponse` em `docs/api/openapi.json`.
@freezed
abstract class SubOrderPreviewResponseDto with _$SubOrderPreviewResponseDto {
  const factory SubOrderPreviewResponseDto({
    required String storeId,
    String? storeName,
    @Default([]) List<PreviewItemResponseDto> items,
    @Default(0) double subtotal,
    @Default(0) double platformFeeAmount,
    String? deliveryDate,
    String? deliveryTime,
    String? deliveryCityName,
  }) = _SubOrderPreviewResponseDto;

  factory SubOrderPreviewResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SubOrderPreviewResponseDtoFromJson(json);
}
