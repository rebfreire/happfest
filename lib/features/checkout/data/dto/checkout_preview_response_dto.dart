import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:happfest/features/checkout/data/dto/sub_order_preview_response_dto.dart';

part 'checkout_preview_response_dto.freezed.dart';
part 'checkout_preview_response_dto.g.dart';

/// Corresponde a `CheckoutPreviewResponse` em `docs/api/openapi.json`.
@freezed
abstract class CheckoutPreviewResponseDto with _$CheckoutPreviewResponseDto {
  const factory CheckoutPreviewResponseDto({
    @Default([]) List<SubOrderPreviewResponseDto> subOrders,
    @Default(0) double total,
    @Default(0) double balanceAvailable,
    @Default(0) double maxBalanceUsable,
  }) = _CheckoutPreviewResponseDto;

  factory CheckoutPreviewResponseDto.fromJson(Map<String, dynamic> json) =>
      _$CheckoutPreviewResponseDtoFromJson(json);
}
