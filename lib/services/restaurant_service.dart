import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../data/models/restaurant_model.dart';

class RestaurantService {
  final String baseUrl = ApiConfig.baseUrl;

  Future<List<Restaurant>> fetchRestaurants() async {
    final url = Uri.parse('$baseUrl${ApiConfig.restaurantsEndpoint}');
    final response = await http.get(url, headers: ApiConfig.headers);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> data = jsonResponse['data'];
      return data.map((item) => Restaurant.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load restaurants');
    }
  }
}
