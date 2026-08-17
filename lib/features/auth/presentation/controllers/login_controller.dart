import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/features/auth/data/auth_providers.dart';
import 'package:happfest/features/auth/presentation/controllers/login_state.dart';

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

    state = switch (result) {
      Ok(:final value) => LoginState.success(value),
      Err(:final failure) => LoginState.failure(failure),
    };
  }
}
