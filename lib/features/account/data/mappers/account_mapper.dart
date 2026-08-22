import 'package:happfest/features/account/data/dto/customer_address_response_dto.dart';
import 'package:happfest/features/account/data/dto/customer_context_response_dto.dart';
import 'package:happfest/features/account/data/dto/order_detail_response_dto.dart';
import 'package:happfest/features/account/data/dto/order_summary_response_dto.dart';
import 'package:happfest/features/account/data/dto/sub_order_item_response_dto.dart';
import 'package:happfest/features/account/data/dto/sub_order_response_dto.dart';
import 'package:happfest/features/account/domain/entities/customer_account.dart';
import 'package:happfest/features/account/domain/entities/customer_address.dart';
import 'package:happfest/features/account/domain/entities/order_detail.dart';
import 'package:happfest/features/account/domain/entities/order_summary.dart';

extension CustomerContextResponseDtoMapper on CustomerContextResponseDto {
  CustomerAccount toEntity() {
    return CustomerAccount(
      customerId: customerId,
      activated: activated,
      name: name,
      email: email,
      phone: phone,
      cpf: cpf,
    );
  }
}

extension CustomerAddressResponseDtoMapper on CustomerAddressResponseDto {
  CustomerAddress toEntity() {
    return CustomerAddress(
      id: id,
      label: label ?? 'Endereço',
      street: street ?? '',
      number: number ?? '',
      complement: complement,
      neighborhood: neighborhood ?? '',
      cityName: cityNome,
      stateUf: stateUf,
      zipCode: zipCode ?? '',
      isDefault: isDefault,
    );
  }
}

extension OrderSummaryResponseDtoMapper on OrderSummaryResponseDto {
  OrderSummary toEntity() {
    return OrderSummary(
      id: id,
      totalAmount: totalAmount,
      deliveryDate: _tryParseDate(deliveryDate),
      createdAt: _tryParseDate(createdAt),
    );
  }
}

extension OrderDetailResponseDtoMapper on OrderDetailResponseDto {
  OrderDetail toEntity() {
    return OrderDetail(
      id: id,
      totalAmount: totalAmount,
      deliveryDate: _tryParseDate(deliveryDate),
      createdAt: _tryParseDate(createdAt),
      subOrders: subOrders.map((dto) => dto.toEntity()).toList(),
    );
  }
}

extension SubOrderResponseDtoMapper on SubOrderResponseDto {
  SubOrderDetail toEntity() {
    return SubOrderDetail(
      id: id,
      storeName: storeName ?? 'Loja',
      status: status?.toEntity(),
      subtotal: subtotal,
      deliveryDate: _tryParseDate(deliveryDate),
      deliveryTime: deliveryTime,
      items: items.map((dto) => dto.toEntity()).toList(),
    );
  }
}

extension SubOrderItemResponseDtoMapper on SubOrderItemResponseDto {
  SubOrderItemDetail toEntity() {
    return SubOrderItemDetail(
      id: id,
      productName: productName ?? 'Item',
      quantity: quantity,
      unitPrice: unitPrice,
      lineTotal: lineTotal,
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

DateTime? _tryParseDate(String? value) {
  if (value == null) return null;
  return DateTime.tryParse(value);
}
