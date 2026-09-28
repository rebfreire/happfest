import 'package:happfest_fornecedor/features/dashboard/data/dto/sub_order_response_dto.dart';
import 'package:happfest_fornecedor/features/dashboard/data/dto/supplier_me_response_dto.dart';
import 'package:happfest_fornecedor/features/dashboard/data/dto/supplier_metrics_response_dto.dart';
import 'package:happfest_fornecedor/features/dashboard/domain/entities/sub_order_preview.dart';
import 'package:happfest_fornecedor/features/dashboard/domain/entities/supplier_metrics.dart';
import 'package:happfest_fornecedor/features/dashboard/domain/entities/supplier_profile.dart';

extension SupplierMeResponseDtoMapper on SupplierMeResponseDto {
  SupplierProfile toEntity() {
    return SupplierProfile(
      id: id,
      name: name,
      approvalStatus: approvalStatus.toEntity(),
      tradeName: tradeName,
      storeId: storeId,
      storeSlug: storeSlug,
    );
  }
}

extension ApprovalStatusDtoMapper on ApprovalStatusDto {
  SupplierApprovalStatus toEntity() {
    return switch (this) {
      ApprovalStatusDto.awaitingDocuments =>
        SupplierApprovalStatus.awaitingDocuments,
      ApprovalStatusDto.inReview => SupplierApprovalStatus.inReview,
      ApprovalStatusDto.documentsPending =>
        SupplierApprovalStatus.documentsPending,
      ApprovalStatusDto.approved => SupplierApprovalStatus.approved,
      ApprovalStatusDto.suspended => SupplierApprovalStatus.suspended,
      ApprovalStatusDto.rejected => SupplierApprovalStatus.rejected,
    };
  }
}

extension SupplierMetricsResponseDtoMapper on SupplierMetricsResponseDto {
  SupplierMetrics toEntity() {
    return SupplierMetrics(
      acceptanceRatePercent: acceptanceRatePercent,
      averageRating: averageRating,
      totalReviews: totalReviews,
      acceptedCount: acceptedCount,
      totalDecisions: totalDecisions,
    );
  }
}

extension SubOrderResponseDtoMapper on SubOrderResponseDto {
  SubOrderPreview toEntity() {
    return SubOrderPreview(
      id: id,
      status: status.toEntity(),
      supplierAmount: supplierAmount,
      deliveryDate: deliveryDate == null ? null : DateTime.parse(deliveryDate!),
    );
  }
}

extension SubOrderStatusDtoMapper on SubOrderStatusDto {
  SubOrderStatus toEntity() {
    return switch (this) {
      SubOrderStatusDto.awaitingPayment => SubOrderStatus.awaitingPayment,
      SubOrderStatusDto.pending => SubOrderStatus.pending,
      SubOrderStatusDto.accepted => SubOrderStatus.accepted,
      SubOrderStatusDto.delivered => SubOrderStatus.delivered,
      SubOrderStatusDto.contested => SubOrderStatus.contested,
      SubOrderStatusDto.completed => SubOrderStatus.completed,
      SubOrderStatusDto.cancelled => SubOrderStatus.cancelled,
      SubOrderStatusDto.rejected => SubOrderStatus.rejected,
    };
  }
}
