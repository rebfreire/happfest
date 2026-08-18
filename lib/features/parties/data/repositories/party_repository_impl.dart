import 'package:dio/dio.dart';
import 'package:happfest/core/error/failure.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/core/network/api_exception.dart';
import 'package:happfest/features/parties/data/dto/party_response_dto.dart';
import 'package:happfest/features/parties/data/mappers/party_mapper.dart';
import 'package:happfest/features/parties/domain/entities/party.dart';
import 'package:happfest/features/parties/domain/repositories/party_repository.dart';

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
}
