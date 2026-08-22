import 'package:dio/dio.dart';
import 'package:happfest/core/location/cep_address.dart';

/// API pública ViaCEP — resolve rua/bairro/cidade/UF a partir do CEP, sem
/// exigir escolha manual de estado/cidade no caminho feliz. Cliente dio
/// separado: host diferente, sem `Authorization`/base URL da API HappFest.
class ViaCepDataSource {
  ViaCepDataSource([Dio? dio])
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'https://viacep.com.br/ws',
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ),
          );

  final Dio _dio;

  /// `null` quando o CEP não existe ou a busca falha — o chamador deve
  /// cair para o preenchimento manual de estado/cidade.
  Future<CepAddress?> lookup(String cep) async {
    final digitsOnly = cep.replaceAll(RegExp('[^0-9]'), '');
    if (digitsOnly.length != 8) return null;

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/$digitsOnly/json/',
      );
      final data = response.data!;
      if (data['erro'] == true) return null;

      final ibge = data['ibge'] as String?;
      if (ibge == null || ibge.length < 2) return null;
      final cityCode = int.tryParse(ibge);
      final stateCode = int.tryParse(ibge.substring(0, 2));
      if (cityCode == null || stateCode == null) return null;

      return CepAddress(
        street: data['logradouro'] as String? ?? '',
        neighborhood: data['bairro'] as String? ?? '',
        cityName: data['localidade'] as String? ?? '',
        stateAbbreviation: data['uf'] as String? ?? '',
        cityCodigoIbge: cityCode,
        stateCodigoUf: stateCode,
      );
    } on DioException {
      return null;
    }
  }
}
