import 'package:happfest_core/core/error/result.dart';
import 'package:happfest_core/core/network/paged_response.dart';
import 'package:happfest_fornecedor/features/dashboard/domain/entities/sub_order_preview.dart';
import 'package:happfest_fornecedor/features/dashboard/domain/entities/supplier_metrics.dart';
import 'package:happfest_fornecedor/features/dashboard/domain/entities/supplier_profile.dart';

abstract interface class DashboardRepository {
  Future<Result<SupplierProfile>> getProfile();

  Future<Result<SupplierMetrics>> getMetrics();

  Future<Result<PagedResponse<SubOrderPreview>>> getPendingOrders({
    int page = 0,
    int size = 5,
  });
}
