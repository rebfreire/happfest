import 'package:happfest/features/checkout/data/dto/checkout_preview_response_dto.dart';
import 'package:happfest/features/checkout/data/dto/checkout_response_dto.dart';
import 'package:happfest/features/checkout/data/dto/payment_action_response_dto.dart';
import 'package:happfest/features/checkout/data/dto/payment_response_dto.dart';
import 'package:happfest/features/checkout/data/dto/sub_order_preview_response_dto.dart';
import 'package:happfest/features/checkout/domain/entities/checkout_preview.dart';
import 'package:happfest/features/checkout/domain/entities/checkout_result.dart';
import 'package:happfest/features/checkout/domain/entities/payment.dart';

extension CheckoutPreviewResponseDtoMapper on CheckoutPreviewResponseDto {
  CheckoutPreview toEntity() {
    return CheckoutPreview(
      stores: subOrders.map((dto) => dto.toEntity()).toList(),
      total: total,
      advertisedTotal: advertisedTotal,
      paymentDiscountAmount: paymentDiscountAmount,
      balanceAvailable: balanceAvailable,
      maxBalanceUsable: maxBalanceUsable,
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
    return CheckoutResult(
      orderId: order?.id,
      orderTotal: order?.totalAmount ?? 0,
      payment: payment?.toEntity(),
      paymentAttemptId: paymentAttemptId,
      paymentStatusUrl: paymentStatusUrl,
      paymentProcessingAsync: paymentProcessingAsync,
    );
  }
}

extension PaymentResponseDtoMapper on PaymentResponseDto {
  Payment toEntity() {
    return Payment(
      id: id,
      orderId: orderId,
      status: status?.toEntity(),
      amount: amount,
      paymentLink: paymentLink,
      failureReason: failureReason,
      action: action?.toEntity(),
      expiresAt: expiresAt != null ? DateTime.tryParse(expiresAt!) : null,
    );
  }
}

extension PaymentActionResponseDtoMapper on PaymentActionResponseDto {
  PaymentAction toEntity() {
    return PaymentAction(
      type: _typeOf(type),
      url: url,
      pixCopyPaste: pixCopyPaste,
      pixQrCode: pixQrCode,
      boletoIdentificationField: boletoIdentificationField,
      boletoPdfUrl: boletoPdfUrl,
      expiresAt: expiresAt != null ? DateTime.tryParse(expiresAt!) : null,
    );
  }

  PaymentActionType _typeOf(String? raw) {
    return switch (raw?.toUpperCase()) {
      'PIX' => PaymentActionType.pix,
      'BOLETO' => PaymentActionType.boleto,
      'HOSTED_REDIRECT' => PaymentActionType.hostedRedirect,
      _ => PaymentActionType.none,
    };
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
      PaymentStatusDto.chargeback => PaymentStatus.chargeback,
    };
  }
}
