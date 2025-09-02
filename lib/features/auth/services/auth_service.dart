import 'package:pakgo/core/constants/api_constants.dart';
import 'package:pakgo/core/constants/app_strings.dart';
import 'package:pakgo/core/network/api_client.dart';
import 'package:pakgo/data/models/user.dart'; // Import the modified ApiClient

class AuthService {
  static Future<Map<String, dynamic>> auth({
    String? fullName,
    required String email,
    String? phone,
    required String password,
    required bool isLogin,
  }) async {
    try {
      Map<String, dynamic> data;
      if (isLogin) {
        data = {
          "email": email,
          "password": password,
        };
      } else {
        data = {
          "name": fullName,
          "email": email,
          "phone": phone,
          "password": password,
          "role": AppStrings.USER,
        };
      }

      final response = await ApiClient().post(
        isLogin ? ApiConstants.login : ApiConstants.register,
        data: data,
      );

      if (response.statusCode == 200) {
        if(isLogin){
          final user = User.fromJson(response.data);
          final token = response.data['token'].toString();
          return {"success": true, "user": user, "token": token};
        }
        return {"success": true, "data": response.data};
      }
      return {"success": false, "message": "Unexpected response."};
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