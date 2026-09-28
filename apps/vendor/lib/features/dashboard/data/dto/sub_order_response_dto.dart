import 'package:freezed_annotation/freezed_annotation.dart';

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
/// preview do dashboard — a feature `orders` mapeia o contrato completo.
@freezed
abstract class SubOrderResponseDto with _$SubOrderResponseDto {
  const factory SubOrderResponseDto({
    required String id,
    required SubOrderStatusDto status,
    required double supplierAmount,
    String? deliveryDate,
  }) = _SubOrderResponseDto;

  factory SubOrderResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SubOrderResponseDtoFromJson(json);
}
