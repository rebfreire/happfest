import 'package:flutter_test/flutter_test.dart';
import 'package:happfest_core/core/error/failure.dart';
import 'package:happfest_core/core/error/result.dart';
import 'package:happfest_core/core/network/paged_response.dart';
import 'package:happfest_fornecedor/features/orders/domain/entities/sub_order.dart';
import 'package:happfest_fornecedor/features/orders/domain/entities/sub_order_status.dart';
import 'package:happfest_fornecedor/features/orders/domain/repositories/orders_repository.dart';
import 'package:happfest_fornecedor/features/orders/domain/usecases/accept_order_usecase.dart';
import 'package:happfest_fornecedor/features/orders/domain/usecases/cancel_order_usecase.dart';
import 'package:happfest_fornecedor/features/orders/domain/usecases/deliver_order_usecase.dart';
import 'package:happfest_fornecedor/features/orders/domain/usecases/get_order_detail_usecase.dart';
import 'package:happfest_fornecedor/features/orders/domain/usecases/list_orders_usecase.dart';
import 'package:happfest_fornecedor/features/orders/domain/usecases/reject_order_usecase.dart';
import 'package:mocktail/mocktail.dart';

class _MockOrdersRepository extends Mock implements OrdersRepository {}

void main() {
  late _MockOrdersRepository repository;

  setUp(() {
    repository = _MockOrdersRepository();
  });

  test('ListOrdersUseCase forwards the status filter', () async {
    when(
      () => repository.list(status: SubOrderStatus.pending),
    ).thenAnswer(
      (_) async => const Ok(
        PagedResponse(
          content: [],
          page: 0,
          totalPages: 0,
          totalElements: 0,
          isLast: true,
        ),
      ),
    );

    final result = await ListOrdersUseCase(repository)(
      status: SubOrderStatus.pending,
    );

    expect(result, isA<Ok<PagedResponse<SubOrder>>>());
    verify(
      () => repository.list(status: SubOrderStatus.pending),
    ).called(1);
  });

  test('GetOrderDetailUseCase returns the repository result', () async {
    const order = SubOrder(
      id: 'o1',
      status: SubOrderStatus.pending,
      subtotal: 100,
      supplierAmount: 90,
      items: [],
    );
    when(
      () => repository.getById('o1'),
    ).thenAnswer((_) async => const Ok(order));

    final result = await GetOrderDetailUseCase(repository)('o1');

    expect(result, const Ok(order));
  });

  test('AcceptOrderUseCase delegates to the repository', () async {
    when(() => repository.accept('o1')).thenAnswer((_) async => const Ok(null));

    final result = await AcceptOrderUseCase(repository)('o1');

    expect(result, const Ok<void>(null));
    verify(() => repository.accept('o1')).called(1);
  });

  test(
    'RejectOrderUseCase forwards the reason and propagates a failure',
    () async {
      when(
        () => repository.reject('o1', reason: 'fora do horário'),
      ).thenAnswer((_) async => const Err(ServerFailure()));

      final result = await RejectOrderUseCase(repository)(
        'o1',
        reason: 'fora do horário',
      );

      expect(result, isA<Err<void>>());
    },
  );

  test('DeliverOrderUseCase delegates to the repository', () async {
    when(
      () => repository.deliver('o1'),
    ).thenAnswer((_) async => const Ok(null));

    final result = await DeliverOrderUseCase(repository)('o1');

    expect(result, const Ok<void>(null));
  });

  test('CancelOrderUseCase delegates to the repository', () async {
    when(
      () => repository.cancel('o1'),
    ).thenAnswer((_) async => const Ok(null));

    final result = await CancelOrderUseCase(repository)('o1');

    expect(result, const Ok<void>(null));
  });
}
