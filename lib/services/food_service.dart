//
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../data/models/food_item.dart';

class FoodService {
  final String endpoint = ApiConfig.foodItemsEndpoint;

  Future<List<FoodItem>> fetchFoodItems() async {
    try {
      final response = await http.get(Uri.parse(endpoint));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true && data['data'] != null) {
          List<dynamic> items = data['data'];
          return items.map((e) => FoodItem.fromJson(e)).toList();
        } else {
          throw Exception('Invalid API response');
        }
      } else {
        throw Exception('Failed to fetch food items (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error fetching food items: $e');
    }
  }
}
