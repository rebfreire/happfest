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
import 'package:happfest_fornecedor/features/orders/domain/entities/sub_order_status.dart';
import 'package:happfest_fornecedor/features/orders/domain/repositories/orders_repository.dart';
import 'package:happfest_fornecedor/features/orders/domain/usecases/list_orders_usecase.dart';
import 'package:happfest_fornecedor/features/orders/presentation/pages/orders_page.dart';

class _FakeOrdersRepository implements OrdersRepository {
  _FakeOrdersRepository(this.result);

  final Result<PagedResponse<SubOrder>> result;

  @override
  Future<Result<PagedResponse<SubOrder>>> list({
    SubOrderStatus? status,
    int page = 0,
    int size = 20,
  }) async => result;

  @override
  Future<Result<SubOrder>> getById(String id) => throw UnimplementedError();

  @override
  Future<Result<void>> accept(String id) => throw UnimplementedError();

  @override
  Future<Result<void>> reject(String id, {String? reason}) =>
      throw UnimplementedError();

  @override
  Future<Result<void>> deliver(String id) => throw UnimplementedError();

  @override
  Future<Result<void>> cancel(String id, {String? reason}) =>
      throw UnimplementedError();
}

Widget _wrap(Result<PagedResponse<SubOrder>> result) {
  final router = GoRouter(
    initialLocation: '/orders',
    routes: [
      GoRoute(path: '/orders', builder: (context, state) => const OrdersPage()),
      GoRoute(
        path: '/orders/:id',
        builder: (context, state) => const Scaffold(body: Text('detail')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      listOrdersUseCaseProvider.overrideWithValue(
        ListOrdersUseCase(_FakeOrdersRepository(result)),
      ),
    ],
    child: MaterialApp.router(
      theme: AppTheme.light,
      routerConfig: router,
    ),
  );
}

void main() {
  testWidgets('shows the order list on success', (tester) async {
    const order = SubOrder(
      id: 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee',
      status: SubOrderStatus.pending,
      subtotal: 100,
      supplierAmount: 90,
      items: [],
    );
    await tester.pumpWidget(
      _wrap(
        const Ok(
          PagedResponse(
            content: [order],
            page: 0,
            totalPages: 1,
            totalElements: 1,
            isLast: true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pedido #aaaaaaaa'), findsOneWidget);
  });

  testWidgets('shows an empty state when there are no orders', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const Ok(
          PagedResponse(
            content: [],
            page: 0,
            totalPages: 0,
            totalElements: 0,
            isLast: true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nenhum pedido encontrado.'), findsOneWidget);
  });

  testWidgets('shows an error state when the list call fails', (tester) async {
    await tester.pumpWidget(_wrap(const Err(ServerFailure())));
    await tester.pumpAndSettle();

    expect(find.text(const ServerFailure().message), findsOneWidget);
  });
}
