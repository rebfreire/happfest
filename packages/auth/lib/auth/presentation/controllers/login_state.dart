import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:happfest_auth/auth/domain/entities/auth_session.dart';
import 'package:happfest_core/core/error/failure.dart';

part 'login_state.freezed.dart';

@freezed
sealed class LoginState with _$LoginState {
  const factory LoginState.idle() = LoginIdle;
  const factory LoginState.loading() = LoginLoading;
  const factory LoginState.success(AuthSession session) = LoginSuccess;
  const factory LoginState.failure(Failure failure) = LoginFailure;
}
