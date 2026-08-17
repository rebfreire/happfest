import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:happfest/core/error/failure.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/features/auth/data/auth_providers.dart';
import 'package:happfest/features/auth/domain/entities/auth_session.dart';
import 'package:happfest/features/auth/domain/entities/profile_type.dart';
import 'package:happfest/features/auth/domain/repositories/auth_repository.dart';
import 'package:happfest/features/auth/domain/usecases/login_usecase.dart';
import 'package:happfest/features/auth/presentation/controllers/login_controller.dart';
import 'package:happfest/features/auth/presentation/controllers/login_state.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository(this.result);

  final Result<AuthSession> result;

  @override
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
  }) async {
    return result;
  }

  @override
  Future<void> logout() async {}
}

void main() {
  test('starts in idle state', () {
    final container = ProviderContainer(
      overrides: [
        loginUseCaseProvider.overrideWithValue(
          LoginUseCase(_FakeAuthRepository(const Err(UnknownFailure()))),
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(loginControllerProvider), const LoginState.idle());
  });

  test('submit transitions to success on Ok result', () async {
    const session = AuthSession(
      token: 't',
      userId: 'u',
      profileType: ProfileType.customer,
      permissions: [],
    );
    final container = ProviderContainer(
      overrides: [
        loginUseCaseProvider.overrideWithValue(
          LoginUseCase(_FakeAuthRepository(const Ok(session))),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(loginControllerProvider.notifier)
        .submit(email: 'a@b.com', password: '123456');

    expect(
      container.read(loginControllerProvider),
      const LoginState.success(session),
    );
  });

  test('submit transitions to failure on Err result', () async {
    final container = ProviderContainer(
      overrides: [
        loginUseCaseProvider.overrideWithValue(
          LoginUseCase(_FakeAuthRepository(const Err(UnauthorizedFailure()))),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(loginControllerProvider.notifier)
        .submit(email: 'a@b.com', password: 'wrong');

    expect(
      container.read(loginControllerProvider),
      const LoginState.failure(UnauthorizedFailure()),
    );
  });
}
