import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happfest/app/di/providers.dart';
import 'package:happfest/features/parties/data/repositories/party_repository_impl.dart';
import 'package:happfest/features/parties/domain/repositories/party_repository.dart';
import 'package:happfest/features/parties/domain/usecases/get_parties_usecase.dart';

final partyRepositoryProvider = Provider<PartyRepository>((ref) {
  return PartyRepositoryImpl(ref.watch(dioProvider));
});

final getPartiesUseCaseProvider = Provider<GetPartiesUseCase>((ref) {
  return GetPartiesUseCase(ref.watch(partyRepositoryProvider));
});
