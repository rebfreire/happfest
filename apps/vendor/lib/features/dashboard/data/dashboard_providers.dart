import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happfest_core/core/di/app_providers.dart';
import 'package:happfest_fornecedor/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:happfest_fornecedor/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:happfest_fornecedor/features/dashboard/domain/usecases/get_pending_orders_usecase.dart';
import 'package:happfest_fornecedor/features/dashboard/domain/usecases/get_supplier_metrics_usecase.dart';
import 'package:happfest_fornecedor/features/dashboard/domain/usecases/get_supplier_profile_usecase.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(ref.watch(dioProvider));
});

final getSupplierProfileUseCaseProvider = Provider<GetSupplierProfileUseCase>(
  (ref) => GetSupplierProfileUseCase(ref.watch(dashboardRepositoryProvider)),
);

final getSupplierMetricsUseCaseProvider = Provider<GetSupplierMetricsUseCase>(
  (ref) => GetSupplierMetricsUseCase(ref.watch(dashboardRepositoryProvider)),
);

final getPendingOrdersUseCaseProvider = Provider<GetPendingOrdersUseCase>(
  (ref) => GetPendingOrdersUseCase(ref.watch(dashboardRepositoryProvider)),
);
