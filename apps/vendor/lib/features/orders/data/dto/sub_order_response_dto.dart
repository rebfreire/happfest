import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:happfest_fornecedor/features/orders/data/dto/sub_order_item_response_dto.dart';

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

/// Corresponde a `SubOrderResponse` em `docs/api/openapi.json` (subset de
/// campos usados pelo app do fornecedor).
@freezed
abstract class SubOrderResponseDto with _$SubOrderResponseDto {
  const factory SubOrderResponseDto({
    required String id,
    required SubOrderStatusDto status,
    required double subtotal,
    required double supplierAmount,
    @Default([]) List<SubOrderItemResponseDto> items,
    String? deliveryDate,
    String? deliveryTime,
    String? deliveryStreet,
    String? deliveryNumber,
    String? deliveryNeighborhood,
    String? deliveryCityName,
    String? cancellationReason,
  }) = _SubOrderResponseDto;

  factory SubOrderResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SubOrderResponseDtoFromJson(json);
}
