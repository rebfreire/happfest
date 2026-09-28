import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:happfest_core/core/error/failure.dart';
import 'package:happfest_core/core/error/result.dart';
import 'package:happfest_core/core/network/paged_response.dart';
import 'package:happfest_design_system/design_system/theme/app_theme.dart';
import 'package:happfest_fornecedor/features/orders/data/orders_providers.dart';
import 'package:happfest_fornecedor/features/orders/domain/entities/sub_order.dart';
import 'package:happfest_fornecedor/features/orders/domain/entities/sub_order_item.dart';
import 'package:happfest_fornecedor/features/orders/domain/entities/sub_order_status.dart';
import 'package:happfest_fornecedor/features/orders/domain/repositories/orders_repository.dart';
import 'package:happfest_fornecedor/features/orders/domain/usecases/accept_order_usecase.dart';
import 'package:happfest_fornecedor/features/orders/domain/usecases/cancel_order_usecase.dart';
import 'package:happfest_fornecedor/features/orders/domain/usecases/deliver_order_usecase.dart';
import 'package:happfest_fornecedor/features/orders/domain/usecases/get_order_detail_usecase.dart';
import 'package:happfest_fornecedor/features/orders/domain/usecases/reject_order_usecase.dart';
import 'package:happfest_fornecedor/features/orders/presentation/pages/order_detail_page.dart';

const _order = SubOrder(
  id: 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee',
  status: SubOrderStatus.pending,
  subtotal: 100,
  supplierAmount: 90,
  items: [
    SubOrderItem(
      id: 'i1',
      productName: 'Bolo de chocolate',
      productType: SubOrderProductType.physical,
      quantity: 1,
      unitPrice: 100,
      lineTotal: 100,
    ),
  ],
);

class _ScriptedOrdersRepository implements OrdersRepository {
  _ScriptedOrdersRepository({this.acceptResult = const Ok(null)});

  final Result<void> acceptResult;
  bool acceptCalled = false;

  @override
  Future<Result<SubOrder>> getById(String id) async => const Ok(_order);

  @override
  Future<Result<void>> accept(String id) async {
    acceptCalled = true;
    return acceptResult;
  }

  @override
  Future<Result<void>> reject(String id, {String? reason}) =>
      throw UnimplementedError();

  @override
  Future<Result<void>> deliver(String id) => throw UnimplementedError();

  @override
  Future<Result<void>> cancel(String id, {String? reason}) =>
      throw UnimplementedError();

  @override
  Future<Result<PagedResponse<SubOrder>>> list({
    SubOrderStatus? status,
    int page = 0,
    int size = 20,
  }) => throw UnimplementedError();
}

Widget _wrap(_ScriptedOrdersRepository repository) {
  final router = GoRouter(
    initialLocation: '/orders/${_order.id}',
    routes: [
      GoRoute(
        path: '/orders',
        builder: (context, state) => const Scaffold(body: Text('orders')),
      ),
      GoRoute(
        path: '/orders/:id',
        builder: (context, state) =>
            OrderDetailPage(orderId: state.pathParameters['id']!),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      getOrderDetailUseCaseProvider.overrideWithValue(
        GetOrderDetailUseCase(repository),
      ),
      acceptOrderUseCaseProvider.overrideWithValue(
        AcceptOrderUseCase(repository),
      ),
      rejectOrderUseCaseProvider.overrideWithValue(
        RejectOrderUseCase(repository),
      ),
      deliverOrderUseCaseProvider.overrideWithValue(
        DeliverOrderUseCase(repository),
      ),
      cancelOrderUseCaseProvider.overrideWithValue(
        CancelOrderUseCase(repository),
      ),
    ],
    child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
  );
}

void main() {
  testWidgets(
    'shows order items and accept/reject/cancel actions when pending',
    (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(_ScriptedOrdersRepository()));
      await tester.pumpAndSettle();

      expect(find.text('1x Bolo de chocolate'), findsOneWidget);
      expect(find.text('Aceitar pedido'), findsOneWidget);
      expect(find.text('Recusar'), findsOneWidget);
      expect(find.text('Cancelar pedido'), findsOneWidget);
    },
  );

  testWidgets('accepting the order calls the repository and navigates back', (
    tester,
  ) async {
    final repository = _ScriptedOrdersRepository();
    await tester.pumpWidget(_wrap(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Aceitar pedido'));
    await tester.pumpAndSettle();

    expect(repository.acceptCalled, isTrue);
    expect(find.text('orders'), findsOneWidget);
  });

  testWidgets('shows a snackbar when accepting the order fails', (
    tester,
  ) async {
    final repository = _ScriptedOrdersRepository(
      acceptResult: const Err(ServerFailure()),
    );
    await tester.pumpWidget(_wrap(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Aceitar pedido'));
    await tester.pumpAndSettle();

    expect(repository.acceptCalled, isTrue);
    expect(find.text(const ServerFailure().message), findsOneWidget);
  });
}
