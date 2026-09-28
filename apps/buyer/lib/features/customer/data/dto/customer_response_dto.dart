import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer_response_dto.freezed.dart';
part 'customer_response_dto.g.dart';

/// Corresponde a `CustomerResponse` em `docs/api/openapi.json`.
@freezed
abstract class CustomerResponseDto with _$CustomerResponseDto {
  const factory CustomerResponseDto({
    required String id,
    required String userId,
    required String name,
    required String email,
    String? phone,
    String? cpf,
  }) = _CustomerResponseDto;

  factory CustomerResponseDto.fromJson(Map<String, dynamic> json) =>
      _$CustomerResponseDtoFromJson(json);
}
