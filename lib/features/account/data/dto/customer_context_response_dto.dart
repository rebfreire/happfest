import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer_context_response_dto.freezed.dart';
part 'customer_context_response_dto.g.dart';

/// Corresponde a `CustomerContextResponse` em `docs/api/openapi.json`.
///
/// Nenhum campo é `required` no schema da API (nem `activated`) — só `id`
/// é tratado como obrigatório aqui; o resto é nullable/tem default para
/// nunca travar o parse (ver AGENTS.md e `docs/progress/03-auth.md` sobre
/// o bug de token nulo causado por um campo assumido como não-nulo).
@freezed
abstract class CustomerContextResponseDto with _$CustomerContextResponseDto {
  const factory CustomerContextResponseDto({
    required String customerId,
    @Default(false) bool activated,
    String? name,
    String? email,
    String? phone,
    String? cpf,
  }) = _CustomerContextResponseDto;

  factory CustomerContextResponseDto.fromJson(Map<String, dynamic> json) =>
      _$CustomerContextResponseDtoFromJson(json);
}
