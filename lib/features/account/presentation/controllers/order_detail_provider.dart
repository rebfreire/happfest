import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/features/account/data/account_providers.dart';
import 'package:happfest/features/account/domain/entities/order_detail.dart';

// AutoDisposeFutureProviderFamily não é exportado publicamente pelo
// flutter_riverpod, então o tipo não pode ser anotado explicitamente aqui.
// ignore: specify_nonobvious_property_types
final orderDetailProvider = FutureProvider.autoDispose
    .family<Result<OrderDetail>, String>((ref, orderId) {
      return ref.watch(getOrderUseCaseProvider)(orderId);
    });
