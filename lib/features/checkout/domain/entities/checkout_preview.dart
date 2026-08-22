import 'package:freezed_annotation/freezed_annotation.dart';

part 'checkout_preview.freezed.dart';

@freezed
abstract class CheckoutPreview with _$CheckoutPreview {
  const factory CheckoutPreview({
    @Default([]) List<StorePreview> stores,
    @Default(0) double total,
  }) = _CheckoutPreview;
}

@freezed
abstract class StorePreview with _$StorePreview {
  const factory StorePreview({
    required String storeId,
    required String storeName,
    @Default(0) double subtotal,
    @Default(0) double platformFeeAmount,
    String? deliveryDate,
    String? deliveryCityName,
    @Default(0) int itemCount,
  }) = _StorePreview;
}
