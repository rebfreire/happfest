import 'package:flutter_test/flutter_test.dart';
import 'package:happfest/core/error/failure.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/features/categories/domain/entities/category.dart';
import 'package:happfest/features/categories/domain/repositories/category_repository.dart';
import 'package:happfest/features/categories/domain/usecases/get_root_categories_usecase.dart';
import 'package:mocktail/mocktail.dart';

class _MockCategoryRepository extends Mock implements CategoryRepository {}

void main() {
  late _MockCategoryRepository repository;
  late GetRootCategoriesUseCase useCase;

  setUp(() {
    repository = _MockCategoryRepository();
    useCase = GetRootCategoriesUseCase(repository);
  });

  test('returns the categories from the repository', () async {
    const categories = [
      Category(id: '1', key: 'bolos', name: 'Bolos', path: 'bolos'),
    ];
    when(
      () => repository.getRootCategories(),
    ).thenAnswer((_) async => const Ok(categories));

    final result = await useCase();

    expect(result, const Ok(categories));
  });

  test('propagates a failure from the repository', () async {
    when(
      () => repository.getRootCategories(),
    ).thenAnswer((_) async => const Err(ServerFailure()));

    final result = await useCase();

    expect(result, isA<Err<List<Category>>>());
  });
}
