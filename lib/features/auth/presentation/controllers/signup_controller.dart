import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/features/auth/data/auth_providers.dart';
import 'package:happfest/features/auth/presentation/controllers/signup_state.dart';

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
    state = const SignupState.loading();

    final useCase = ref.read(signupUseCaseProvider);
    final result = await useCase(
      name: name,
      email: email,
      password: password,
      cpf: cpf,
      phone: phone,
      birthDate: birthDate,
      incomeValue: incomeValue,
      street: street,
      number: number,
      neighborhood: neighborhood,
      cityCodigoIbge: cityCodigoIbge,
      stateCodigoUf: stateCodigoUf,
      zipCode: zipCode,
      complement: complement,
    );

    state = switch (result) {
      Ok() => const SignupState.success(),
      Err(:final failure) => SignupState.failure(failure),
    };
  }
}
