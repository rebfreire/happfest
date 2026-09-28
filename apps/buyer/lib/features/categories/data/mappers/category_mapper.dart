import 'package:happfest/features/categories/data/dto/category_response_dto.dart';
import 'package:happfest/features/categories/domain/entities/category.dart';

extension CategoryResponseDtoMapper on CategoryResponseDto {
  Category toEntity() {
    return Category(
      id: id,
      key: key,
      name: name,
      path: path,
      icon: icon,
      hasChildren: hasChildren,
    );
  }
}
