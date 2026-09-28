import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happfest_core/core/error/result.dart';
import 'package:happfest_core/core/network/paged_response.dart';
import 'package:happfest_fornecedor/features/dashboard/data/dashboard_providers.dart';
import 'package:happfest_fornecedor/features/dashboard/domain/entities/sub_order_preview.dart';
import 'package:happfest_fornecedor/features/dashboard/domain/entities/supplier_metrics.dart';
import 'package:happfest_fornecedor/features/dashboard/domain/entities/supplier_profile.dart';

final supplierProfileProvider = FutureProvider<Result<SupplierProfile>>((
  ref,
) {
  return ref.watch(getSupplierProfileUseCaseProvider)();
});

final supplierMetricsProvider = FutureProvider<Result<SupplierMetrics>>((
  ref,
) {
  return ref.watch(getSupplierMetricsUseCaseProvider)();
});

final pendingOrdersProvider =
    FutureProvider<Result<PagedResponse<SubOrderPreview>>>((ref) {
      return ref.watch(getPendingOrdersUseCaseProvider)();
    });
