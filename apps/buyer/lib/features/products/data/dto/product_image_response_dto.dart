import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_image_response_dto.freezed.dart';
part 'product_image_response_dto.g.dart';

/// Corresponde a `ProductImageResponse` em `docs/api/openapi.json`.
@freezed
abstract class ProductImageResponseDto with _$ProductImageResponseDto {
  const factory ProductImageResponseDto({
    required String id,
    required String url,
    @Default(false) bool isCover,
    @Default(0) int sortOrder,
  }) = _ProductImageResponseDto;

  factory ProductImageResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ProductImageResponseDtoFromJson(json);
}
