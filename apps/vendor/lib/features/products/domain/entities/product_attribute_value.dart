import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_attribute_value.freezed.dart';

@freezed
abstract class ProductAttributeValue with _$ProductAttributeValue {
  const factory ProductAttributeValue({
    required String attributeName,
    required String valueText,
  }) = _ProductAttributeValue;
}
