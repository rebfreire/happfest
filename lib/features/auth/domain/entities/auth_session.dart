import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:happfest/features/auth/domain/entities/profile_type.dart';

part 'auth_session.freezed.dart';

@freezed
abstract class AuthSession with _$AuthSession {
  const factory AuthSession({
    required String accessToken,
    required String userId,
    required ProfileType profileType,
    required List<String> permissions,
  }) = _AuthSession;
}
