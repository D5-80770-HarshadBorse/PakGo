import 'package:pakgo/core/constants/api_constants.dart';
import 'package:pakgo/core/network/api_client.dart';
import 'package:pakgo/data/models/user.dart';

class UserService {
  final ApiClient _apiClient = ApiClient();

  Future<User> fetchProfile() async {
    try {
      final response = await _apiClient.get(ApiConstants.loggedInUser);
      return _extractUserFromResponse(response.data);
    } catch (e) {
      throw Exception('Failed to fetch profile. Please check your connection.');
    }
  }

  Future<User> updateProfile(int userId, Map<String, dynamic> updateData) async {
    updateData.removeWhere((key, value) => value == null || (value is String && value.isEmpty));

    if (updateData.isEmpty) {
      throw Exception('No changes to update.');
    }

    try {
      final String path = '${ApiConstants.updateUser}/$userId';
      final response = await _apiClient.put(
        path,
        data: updateData,
      );
      return _extractUserFromResponse(response.data);
    } catch (e) {
      throw Exception('Failed to update profile. Please try again.');
    }
  }

  User _extractUserFromResponse(dynamic data) {
    if (data is Map && data.containsKey('user')) {
      return User.fromJson(data['user']);
    }
    return User.fromJson(data);
  }
}
