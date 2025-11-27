import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zenzio/data/models/delivery_location_model.dart';
import 'package:zenzio/services/api_service.dart';
import '../config/api_config.dart';

class DeliveryLocationService {
  static Future<Map<String, dynamic>> saveLocation(
    DeliveryLocation location,
  ) async {
    final url = Uri.parse("${ApiConfig.baseUrl}${ApiConfig.deliveryLocation}");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(location.toJson()),
    );

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    return jsonDecode(response.body);
  }

  //  GET Saved Addresses
  static Future<List<dynamic>> getSavedLocations() async {
    try {
      final response = await ApiService().get(
        ApiConfig.deliveryLocation,
        requiresAuth: true, // 🔥 token auto include
      );

      return response["data"]["locations"] ?? [];
    } catch (e) {
      throw Exception("Failed to load locations: $e");
    }
  }


  //  Edit location by ID
static Future<bool> updateLocation(String deliveryUid, Map<String, dynamic> body) async {
  try {
    final url = "${ApiConfig.deliveryLocation}/$deliveryUid";

    final response = await ApiService().patch(
      url,
      body: body,
      requiresAuth: true,
    );

    if (response["status"] == "success" || response["code"] == 200) {
      return true;
    } else {
      throw Exception(response["message"] ?? "Failed to update location");
    }
  } catch (e) {
    throw Exception("Update failed: $e");
  }
}


  //  Delete location by ID
  static Future<bool> deleteLocation(String deliveryUid) async {
    try {
      final url = Uri.parse("${ApiConfig.deliveryLocation}/$deliveryUid");

      final response = await ApiService().delete(
        url.toString(),
        requiresAuth: true,
      );

      if (response["status"] == "success" || response["code"] == 200) {
        return true;
      } else {
        throw Exception(response["message"] ?? "Failed to delete location");
      }
    } catch (e) {
      throw Exception("Delete failed: $e");
    }
  }
}
