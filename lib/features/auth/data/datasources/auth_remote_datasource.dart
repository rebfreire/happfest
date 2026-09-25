import 'package:dio/dio.dart';
import 'package:happfest/features/auth/data/dto/login_request_dto.dart';
import 'package:happfest/features/auth/data/dto/login_response_dto.dart';
import 'package:happfest/features/auth/data/dto/signup_request_dto.dart';

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

  /// `POST /customers` — cadastro público, sem autenticação. Não retorna
  /// tokens; o login em seguida (mesmas credenciais) é responsabilidade do
  /// repositório/controller.
  Future<void> signup(SignupRequestDto request) {
    return _dio.post<Map<String, dynamic>>(
      '/customers',
      data: request.toJson(),
    );
  }

  /// `POST /auth/recuperar-senha?email=...` — dispara o e-mail de
  /// recuperação de senha (link com token, tratado fora do app). Público,
  /// sem autenticação.
  Future<void> requestPasswordReset(String email) {
    return _dio.post<void>(
      '/auth/recuperar-senha',
      queryParameters: {'email': email},
    );
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
