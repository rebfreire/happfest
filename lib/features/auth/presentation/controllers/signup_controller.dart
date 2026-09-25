import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/features/auth/data/auth_providers.dart';
import 'package:happfest/features/auth/presentation/controllers/signup_state.dart';
import 'package:happfest/features/cart/data/cart_providers.dart';
import 'package:happfest/features/cart/presentation/controllers/cart_providers.dart';

final signupControllerProvider =
    NotifierProvider<SignupController, SignupState>(SignupController.new);

class SignupController extends Notifier<SignupState> {
  @override
  SignupState build() => const SignupState.idle();

  Future<void> submit({
    required String name,
    required String email,
    required String password,
    required String cpf,
    required String phone,
  }) async {
    state = const SignupState.loading();

    final useCase = ref.read(signupUseCaseProvider);
    final result = await useCase(
      name: name,
      email: email,
      password: password,
      cpf: cpf,
      phone: phone,
    );

    if (result case Ok()) {
      // Best-effort: associa o carrinho anônimo à conta recém-criada. Uma
      // falha aqui não deve impedir o cadastro de ter sucesso.
      await ref.read(mergeCartUseCaseProvider)();
      ref.invalidate(cartProvider);
    }

    state = switch (result) {
      Ok(:final value) => SignupState.success(value),
      Err(:final failure) => SignupState.failure(failure),
    };
  }
}
