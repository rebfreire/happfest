import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/features/checkout/data/checkout_providers.dart';
import 'package:happfest/features/checkout/domain/entities/checkout_preview.dart';
import 'package:happfest/features/checkout/domain/entities/payment_method.dart';

typedef CheckoutPreviewQuery = ({String partyId, PaymentMethod paymentMethod});

// AutoDisposeFutureProviderFamily não é exportado publicamente pelo
// flutter_riverpod, então o tipo não pode ser anotado explicitamente aqui.
// ignore: specify_nonobvious_property_types
final checkoutPreviewProvider = FutureProvider.autoDispose
    .family<Result<CheckoutPreview>, CheckoutPreviewQuery>((ref, query) {
      return ref.watch(previewCheckoutUseCaseProvider)(
        partyId: query.partyId,
        paymentMethod: query.paymentMethod,
      );
    });
