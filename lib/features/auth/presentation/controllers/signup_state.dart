import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:happfest/core/error/failure.dart';
import 'package:happfest/features/auth/domain/entities/auth_session.dart';

part 'signup_state.freezed.dart';

@freezed
sealed class SignupState with _$SignupState {
  const factory SignupState.idle() = SignupIdle;
  const factory SignupState.loading() = SignupLoading;
  const factory SignupState.success(AuthSession session) = SignupSuccess;
  const factory SignupState.failure(Failure failure) = SignupFailure;
}
