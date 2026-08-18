import 'package:dio/dio.dart';
import 'package:happfest/core/error/failure.dart';
import 'package:happfest/core/error/result.dart';
import 'package:happfest/core/network/api_exception.dart';
import 'package:happfest/features/cart/data/dto/cart_item_request_dto.dart';
import 'package:happfest/features/cart/data/dto/cart_item_update_request_dto.dart';
import 'package:happfest/features/cart/data/dto/cart_response_dto.dart';
import 'package:happfest/features/cart/data/mappers/cart_mapper.dart';
import 'package:happfest/features/cart/domain/entities/cart.dart';
import 'package:happfest/features/cart/domain/repositories/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  const CartRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<Result<Cart>> getCart() {
    return _run(() => _dio.get<Map<String, dynamic>>('/cart'));
  }

  @override
  Future<Result<Cart>> addItem({
    required String productVariantId,
    required int quantity,
    required double pricingUnitQuantity,
  }) {
    final request = CartItemRequestDto(
      productVariantId: productVariantId,
      quantity: quantity,
      pricingUnitQuantity: pricingUnitQuantity,
    );
    return _run(
      () => _dio.post<Map<String, dynamic>>(
        '/cart/items',
        data: request.toJson(),
      ),
    );
  }

  @override
  Future<Result<Cart>> updateItem({
    required String itemId,
    required int quantity,
    required double pricingUnitQuantity,
  }) {
    final request = CartItemUpdateRequestDto(
      quantity: quantity,
      pricingUnitQuantity: pricingUnitQuantity,
    );
    return _run(
      () => _dio.patch<Map<String, dynamic>>(
        '/cart/items/$itemId',
        data: request.toJson(),
      ),
    );
  }

  @override
  Future<Result<Cart>> removeItem(String itemId) {
    return _run(
      () => _dio.delete<Map<String, dynamic>>('/cart/items/$itemId'),
    );
  }

  @override
  Future<Result<Cart>> mergeAnonymousCart() {
    return _run(() => _dio.post<Map<String, dynamic>>('/cart/merge'));
  }

  Future<Result<Cart>> _run(
    Future<Response<Map<String, dynamic>>> Function() request,
  ) async {
    try {
      final response = await request();
      final cart = CartResponseDto.fromJson(response.data!);
      return Ok(cart.toEntity());
    } on DioException catch (exception) {
      final error = exception.error;
      final failure = error is ApiException
          ? error.failure
          : const UnknownFailure();
      return Err(failure);
    }
  }
}
