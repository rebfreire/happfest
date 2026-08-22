import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_response_dto.freezed.dart';
part 'order_response_dto.g.dart';

/// Subconjunto de `OrderResponse` usado na confirmação do checkout.
@freezed
abstract class OrderResponseDto with _$OrderResponseDto {
  const factory OrderResponseDto({
    required String id,
    @Default(0) double totalAmount,
    String? deliveryDate,
  }) = _OrderResponseDto;

  factory OrderResponseDto.fromJson(Map<String, dynamic> json) =>
      _$OrderResponseDtoFromJson(json);
}
