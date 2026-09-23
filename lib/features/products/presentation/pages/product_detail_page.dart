import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happfest/core/error/failure.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/design_system/components/app_badge.dart';
import 'package:happfest/design_system/components/app_button.dart';
import 'package:happfest/design_system/feedback/app_error_state.dart';
import 'package:happfest/design_system/feedback/app_loading.dart';
import 'package:happfest/design_system/feedback/app_snackbar.dart';
import 'package:happfest/design_system/tokens/app_spacing.dart';
import 'package:happfest/features/cart/data/cart_providers.dart';
import 'package:happfest/features/cart/presentation/controllers/cart_providers.dart';
import 'package:happfest/features/products/domain/entities/product_detail.dart';
import 'package:happfest/features/products/domain/entities/product_type.dart';
import 'package:happfest/features/products/presentation/controllers/product_detail_providers.dart';
import 'package:happfest/features/products/presentation/widgets/product_image_gallery.dart';
import 'package:happfest/features/service_availability/presentation/controllers/service_availability_providers.dart';
import 'package:happfest/features/service_availability/presentation/widgets/service_availability_picker.dart';
import 'package:intl/intl.dart';

class ProductDetailPage extends ConsumerWidget {
  const ProductDetailPage({required this.productId, super.key, this.storeName});

  final String productId;
  final String? storeName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(productDetailProvider(productId));

    return Scaffold(
      appBar: AppBar(),
      body: detailAsync.when(
        loading: () => const AppLoading(),
        error: (error, stackTrace) => AppErrorState(
          failure: const UnknownFailure(),
          onRetry: () => ref.invalidate(productDetailProvider(productId)),
        ),
        data: (result) => switch (result) {
          Ok(:final value) => _ProductDetailContent(
            detail: value,
            storeName: storeName ?? value.storeName,
          ),
          Err(:final failure) => AppErrorState(
            failure: failure,
            onRetry: () => ref.invalidate(productDetailProvider(productId)),
          ),
        },
      ),
    );
  }
}

class _ProductDetailContent extends ConsumerStatefulWidget {
  const _ProductDetailContent({required this.detail, this.storeName});

  final ProductDetail detail;
  final String? storeName;

  @override
  ConsumerState<_ProductDetailContent> createState() =>
      _ProductDetailContentState();
}

class _ProductDetailContentState extends ConsumerState<_ProductDetailContent> {
  var _isAddingToCart = false;
  var _quantity = 1;
  late double _pricingUnitQuantity = widget.detail.pricingUnitMin ?? 1;
  DateTime? _selectedDate;
  String? _selectedTime;

  bool get _isService => widget.detail.productType == ProductType.service;

  ServiceAvailabilityQuery get _availabilityQuery => (
    productId: widget.detail.id,
    quantity: _quantity,
    pricingUnitQuantity: _pricingUnitQuantity,
  );

  void _changeQuantity(int delta) {
    final next = _quantity + delta;
    if (next < 1) return;
    setState(() {
      _quantity = next;
      _selectedDate = null;
      _selectedTime = null;
    });
  }

  void _changeDuration(double delta) {
    final next = _pricingUnitQuantity + delta;
    if (next < 0.001) return;
    setState(() {
      _pricingUnitQuantity = next;
      _selectedDate = null;
      _selectedTime = null;
    });
  }

  Future<void> _addToCart() async {
    final detail = widget.detail;
    final variantId = detail.defaultVariantId;
    if (variantId == null) {
      AppSnackbar.error(context, 'Este item não está disponível no momento.');
      return;
    }

    if (_isService) {
      final availabilityAsync = ref.read(
        serviceAvailabilityProvider(_availabilityQuery),
      );
      final availabilityResult = availabilityAsync.value;
      final availability = switch (availabilityResult) {
        Ok(:final value) => value,
        _ => null,
      };
      if (availability == null || !availability.hasAvailability) {
        AppSnackbar.error(
          context,
          'Não há datas disponíveis para esse serviço no momento.',
        );
        return;
      }
      if (_selectedDate == null) {
        AppSnackbar.error(context, 'Escolha uma data para continuar.');
        return;
      }
      if (availability.timeSelectionRequired && _selectedTime == null) {
        AppSnackbar.error(context, 'Escolha um horário para continuar.');
        return;
      }
    }

    setState(() => _isAddingToCart = true);
    final result = await ref
        .read(addCartItemUseCaseProvider)
        .call(
          productVariantId: variantId,
          pricingUnitQuantity: _pricingUnitQuantity,
          quantity: _quantity,
          preferredDate: _isService && _selectedDate != null
              ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
              : null,
          preferredTime: _isService ? _selectedTime : null,
        );
    if (!mounted) return;
    setState(() => _isAddingToCart = false);

    switch (result) {
      case Ok():
        ref.invalidate(cartProvider);
        AppSnackbar.success(context, 'Adicionado ao carrinho.');
      case Err(:final failure):
        if (failure is ConflictFailure && _isService) {
          ref.invalidate(serviceAvailabilityProvider(_availabilityQuery));
          setState(() {
            _selectedDate = null;
            _selectedTime = null;
          });
        }
        AppSnackbar.error(context, failure.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = widget.detail;
    final storeName = widget.storeName;
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: r'R$');
    final hasPriceRange =
        detail.pricingUnitMax != null &&
        detail.pricingUnitMax != detail.pricingUnitMin;

    final availabilityAsync = _isService
        ? ref.watch(serviceAvailabilityProvider(_availabilityQuery))
        : null;

    final canAddToCart =
        !_isAddingToCart &&
        (!_isService || availabilityAsync?.value is Ok);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
            children: [
              ProductImageGallery(imageUrls: detail.imageUrls),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            detail.name,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                        AppBadge(
                          label: _isService ? 'SERVIÇO' : 'PRODUTO',
                        ),
                      ],
                    ),
                    if (storeName != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        storeName,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    if (detail.pricingUnitMin != null)
                      Text(
                        hasPriceRange
                            ? '${currency.format(detail.pricingUnitMin)} — '
                                  '${currency.format(detail.pricingUnitMax)}'
                            : currency.format(detail.pricingUnitMin),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    if (detail.pricingUnitLabel != null)
                      Text(
                        'por ${detail.pricingUnitLabel}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    if (detail.description != null &&
                        detail.description!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Descrição',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(detail.description!),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Text(
                          'Quantidade',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => _changeQuantity(-1),
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Text('$_quantity'),
                        IconButton(
                          onPressed: () => _changeQuantity(1),
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ],
                    ),
                    if (_isService) ...[
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              detail.pricingUnitLabel != null
                                  ? 'Duração (${detail.pricingUnitLabel})'
                                  : 'Duração',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          IconButton(
                            onPressed: () => _changeDuration(-1),
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text(
                            _pricingUnitQuantity % 1 == 0
                                ? _pricingUnitQuantity.toStringAsFixed(0)
                                : _pricingUnitQuantity.toString(),
                          ),
                          IconButton(
                            onPressed: () => _changeDuration(1),
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      availabilityAsync!.when(
                        loading: () => const AppLoading.skeleton(),
                        error: (error, stackTrace) => AppErrorState(
                          failure: const UnknownFailure(),
                          onRetry: () => ref.invalidate(
                            serviceAvailabilityProvider(_availabilityQuery),
                          ),
                        ),
                        data: (result) => switch (result) {
                          Ok(:final value) => ServiceAvailabilityPicker(
                            availability: value,
                            selectedDate: _selectedDate,
                            onDateSelected: (date) => setState(() {
                              _selectedDate = date;
                              _selectedTime = null;
                            }),
                            selectedTime: _selectedTime,
                            onTimeSelected: (time) =>
                                setState(() => _selectedTime = time),
                          ),
                          Err(:final failure) => AppErrorState(
                            failure: failure,
                            onRetry: () => ref.invalidate(
                              serviceAvailabilityProvider(_availabilityQuery),
                            ),
                          ),
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: AppButton.confirm(
              label: 'Adicionar ao carrinho',
              expanded: true,
              isLoading: _isAddingToCart,
              onPressed: canAddToCart ? _addToCart : null,
            ),
          ),
        ),
      ],
    );
  }
}
