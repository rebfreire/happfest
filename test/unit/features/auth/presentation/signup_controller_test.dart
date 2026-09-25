import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:happfest/core/error/failure.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/features/auth/data/auth_providers.dart';
import 'package:happfest/features/auth/domain/entities/auth_session.dart';
import 'package:happfest/features/auth/domain/entities/profile_type.dart';
import 'package:happfest/features/auth/domain/repositories/auth_repository.dart';
import 'package:happfest/features/auth/domain/usecases/signup_usecase.dart';
import 'package:happfest/features/auth/presentation/controllers/signup_controller.dart';
import 'package:happfest/features/auth/presentation/controllers/signup_state.dart';
import 'package:happfest/features/cart/data/cart_providers.dart';
import 'package:happfest/features/cart/domain/entities/cart.dart';
import 'package:happfest/features/cart/domain/repositories/cart_repository.dart';
import 'package:happfest/features/cart/domain/usecases/merge_cart_usecase.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository(this.result);

  final Result<AuthSession> result;
  int signupCallCount = 0;

  @override
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
  }) async => result;

  @override
  Future<Result<AuthSession>> signup({
    required String name,
    required String email,
    required String password,
    required String cpf,
    required String phone,
  }) async {
    signupCallCount++;
    return result;
  }

  @override
  Future<void> logout() async {}
}

class _FakeCartRepository implements CartRepository {
  int mergeCallCount = 0;

  @override
  Future<Result<Cart>> mergeAnonymousCart() async {
    mergeCallCount++;
    return const Ok(Cart(id: 'cart-1'));
  }

  @override
  Future<Result<Cart>> getCart() async => throw UnimplementedError();

  @override
  Future<Result<Cart>> addItem({
    required String productVariantId,
    required int quantity,
    required double pricingUnitQuantity,
    String? preferredDate,
    String? preferredTime,
  }) async => throw UnimplementedError();

  @override
  Future<Result<Cart>> updateItem({
    required String itemId,
    required int quantity,
    required double pricingUnitQuantity,
  }) async => throw UnimplementedError();

  @override
  Future<Result<Cart>> removeItem(String itemId) async =>
      throw UnimplementedError();
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
    'submit calls signup (which auto-logs in) and merges the anonymous cart '
    'on success',
    () async {
      const session = AuthSession(
        accessToken: 't',
        userId: 'u',
        profileType: ProfileType.customer,
        permissions: [],
      );
      final authRepository = _FakeAuthRepository(const Ok(session));
      final cartRepository = _FakeCartRepository();
      final container = ProviderContainer(
        overrides: [
          signupUseCaseProvider.overrideWithValue(
            SignupUseCase(authRepository),
          ),
          mergeCartUseCaseProvider.overrideWithValue(
            MergeCartUseCase(cartRepository),
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
          );

      expect(
        container.read(signupControllerProvider),
        const SignupState.success(session),
      );
      expect(authRepository.signupCallCount, 1);
      expect(cartRepository.mergeCallCount, 1);
    },
  );

  test(
    'submit transitions to failure on Err result without merging the cart '
    '(e.g. email already registered)',
    () async {
      final cartRepository = _FakeCartRepository();
      final container = ProviderContainer(
        overrides: [
          signupUseCaseProvider.overrideWithValue(
            SignupUseCase(
              _FakeAuthRepository(
                const Err(ConflictFailure('E-mail já cadastrado.')),
              ),
            ),
          ),
          mergeCartUseCaseProvider.overrideWithValue(
            MergeCartUseCase(cartRepository),
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
          );

      expect(
        container.read(signupControllerProvider),
        const SignupState.failure(ConflictFailure('E-mail já cadastrado.')),
      );
      expect(cartRepository.mergeCallCount, 0);
    },
  );
}
