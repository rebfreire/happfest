import 'package:dio/dio.dart';
import 'package:happfest/features/auth/data/dto/login_request_dto.dart';
import 'package:happfest/features/auth/data/dto/login_response_dto.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<LoginResponseDto> login(LoginRequestDto request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/mobile/login',
      data: request.toJson(),
    );
    return LoginResponseDto.fromJson(response.data!);
  }

  /// A resposta tem o mesmo formato do login — ambos os tokens (access e
  /// refresh) devem ser substituídos pelos valores novos.
  Future<LoginResponseDto> refresh(String refreshToken) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/mobile/refresh',
      data: {'refreshToken': refreshToken},
    );
    return LoginResponseDto.fromJson(response.data!);
  }
}
