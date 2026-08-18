import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/features/account/presentation/controllers/account_providers.dart';
import 'package:happfest/features/parties/data/party_providers.dart';
import 'package:happfest/features/parties/domain/entities/party.dart';

/// Depende do `customerId` de `accountContextProvider` — a API exige o id
/// do customer na URL (`GET /customers/{customerId}/parties`).
final partiesProvider = FutureProvider<Result<List<Party>>>((ref) async {
  final contextResult = await ref.watch(accountContextProvider.future);
  return switch (contextResult) {
    Ok(:final value) => ref.watch(getPartiesUseCaseProvider)(value.customerId),
    Err(:final failure) => Err(failure),
  };
});
