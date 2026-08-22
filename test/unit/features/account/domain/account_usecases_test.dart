import 'package:flutter_test/flutter_test.dart';
import 'package:happfest/core/error/failure.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/core/network/paged_response.dart';
import 'package:happfest/features/account/domain/entities/customer_account.dart';
import 'package:happfest/features/account/domain/entities/customer_address.dart';
import 'package:happfest/features/account/domain/entities/order_detail.dart';
import 'package:happfest/features/account/domain/entities/order_summary.dart';
import 'package:happfest/features/account/domain/repositories/account_repository.dart';
import 'package:happfest/features/account/domain/usecases/create_address_usecase.dart';
import 'package:happfest/features/account/domain/usecases/get_account_context_usecase.dart';
import 'package:happfest/features/account/domain/usecases/get_addresses_usecase.dart';
import 'package:happfest/features/account/domain/usecases/get_order_usecase.dart';
import 'package:happfest/features/account/domain/usecases/get_orders_usecase.dart';
import 'package:mocktail/mocktail.dart';

class _MockAccountRepository extends Mock implements AccountRepository {}

void main() {
  late _MockAccountRepository repository;

  setUp(() {
    repository = _MockAccountRepository();
  });

  test(
    'GetAccountContextUseCase returns the account from the repository',
    () async {
      const account = CustomerAccount(customerId: 'c1', activated: true);
      when(
        () => repository.getContext(),
      ).thenAnswer((_) async => const Ok(account));

      final result = await GetAccountContextUseCase(repository)();

      expect(result, const Ok(account));
    },
  );

  test(
    'GetAddressesUseCase returns the addresses from the repository',
    () async {
      const addresses = [
        CustomerAddress(
          id: 'a1',
          label: 'Casa',
          street: 'Rua 1',
          number: '10',
          neighborhood: 'Centro',
          zipCode: '00000000',
        ),
      ];
      when(
        () => repository.getAddresses(),
      ).thenAnswer((_) async => const Ok(addresses));

      final result = await GetAddressesUseCase(repository)();

      expect(result, const Ok(addresses));
    },
  );

  test(
    'GetOrdersUseCase forwards pagination and propagates failures',
    () async {
      when(
        () => repository.getOrders(page: 1, size: 10),
      ).thenAnswer((_) async => const Err(ServerFailure()));

      final result = await GetOrdersUseCase(repository)(page: 1, size: 10);

      expect(result, isA<Err<PagedResponse<OrderSummary>>>());
      verify(() => repository.getOrders(page: 1, size: 10)).called(1);
    },
  );

  test(
    'CreateAddressUseCase forwards the fields and returns the created address',
    () async {
      const created = CustomerAddress(
        id: 'a1',
        label: 'Casa',
        street: 'Rua 1',
        number: '10',
        neighborhood: 'Centro',
        zipCode: '01001000',
      );
      when(
        () => repository.createAddress(
          label: any(named: 'label'),
          street: any(named: 'street'),
          number: any(named: 'number'),
          neighborhood: any(named: 'neighborhood'),
          cityCodigoIbge: any(named: 'cityCodigoIbge'),
          stateCodigoUf: any(named: 'stateCodigoUf'),
          zipCode: any(named: 'zipCode'),
          complement: any(named: 'complement'),
        ),
      ).thenAnswer((_) async => const Ok(created));

      final result = await CreateAddressUseCase(repository)(
        label: 'Casa',
        street: 'Rua 1',
        number: '10',
        neighborhood: 'Centro',
        cityCodigoIbge: 3550308,
        stateCodigoUf: 35,
        zipCode: '01001000',
      );

      expect(result, const Ok(created));
      verify(
        () => repository.createAddress(
          label: 'Casa',
          street: 'Rua 1',
          number: '10',
          neighborhood: 'Centro',
          cityCodigoIbge: 3550308,
          stateCodigoUf: 35,
          zipCode: '01001000',
        ),
      ).called(1);
    },
  );

  test('GetOrderUseCase returns the order from the repository', () async {
    const order = OrderDetail(id: 'o1', totalAmount: 200);
    when(
      () => repository.getOrder('o1'),
    ).thenAnswer((_) async => const Ok(order));

    final result = await GetOrderUseCase(repository)('o1');

    expect(result, const Ok(order));
    verify(() => repository.getOrder('o1')).called(1);
  });
}
