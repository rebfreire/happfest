import 'package:happfest_core/core/error/result.dart';
import 'package:happfest_fornecedor/features/dashboard/domain/entities/supplier_metrics.dart';
import 'package:happfest_fornecedor/features/dashboard/domain/repositories/dashboard_repository.dart';

class GetSupplierMetricsUseCase {
  const GetSupplierMetricsUseCase(this._repository);

  final DashboardRepository _repository;

  Future<Result<SupplierMetrics>> call() => _repository.getMetrics();
}
