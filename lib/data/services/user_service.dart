import 'package:pakgo/core/constants/api_constants.dart';
import 'package:pakgo/core/network/api_client.dart';
import 'package:pakgo/data/models/user.dart';

class UserService {
  final ApiClient _apiClient = ApiClient();

  Future<User> fetchProfile() async {
    final response = await _apiClient.get(ApiConstants.loggedInUser);
    final data = response.data;

    return User.fromJson(data is Map && data.containsKey('user') ? data['user'] : data);
  }

  Future<User> updateProfile(
      String name,
      String email,
      String phone,
      String password,
      ) async {
    final response = await _apiClient.put(
      ApiConstants.updateUser,
      data: {
        "name": name,
        "email": email,
        "phone": phone,
        "password": password,
      },
    );

    final data = response.data;
    return User.fromJson(data is Map && data.containsKey('user') ? data['user'] : data);
  }
}
