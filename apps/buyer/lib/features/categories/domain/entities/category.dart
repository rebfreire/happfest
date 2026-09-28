import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';

@freezed
abstract class Category with _$Category {
  const factory Category({
    required String id,
    required String key,
    required String name,
    required String path,
    String? icon,
    @Default(false) bool hasChildren,
  }) = _Category;
}
