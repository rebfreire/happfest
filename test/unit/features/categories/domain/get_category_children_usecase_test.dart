import 'package:flutter_test/flutter_test.dart';
import 'package:happfest/core/error/failure.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/features/categories/domain/entities/category.dart';
import 'package:happfest/features/categories/domain/repositories/category_repository.dart';
import 'package:happfest/features/categories/domain/usecases/get_category_children_usecase.dart';
import 'package:mocktail/mocktail.dart';

class _MockCategoryRepository extends Mock implements CategoryRepository {}

void main() {
  late _MockCategoryRepository repository;
  late GetCategoryChildrenUseCase useCase;

  setUp(() {
    repository = _MockCategoryRepository();
    useCase = GetCategoryChildrenUseCase(repository);
  });

  test('returns the children for the given path', () async {
    const children = [
      Category(
        id: '2',
        key: 'bolos-infantil',
        name: 'Infantil',
        path: 'bolos.infantil',
      ),
    ];
    when(
      () => repository.getChildren('bolos'),
    ).thenAnswer((_) async => const Ok(children));

    final result = await useCase('bolos');

    expect(result, const Ok(children));
    verify(() => repository.getChildren('bolos')).called(1);
  });

  test('propagates a failure from the repository', () async {
    when(
      () => repository.getChildren(any()),
    ).thenAnswer((_) async => const Err(ServerFailure()));

    final result = await useCase('bolos');

    expect(result, isA<Err<List<Category>>>());
  });
}
