import 'package:freezed_annotation/freezed_annotation.dart';

part 'checkout_request_dto.freezed.dart';
part 'checkout_request_dto.g.dart';

/// Corresponde a `CheckoutRequest` em `docs/api/openapi.json`. Sem
/// `deliveries` — cada loja herda a entrega da festa (comportamento padrão
/// da API quando o campo é omitido).
@freezed
abstract class CheckoutRequestDto with _$CheckoutRequestDto {
  const factory CheckoutRequestDto({
    required String partyId,
    required String paymentMethod,
  }) = _CheckoutRequestDto;

  factory CheckoutRequestDto.fromJson(Map<String, dynamic> json) =>
      _$CheckoutRequestDtoFromJson(json);
}
