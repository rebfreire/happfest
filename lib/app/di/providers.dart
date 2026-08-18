import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happfest/core/config/env.dart';
import 'package:happfest/core/network/dio_client.dart';
import 'package:happfest/core/storage/cart_session_storage.dart';
import 'package:happfest/core/storage/token_storage.dart';

final envProvider = Provider<Env>((ref) {
  throw UnimplementedError('envProvider must be overridden in bootstrap.dart');
});

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

final cartSessionStorageProvider = Provider<CartSessionStorage>(
  (ref) => CartSessionStorage(),
);

final dioProvider = Provider<Dio>((ref) {
  final env = ref.watch(envProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  final cartSessionStorage = ref.watch(cartSessionStorageProvider);
  return buildDioClient(env, tokenStorage, cartSessionStorage);
});
