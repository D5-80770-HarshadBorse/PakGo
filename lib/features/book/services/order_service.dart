import 'package:pakgo/core/constants/api_constants.dart';
import 'package:pakgo/core/network/api_client.dart';
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
}