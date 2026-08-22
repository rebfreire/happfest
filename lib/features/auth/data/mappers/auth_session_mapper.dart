import 'package:happfest/features/auth/data/dto/login_response_dto.dart';
import 'package:happfest/features/auth/domain/entities/auth_session.dart';
import 'package:happfest/features/auth/domain/entities/profile_type.dart';

extension LoginResponseDtoMapper on LoginResponseDto {
  /// [accessToken] e [userId] são passados à parte porque são nullable no
  /// DTO — o chamador já validou que não são nulos antes de montar a
  /// entidade.
  AuthSession toEntity({required String accessToken, required String userId}) {
    return AuthSession(
      accessToken: accessToken,
      userId: userId,
      profileType: (profileType ?? ProfileTypeDto.customer).toEntity(),
      permissions: permissions,
    );
  }
}

extension ProfileTypeDtoMapper on ProfileTypeDto {
  ProfileType toEntity() {
    return switch (this) {
      ProfileTypeDto.customer => ProfileType.customer,
      ProfileTypeDto.supplier => ProfileType.supplier,
      ProfileTypeDto.franchisee => ProfileType.franchisee,
      ProfileTypeDto.admin => ProfileType.admin,
    };
  }
}
