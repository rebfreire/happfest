import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_response_dto.freezed.dart';
part 'payment_response_dto.g.dart';

enum PaymentStatusDto {
  @JsonValue('PENDING')
  pending,
  @JsonValue('APPROVED')
  approved,
  @JsonValue('FAILED')
  failed,
  @JsonValue('CANCELLED')
  cancelled,
  @JsonValue('PARTIALLY_REFUNDED')
  partiallyRefunded,
  @JsonValue('REFUNDED')
  refunded,
}

/// Corresponde a `PaymentResponse` em `docs/api/openapi.json`. O
/// `paymentLink` (quando presente) é aberto no navegador — o app nunca
/// coleta dados de cartão diretamente.
@freezed
abstract class PaymentResponseDto with _$PaymentResponseDto {
  const factory PaymentResponseDto({
    required String id,
    PaymentStatusDto? status,
    @Default(0) double amount,
    String? paymentLink,
    String? failureReason,
  }) = _PaymentResponseDto;

  factory PaymentResponseDto.fromJson(Map<String, dynamic> json) =>
      _$PaymentResponseDtoFromJson(json);
}
