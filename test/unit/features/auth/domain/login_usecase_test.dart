import 'package:flutter_test/flutter_test.dart';
import 'package:happfest/core/error/failure.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/features/auth/domain/entities/auth_session.dart';
import 'package:happfest/features/auth/domain/entities/profile_type.dart';
import 'package:happfest/features/auth/domain/repositories/auth_repository.dart';
import 'package:happfest/features/auth/domain/usecases/login_usecase.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repository;
  late LoginUseCase useCase;

  setUp(() {
    repository = _MockAuthRepository();
    useCase = LoginUseCase(repository);
  });

  test('returns Ok with the session on success', () async {
    const session = AuthSession(
      accessToken: 'token-123',
      userId: 'user-1',
      profileType: ProfileType.customer,
      permissions: [],
    );
    when(
      () => repository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => const Ok(session));

    final result = await useCase(email: 'a@b.com', password: '123456');

    expect(result, isA<Ok<AuthSession>>());
    expect((result as Ok<AuthSession>).value, session);
    verify(
      () => repository.login(email: 'a@b.com', password: '123456'),
    ).called(1);
  });

  test('returns Err with the failure on error', () async {
    when(
      () => repository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => const Err(UnauthorizedFailure()));

    final result = await useCase(email: 'a@b.com', password: 'wrong');

    expect(result, isA<Err<AuthSession>>());
    expect((result as Err<AuthSession>).failure, isA<UnauthorizedFailure>());
  });
}
