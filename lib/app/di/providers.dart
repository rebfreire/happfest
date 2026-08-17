import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happfest/core/config/env.dart';
import 'package:happfest/core/network/dio_client.dart';
import 'package:happfest/core/storage/token_storage.dart';

final envProvider = Provider<Env>((ref) {
  throw UnimplementedError('envProvider must be overridden in bootstrap.dart');
});

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

final dioProvider = Provider<Dio>((ref) {
  final env = ref.watch(envProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  return buildDioClient(env, tokenStorage);
});
