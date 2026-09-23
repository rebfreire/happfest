import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_action_response_dto.freezed.dart';
part 'payment_action_response_dto.g.dart';

/// Corresponde a `PaymentActionResponse` em `docs/api/openapi.json`. O
/// `type` chega como string livre da API (ex.: `PIX`, `BOLETO`,
/// `HOSTED_REDIRECT`) — mapeado para `PaymentActionType` na camada de
/// domínio, com `none` como fallback para valores desconhecidos ou ausentes.
@freezed
abstract class PaymentActionResponseDto with _$PaymentActionResponseDto {
  const factory PaymentActionResponseDto({
    String? type,
    String? url,
    String? pixCopyPaste,
    String? pixQrCode,
    String? boletoIdentificationField,
    String? boletoPdfUrl,
    String? expiresAt,
  }) = _PaymentActionResponseDto;

  factory PaymentActionResponseDto.fromJson(Map<String, dynamic> json) =>
      _$PaymentActionResponseDtoFromJson(json);
}
