import 'package:happfest/features/auth/data/dto/login_response_dto.dart';
import 'package:happfest/features/auth/domain/entities/auth_session.dart';
import 'package:happfest/features/auth/domain/entities/profile_type.dart';

extension LoginResponseDtoMapper on LoginResponseDto {
  /// [token] é passado à parte porque [LoginResponseDto.token] é nullable
  /// — o chamador já validou que não é nulo antes de montar a entidade.
  AuthSession toEntity(String token) {
    return AuthSession(
      token: token,
      userId: userId,
      profileType: profileType.toEntity(),
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
