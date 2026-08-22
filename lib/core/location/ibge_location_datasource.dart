import 'package:dio/dio.dart';
import 'package:happfest/core/location/brazilian_location.dart';

/// API pública do IBGE para estados/municípios — usada só para resolver
/// `stateCodigoUf`/`cityCodigoIbge`, exigidos por `CustomerAddressRequest`
/// e `PartyRequest` mas que a API HappFest não expõe busca própria. Cliente
/// dio separado: host diferente, sem `Authorization`/base URL da API.
class IbgeLocationDataSource {
  IbgeLocationDataSource([Dio? dio])
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'https://servicodados.ibge.gov.br/api/v1/localidades',
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ),
          );

  final Dio _dio;

  Future<List<BrazilianState>> getStates() async {
    final response = await _dio.get<List<dynamic>>(
      '/estados',
      queryParameters: {'orderBy': 'nome'},
    );
    return response.data!
        .cast<Map<String, dynamic>>()
        .map(
          (json) => BrazilianState(
            code: json['id'] as int,
            abbreviation: json['sigla'] as String? ?? '',
            name: json['nome'] as String? ?? '',
          ),
        )
        .toList();
  }

  Future<List<BrazilianCity>> getCities(int stateCode) async {
    final response = await _dio.get<List<dynamic>>(
      '/estados/$stateCode/municipios',
    );
    final cities =
        response.data!
            .cast<Map<String, dynamic>>()
            .map(
              (json) => BrazilianCity(
                code: json['id'] as int,
                name: json['nome'] as String? ?? '',
              ),
            )
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));
    return cities;
  }
}
