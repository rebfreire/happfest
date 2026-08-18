import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/features/auth/data/auth_providers.dart';
import 'package:happfest/features/auth/presentation/controllers/login_state.dart';
import 'package:happfest/features/cart/data/cart_providers.dart';
import 'package:happfest/features/cart/presentation/controllers/cart_providers.dart';

final loginControllerProvider = NotifierProvider<LoginController, LoginState>(
  LoginController.new,
);

class LoginController extends Notifier<LoginState> {
  @override
  LoginState build() => const LoginState.idle();

  Future<void> submit({required String email, required String password}) async {
    state = const LoginState.loading();

    final useCase = ref.read(loginUseCaseProvider);
    final result = await useCase(email: email, password: password);

    if (result case Ok()) {
      // Best-effort: associa o carrinho anônimo à conta recém-logada. Uma
      // falha aqui não deve impedir o login de ter sucesso.
      await ref.read(mergeCartUseCaseProvider)();
      ref.invalidate(cartProvider);
    }

    state = switch (result) {
      Ok(:final value) => LoginState.success(value),
      Err(:final failure) => LoginState.failure(failure),
    };
  }
}
