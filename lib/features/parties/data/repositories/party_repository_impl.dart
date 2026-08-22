import 'package:dio/dio.dart';
import 'package:happfest/core/error/failure.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/core/network/api_exception.dart';
import 'package:happfest/features/parties/data/dto/party_request_dto.dart';
import 'package:happfest/features/parties/data/dto/party_response_dto.dart';
import 'package:happfest/features/parties/data/mappers/party_mapper.dart';
import 'package:happfest/features/parties/domain/entities/party.dart';
import 'package:happfest/features/parties/domain/repositories/party_repository.dart';
import 'package:intl/intl.dart';

class PartyRepositoryImpl implements PartyRepository {
  const PartyRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<Result<List<Party>>> getParties(String customerId) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/customers/$customerId/parties',
      );
      final parties = response.data!
          .cast<Map<String, dynamic>>()
          .map(PartyResponseDto.fromJson)
          .map((dto) => dto.toEntity())
          .toList();
      return Ok(parties);
    } on DioException catch (exception) {
      final error = exception.error;
      final failure = error is ApiException
          ? error.failure
          : const UnknownFailure();
      return Err(failure);
    }
  }

  @override
  Future<Result<Party>> createParty({
    required String customerId,
    required String street,
    required String number,
    required String neighborhood,
    required int cityCodigoIbge,
    required int stateCodigoUf,
    required String zipCode,
    required DateTime startDate,
    required DateTime endDate,
    required int guestCount,
    String? name,
    String? complement,
  }) async {
    try {
      final dateFormat = DateFormat('yyyy-MM-dd');
      final request = PartyRequestDto(
        name: name,
        street: street,
        number: number,
        complement: complement,
        neighborhood: neighborhood,
        cityCodigoIbge: cityCodigoIbge,
        stateCodigoUf: stateCodigoUf,
        zipCode: zipCode,
        startDate: dateFormat.format(startDate),
        endDate: dateFormat.format(endDate),
        guestCount: guestCount,
      );
      final response = await _dio.post<Map<String, dynamic>>(
        '/customers/$customerId/parties',
        data: request.toJson(),
      );
      final dto = PartyResponseDto.fromJson(response.data!);
      return Ok(dto.toEntity());
    } on DioException catch (exception) {
      final error = exception.error;
      final failure = error is ApiException
          ? error.failure
          : const UnknownFailure();
      return Err(failure);
    }
  }
}
