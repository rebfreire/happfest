import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:happfest_core/core/error/failure.dart';
import 'package:happfest_core/core/error/result.dart';
import 'package:happfest_core/core/network/paged_response.dart';
import 'package:happfest_design_system/design_system/theme/app_theme.dart';
import 'package:happfest_fornecedor/features/dashboard/data/dashboard_providers.dart';
import 'package:happfest_fornecedor/features/dashboard/domain/entities/sub_order_preview.dart';
import 'package:happfest_fornecedor/features/dashboard/domain/entities/supplier_metrics.dart';
import 'package:happfest_fornecedor/features/dashboard/domain/entities/supplier_profile.dart';
import 'package:happfest_fornecedor/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:happfest_fornecedor/features/dashboard/domain/usecases/get_pending_orders_usecase.dart';
import 'package:happfest_fornecedor/features/dashboard/domain/usecases/get_supplier_metrics_usecase.dart';
import 'package:happfest_fornecedor/features/dashboard/domain/usecases/get_supplier_profile_usecase.dart';
import 'package:happfest_fornecedor/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:happfest_fornecedor/l10n/generated/app_localizations.dart';

class _FakeDashboardRepository implements DashboardRepository {
  _FakeDashboardRepository({
    required this.profile,
    required this.metrics,
    required this.pendingOrders,
  });

  final Result<SupplierProfile> profile;
  final Result<SupplierMetrics> metrics;
  final Result<PagedResponse<SubOrderPreview>> pendingOrders;

  @override
  Future<Result<SupplierProfile>> getProfile() async => profile;

  @override
  Future<Result<SupplierMetrics>> getMetrics() async => metrics;

  @override
  Future<Result<PagedResponse<SubOrderPreview>>> getPendingOrders({
    int page = 0,
    int size = 5,
  }) async => pendingOrders;
}

Widget _wrap({
  required Result<SupplierProfile> profile,
  required Result<SupplierMetrics> metrics,
  required Result<PagedResponse<SubOrderPreview>> pendingOrders,
}) {
  final repository = _FakeDashboardRepository(
    profile: profile,
    metrics: metrics,
    pendingOrders: pendingOrders,
  );

  return ProviderScope(
    overrides: [
      getSupplierProfileUseCaseProvider.overrideWithValue(
        GetSupplierProfileUseCase(repository),
      ),
      getSupplierMetricsUseCaseProvider.overrideWithValue(
        GetSupplierMetricsUseCase(repository),
      ),
      getPendingOrdersUseCaseProvider.overrideWithValue(
        GetPendingOrdersUseCase(repository),
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const DashboardPage(),
    ),
  );
}

void main() {
  const profile = SupplierProfile(
    id: 's1',
    name: 'Doces da Ana',
    tradeName: 'Doces da Ana',
    approvalStatus: SupplierApprovalStatus.approved,
  );
  const metrics = SupplierMetrics(
    acceptanceRatePercent: 92,
    averageRating: 4.8,
    totalReviews: 12,
    acceptedCount: 23,
    totalDecisions: 25,
  );

  testWidgets('shows profile, metrics and pending orders on success', (
    tester,
  ) async {
    const order = SubOrderPreview(
      id: 'aaaaaaaa-1111-2222-3333-444444444444',
      status: SubOrderStatus.pending,
      supplierAmount: 150,
    );
    await tester.pumpWidget(
      _wrap(
        profile: const Ok(profile),
        metrics: const Ok(metrics),
        pendingOrders: const Ok(
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

    expect(find.text('Doces da Ana'), findsWidgets);
    expect(find.text('92%'), findsOneWidget);
    expect(find.text('4.8'), findsOneWidget);
    expect(find.text('Pedido #aaaaaaaa'), findsOneWidget);
  });

  testWidgets('shows an empty state when there are no pending orders', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        profile: const Ok(profile),
        metrics: const Ok(metrics),
        pendingOrders: const Ok(
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

    expect(find.text('Nenhum pedido pendente no momento.'), findsOneWidget);
  });

  testWidgets('shows an error state when the metrics call fails', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        profile: const Ok(profile),
        metrics: const Err(ServerFailure()),
        pendingOrders: const Ok(
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

    expect(find.text(const ServerFailure().message), findsOneWidget);
  });
}
