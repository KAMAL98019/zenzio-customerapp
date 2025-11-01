import '../config/api_config.dart';
import '../data/models/user_model.dart';
import 'api_service.dart';

class UserService {
  final ApiService _apiService = ApiService();

  Future<List<User>> fetchAllUsers() async {
    try {
      final response = await _apiService.get(
        ApiConfig.usersEndpoint,
        requiresAuth: true,
      );

      print('📥 Raw User Response: $response');

      // ✅ Backend typically returns { success, message, data: [...] }
      if (response is Map<String, dynamic> && response['data'] is List) {
        final List<dynamic> dataList = response['data'];
        return dataList.map((user) => User.fromJson(user)).toList();
      }

      // ✅ Fallback: sometimes direct list (if API returns bare array)
      if (response is List) {
        return response.map((user) => User.fromJson(user)).toList();
      }

      throw Exception('Invalid response format: $response');
    } catch (e) {
      print('❌ Error fetching users: $e');
      rethrow;
    }
  }
}
