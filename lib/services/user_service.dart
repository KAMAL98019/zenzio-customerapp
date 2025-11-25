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

      if (response == null) throw Exception('No response from server');

      if (response is Map<String, dynamic>) {
        if (response['data'] is List) {
          final dataList = response['data'] as List;
          return dataList.map((e) => User.fromJson(e)).toList();
        } else if (response['success'] == false) {
          throw Exception(response['message'] ?? 'Failed to fetch users');
        }
      }

      if (response is List) {
        return response.map((e) => User.fromJson(e)).toList();
      }

      print('⚠️ Unexpected format: $response');
      return [];
    } catch (e, stack) {
      print('❌ Error fetching users: $e');
      print(stack);
      return [];
    }
  }

  Future updateUserProfile({
    required String userId,
    required String name,
    required String email,
  }) async {}
}
