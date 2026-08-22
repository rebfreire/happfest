import 'package:happfest/features/checkout/data/dto/checkout_preview_response_dto.dart';
import 'package:happfest/features/checkout/data/dto/checkout_response_dto.dart';
import 'package:happfest/features/checkout/data/dto/payment_response_dto.dart';
import 'package:happfest/features/checkout/data/dto/sub_order_preview_response_dto.dart';
import 'package:happfest/features/checkout/domain/entities/checkout_preview.dart';
import 'package:happfest/features/checkout/domain/entities/checkout_result.dart';

extension CheckoutPreviewResponseDtoMapper on CheckoutPreviewResponseDto {
  CheckoutPreview toEntity() {
    return CheckoutPreview(
      stores: subOrders.map((dto) => dto.toEntity()).toList(),
      total: total,
    );
  }
}

extension SubOrderPreviewResponseDtoMapper on SubOrderPreviewResponseDto {
  StorePreview toEntity() {
    return StorePreview(
      storeId: storeId,
      storeName: storeName ?? 'Loja',
      subtotal: subtotal,
      platformFeeAmount: platformFeeAmount,
      deliveryDate: deliveryDate,
      deliveryCityName: deliveryCityName,
      itemCount: items.length,
    );
  }
}

extension CheckoutResponseDtoMapper on CheckoutResponseDto {
  CheckoutResult toEntity() {
    final paymentDto = payment;
    return CheckoutResult(
      orderId: order?.id,
      orderTotal: order?.totalAmount ?? 0,
      paymentStatus: paymentDto?.status?.toEntity(),
      paymentLink: paymentDto?.paymentLink,
      failureReason: paymentDto?.failureReason,
    );
  }
}

extension PaymentStatusDtoMapper on PaymentStatusDto {
  PaymentStatus toEntity() {
    return switch (this) {
      PaymentStatusDto.pending => PaymentStatus.pending,
      PaymentStatusDto.approved => PaymentStatus.approved,
      PaymentStatusDto.failed => PaymentStatus.failed,
      PaymentStatusDto.cancelled => PaymentStatus.cancelled,
      PaymentStatusDto.partiallyRefunded => PaymentStatus.partiallyRefunded,
      PaymentStatusDto.refunded => PaymentStatus.refunded,
    };
  }
}
