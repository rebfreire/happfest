import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_summary_response_dto.freezed.dart';
part 'order_summary_response_dto.g.dart';

/// Subconjunto de `OrderResponse` (`docs/api/openapi.json`) usado na lista
/// "Meus pedidos" — campos extras da resposta são ignorados no parse. Só
/// `id` é obrigatório; o schema não declara nenhum campo `required`.
@freezed
abstract class OrderSummaryResponseDto with _$OrderSummaryResponseDto {
  const factory OrderSummaryResponseDto({
    required String id,
    @Default(0) double totalAmount,
    String? deliveryDate,
    String? createdAt,
  }) = _OrderSummaryResponseDto;

  factory OrderSummaryResponseDto.fromJson(Map<String, dynamic> json) =>
      _$OrderSummaryResponseDtoFromJson(json);
}
