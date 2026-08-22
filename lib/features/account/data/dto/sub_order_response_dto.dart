import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:happfest/features/account/data/dto/sub_order_item_response_dto.dart';

part 'sub_order_response_dto.freezed.dart';
part 'sub_order_response_dto.g.dart';

enum SubOrderStatusDto {
  @JsonValue('AWAITING_PAYMENT')
  awaitingPayment,
  @JsonValue('PENDING')
  pending,
  @JsonValue('ACCEPTED')
  accepted,
  @JsonValue('DELIVERED')
  delivered,
  @JsonValue('CONTESTED')
  contested,
  @JsonValue('COMPLETED')
  completed,
  @JsonValue('CANCELLED')
  cancelled,
  @JsonValue('REJECTED')
  rejected,
}

/// Subconjunto de `SubOrderResponse` em `docs/api/openapi.json` usado no
/// detalhe do pedido. Só `id` é obrigatório.
@freezed
abstract class SubOrderResponseDto with _$SubOrderResponseDto {
  const factory SubOrderResponseDto({
    required String id,
    String? storeName,
    SubOrderStatusDto? status,
    @Default(0) double subtotal,
    String? deliveryDate,
    String? deliveryTime,
    @Default([]) List<SubOrderItemResponseDto> items,
  }) = _SubOrderResponseDto;

  factory SubOrderResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SubOrderResponseDtoFromJson(json);
}
