import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_response_dto.freezed.dart';
part 'category_response_dto.g.dart';

/// Corresponde a `CategoryResponse` em `docs/api/openapi.json`.
@freezed
abstract class CategoryResponseDto with _$CategoryResponseDto {
  const factory CategoryResponseDto({
    required String id,
    required String key,
    required String name,
    required String path,
    String? icon,
    String? parentId,
    @Default(false) bool hasChildren,
  }) = _CategoryResponseDto;

  factory CategoryResponseDto.fromJson(Map<String, dynamic> json) =>
      _$CategoryResponseDtoFromJson(json);
}
