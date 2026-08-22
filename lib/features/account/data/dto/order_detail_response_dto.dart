import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:happfest/features/account/data/dto/sub_order_response_dto.dart';

part 'order_detail_response_dto.freezed.dart';
part 'order_detail_response_dto.g.dart';

/// Subconjunto de `OrderResponse` em `docs/api/openapi.json` usado no
/// detalhe do pedido. Só `id` é obrigatório.
@freezed
abstract class OrderDetailResponseDto with _$OrderDetailResponseDto {
  const factory OrderDetailResponseDto({
    required String id,
    @Default(0) double totalAmount,
    String? deliveryDate,
    String? createdAt,
    @Default([]) List<SubOrderResponseDto> subOrders,
  }) = _OrderDetailResponseDto;

  factory OrderDetailResponseDto.fromJson(Map<String, dynamic> json) =>
      _$OrderDetailResponseDtoFromJson(json);
}
