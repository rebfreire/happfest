import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:happfest/core/error/failure.dart';

part 'signup_state.freezed.dart';

@freezed
sealed class SignupState with _$SignupState {
  const factory SignupState.idle() = SignupIdle;
  const factory SignupState.loading() = SignupLoading;

  /// O cadastro (`POST /customers`) não retorna tokens nem faz login
  /// automático — a API passou a exigir verificação de e-mail antes de
  /// permitir login, então o sucesso aqui é só o cadastro em si.
  /// `SignupPage` mostra a instrução de verificar o e-mail e navega para
  /// `/login`.
  const factory SignupState.success() = SignupSuccess;
  const factory SignupState.failure(Failure failure) = SignupFailure;
}
