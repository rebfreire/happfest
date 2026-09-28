import 'package:flutter_test/flutter_test.dart';
import 'package:happfest_core/core/error/failure.dart';
import 'package:happfest_core/core/error/result.dart';
import 'package:happfest_core/core/network/paged_response.dart';
import 'package:happfest_fornecedor/features/dashboard/domain/entities/sub_order_preview.dart';
import 'package:happfest_fornecedor/features/dashboard/domain/entities/supplier_metrics.dart';
import 'package:happfest_fornecedor/features/dashboard/domain/entities/supplier_profile.dart';
import 'package:happfest_fornecedor/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:happfest_fornecedor/features/dashboard/domain/usecases/get_pending_orders_usecase.dart';
import 'package:happfest_fornecedor/features/dashboard/domain/usecases/get_supplier_metrics_usecase.dart';
import 'package:happfest_fornecedor/features/dashboard/domain/usecases/get_supplier_profile_usecase.dart';
import 'package:mocktail/mocktail.dart';

class _MockDashboardRepository extends Mock implements DashboardRepository {}

void main() {
  late _MockDashboardRepository repository;

  setUp(() {
    repository = _MockDashboardRepository();
  });

  test('GetSupplierProfileUseCase returns the repository result', () async {
    const profile = SupplierProfile(
      id: 's1',
      name: 'Doces da Ana',
      approvalStatus: SupplierApprovalStatus.approved,
    );
    when(
      () => repository.getProfile(),
    ).thenAnswer((_) async => const Ok(profile));

    final result = await GetSupplierProfileUseCase(repository)();

    expect(result, const Ok(profile));
  });

  test('GetSupplierMetricsUseCase returns the repository result', () async {
    const metrics = SupplierMetrics(
      acceptanceRatePercent: 92,
      averageRating: 4.8,
      totalReviews: 12,
      acceptedCount: 23,
      totalDecisions: 25,
    );
    when(
      () => repository.getMetrics(),
    ).thenAnswer((_) async => const Ok(metrics));

    final result = await GetSupplierMetricsUseCase(repository)();

    expect(result, const Ok(metrics));
  });

  test(
    'GetPendingOrdersUseCase forwards paging and propagates a failure',
    () async {
      when(
        () => repository.getPendingOrders(),
      ).thenAnswer((_) async => const Err(ServerFailure()));

      final result = await GetPendingOrdersUseCase(repository)();

      expect(result, isA<Err<PagedResponse<SubOrderPreview>>>());
      verify(() => repository.getPendingOrders()).called(1);
    },
  );
}
