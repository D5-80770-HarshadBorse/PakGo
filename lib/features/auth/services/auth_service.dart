import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pakgo/core/constants/api_constants.dart';
import 'package:pakgo/core/constants/app_strings.dart';

class AuthService {
  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.register),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "fullName": fullName,
          "email": email,
          "phone": phone,
          "password": password,
          "role": AppStrings.USER,
        }),
      );

      if (response.statusCode == 200) {
        return {"success": true, "data": jsonDecode(response.body)};
      } else {
        return {
          "success": false,
          "message":
              jsonDecode(response.body)["message"] ?? "Registration failed",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }
}
