// lib/core/services/paymob_service.dart

import 'package:dio/dio.dart';
import 'package:your_cairo_trip/core/constants/app_endpoints.dart';
import 'package:your_cairo_trip/core/utils/paymob/paymob_config.dart';

class PaymobService {
  final Dio _dio;

  PaymobService(this._dio);

  // ── Step 1: Get Auth Token ──
  Future<String> _getAuthToken() async {
    final response = await _dio.post(
      AppEndpoints.paymobAuthUrl,
      data: {'api_key': PaymobConfig.apiKey},
    );
    return response.data['token'];
  }

  // ── Step 2: Create Order ──
  Future<int> _createOrder({
    required String authToken,
    required double amount,
    required int bookingId,
  }) async {
    // ← unique merchant_order_id بإضافة timestamp عشان Paymob ميرفضش
    final uniqueOrderId =
        '${bookingId}_${DateTime.now().millisecondsSinceEpoch}';

    final response = await _dio.post(
      AppEndpoints.paymobOrderUrl,
      data: {
        'auth_token': authToken,
        'delivery_needed': false,
        'amount_cents': PaymobConfig.toPaymobAmount(amount),
        'currency': PaymobConfig.currency,
        'merchant_order_id': uniqueOrderId,
        'items': [],
      },
    );
    return response.data['id'];
  }

  // ── Step 3: Get Payment Key ──
  Future<String> _getPaymentKey({
    required String authToken,
    required int orderId,
    required double amount,
    required String userEmail,
    required String userName,
    required String userPhone,
  }) async {
    final nameParts = userName.trim().split(' ');
    final firstName = nameParts.first;
    final lastName = nameParts.length > 1 ? nameParts.last : 'User';

    final response = await _dio.post(
      AppEndpoints.paymobPaymentKeyUrl,
      data: {
        'auth_token': authToken,
        'amount_cents': PaymobConfig.toPaymobAmount(amount),
        'expiration': 3600,
        'order_id': orderId,
        'currency': PaymobConfig.currency,
        'integration_id': PaymobConfig.integrationId,
        'billing_data': {
          'first_name': firstName,
          'last_name': lastName,
          'email': userEmail,
          'phone_number': userPhone,
          'apartment': 'NA',
          'floor': 'NA',
          'street': 'NA',
          'building': 'NA',
          'shipping_method': 'NA',
          'postal_code': 'NA',
          'city': 'Cairo',
          'country': 'EG',
          'state': 'NA',
        },
      },
    );
    return response.data['token'];
  }

  // ── Get Payment URL ──
  Future<String> getPaymentUrl({
    required double amount,
    required int bookingId,
    required String userEmail,
    required String userName,
    required String userPhone,
  }) async {
    final authToken = await _getAuthToken();
    final orderId = await _createOrder(
      authToken: authToken,
      amount: amount,
      bookingId: bookingId,
    );
    final paymentKey = await _getPaymentKey(
      authToken: authToken,
      orderId: orderId,
      amount: amount,
      userEmail: userEmail,
      userName: userName,
      userPhone: userPhone,
    );
    return '${AppEndpoints.paymobIframeBaseUrl}${PaymobConfig.iframeId}?payment_token=$paymentKey';
  }
}
