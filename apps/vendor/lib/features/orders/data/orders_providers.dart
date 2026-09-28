import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happfest_core/core/di/app_providers.dart';
import 'package:happfest_fornecedor/features/orders/data/repositories/orders_repository_impl.dart';
import 'package:happfest_fornecedor/features/orders/domain/repositories/orders_repository.dart';
import 'package:happfest_fornecedor/features/orders/domain/usecases/accept_order_usecase.dart';
import 'package:happfest_fornecedor/features/orders/domain/usecases/cancel_order_usecase.dart';
import 'package:happfest_fornecedor/features/orders/domain/usecases/deliver_order_usecase.dart';
import 'package:happfest_fornecedor/features/orders/domain/usecases/get_order_detail_usecase.dart';
import 'package:happfest_fornecedor/features/orders/domain/usecases/list_orders_usecase.dart';
import 'package:happfest_fornecedor/features/orders/domain/usecases/reject_order_usecase.dart';

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  return OrdersRepositoryImpl(ref.watch(dioProvider));
});

final listOrdersUseCaseProvider = Provider<ListOrdersUseCase>(
  (ref) => ListOrdersUseCase(ref.watch(ordersRepositoryProvider)),
);

final getOrderDetailUseCaseProvider = Provider<GetOrderDetailUseCase>(
  (ref) => GetOrderDetailUseCase(ref.watch(ordersRepositoryProvider)),
);

final acceptOrderUseCaseProvider = Provider<AcceptOrderUseCase>(
  (ref) => AcceptOrderUseCase(ref.watch(ordersRepositoryProvider)),
);

final rejectOrderUseCaseProvider = Provider<RejectOrderUseCase>(
  (ref) => RejectOrderUseCase(ref.watch(ordersRepositoryProvider)),
);

final deliverOrderUseCaseProvider = Provider<DeliverOrderUseCase>(
  (ref) => DeliverOrderUseCase(ref.watch(ordersRepositoryProvider)),
);

final cancelOrderUseCaseProvider = Provider<CancelOrderUseCase>(
  (ref) => CancelOrderUseCase(ref.watch(ordersRepositoryProvider)),
);
