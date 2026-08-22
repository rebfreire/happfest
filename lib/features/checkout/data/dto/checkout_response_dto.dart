import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:happfest/features/checkout/data/dto/order_response_dto.dart';
import 'package:happfest/features/checkout/data/dto/payment_response_dto.dart';

part 'checkout_response_dto.freezed.dart';
part 'checkout_response_dto.g.dart';

/// Corresponde a `CheckoutResponse` em `docs/api/openapi.json`.
@freezed
abstract class CheckoutResponseDto with _$CheckoutResponseDto {
  const factory CheckoutResponseDto({
    OrderResponseDto? order,
    PaymentResponseDto? payment,
  }) = _CheckoutResponseDto;

  factory CheckoutResponseDto.fromJson(Map<String, dynamic> json) =>
      _$CheckoutResponseDtoFromJson(json);
}
