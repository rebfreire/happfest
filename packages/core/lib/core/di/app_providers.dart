import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happfest_core/core/config/env.dart';
import 'package:happfest_core/core/network/dio_client.dart';
import 'package:happfest_core/core/storage/token_storage.dart';

/// Providers de infraestrutura compartilhados por todos os apps do monorepo
/// (ver AGENTS.md seção 2.1). `envProvider` é sobrescrito em cada
/// `bootstrap.dart` com o [Env] do flavor daquele app.

final envProvider = Provider<Env>((ref) {
  throw UnimplementedError('envProvider must be overridden in bootstrap.dart');
});

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

final dioProvider = Provider<Dio>((ref) {
  final env = ref.watch(envProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  return buildDioClient(env, tokenStorage);
});
