import 'package:happfest_core/core/error/result.dart';
import 'package:happfest_fornecedor/features/dashboard/domain/entities/supplier_profile.dart';
import 'package:happfest_fornecedor/features/dashboard/domain/repositories/dashboard_repository.dart';

class GetSupplierProfileUseCase {
  const GetSupplierProfileUseCase(this._repository);

  final DashboardRepository _repository;

  Future<Result<SupplierProfile>> call() => _repository.getProfile();
}
