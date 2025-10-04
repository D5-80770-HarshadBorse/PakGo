import 'package:pakgo/core/constants/api_constants.dart';
import 'package:pakgo/core/network/api_client.dart';
import 'package:pakgo/data/models/order.dart';
import 'package:pakgo/data/models/order_request.dart';

class OrderService {
  static Future<Map<String, dynamic>> createOrder({
    required OrderRequest orderRequest,
  }) async {
    try {
      final Map<String, dynamic> data = orderRequest.toJson();

      final response = await ApiClient().post(
        ApiConstants.createOrder,
        data: data,
      );

      if (response.statusCode == 200) {
        return {"success": true, "data": response.data};
      }

      return {"success": false, "message": "Unexpected response from server."};
    } on ApiException catch (e) {
      return {
        "success": false,
        "message": e.message,
      };
    } catch (e) {
      return {
        "success": false,
        "message": "An unexpected error occurred. Please try again.",
      };
    }
  }

  static Future<List<Order>> getUserOrders() async {
    try {
      final response = await ApiClient().get(ApiConstants.userOrders);
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> orderData = response.data;
        return orderData.map((json) => Order.fromJson(json)).toList();
      }
      throw 'Failed to load orders.';
    } on ApiException catch (e) {
      throw Exception('Failed to load orders: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }
}