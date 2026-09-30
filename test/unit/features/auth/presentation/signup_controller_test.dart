import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:happfest/core/error/failure.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/features/auth/data/auth_providers.dart';
import 'package:happfest/features/auth/domain/entities/auth_session.dart';
import 'package:happfest/features/auth/domain/repositories/auth_repository.dart';
import 'package:happfest/features/auth/domain/usecases/signup_usecase.dart';
import 'package:happfest/features/auth/presentation/controllers/signup_controller.dart';
import 'package:happfest/features/auth/presentation/controllers/signup_state.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository(this.result);

  final Result<void> result;
  int signupCallCount = 0;

  @override
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
  }) async => throw UnimplementedError();

  @override
  Future<Result<void>> signup({
    required String name,
    required String email,
    required String password,
    required String cpf,
    required String phone,
    required String birthDate,
    required double incomeValue,
    required String street,
    required String number,
    required String neighborhood,
    required int cityCodigoIbge,
    required int stateCodigoUf,
    required String zipCode,
    String? complement,
  }) async {
    signupCallCount++;
    return result;
  }

  @override
  Future<Result<void>> requestPasswordReset(String email) async =>
      const Ok(null);

  @override
  Future<void> logout() async {}
}

void main() {
  test('starts in idle state', () {
    final container = ProviderContainer(
      overrides: [
        signupUseCaseProvider.overrideWithValue(
          SignupUseCase(_FakeAuthRepository(const Err(UnknownFailure()))),
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(
      container.read(signupControllerProvider),
      const SignupState.idle(),
    );
  });

  test(
    'submit calls signup and transitions to success — no auto-login: the '
    'API requires e-mail verification before allowing login, so signup '
    'success just means the account was created',
    () async {
      final authRepository = _FakeAuthRepository(const Ok(null));
      final container = ProviderContainer(
        overrides: [
          signupUseCaseProvider.overrideWithValue(
            SignupUseCase(authRepository),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(signupControllerProvider.notifier)
          .submit(
            name: 'Maria',
            email: 'maria@example.com',
            password: '123456',
            cpf: '12345678901',
            phone: '11999999999',
            birthDate: '1990-05-10',
            incomeValue: 3500,
            street: 'Praça da Sé',
            number: '100',
            neighborhood: 'Sé',
            cityCodigoIbge: 3550308,
            stateCodigoUf: 35,
            zipCode: '01001000',
          );

      expect(
        container.read(signupControllerProvider),
        const SignupState.success(),
      );
      expect(authRepository.signupCallCount, 1);
    },
  );

  test(
    'submit transitions to failure on Err result (e.g. email already '
    'registered)',
    () async {
      final container = ProviderContainer(
        overrides: [
          signupUseCaseProvider.overrideWithValue(
            SignupUseCase(
              _FakeAuthRepository(
                const Err(ConflictFailure('E-mail já cadastrado.')),
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(signupControllerProvider.notifier)
          .submit(
            name: 'Maria',
            email: 'maria@example.com',
            password: '123456',
            cpf: '12345678901',
            phone: '11999999999',
            birthDate: '1990-05-10',
            incomeValue: 3500,
            street: 'Praça da Sé',
            number: '100',
            neighborhood: 'Sé',
            cityCodigoIbge: 3550308,
            stateCodigoUf: 35,
            zipCode: '01001000',
          );

      expect(
        container.read(signupControllerProvider),
        const SignupState.failure(ConflictFailure('E-mail já cadastrado.')),
      );
    },
  );
}
