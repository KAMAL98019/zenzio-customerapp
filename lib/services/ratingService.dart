import 'package:zenzio/config/api_config.dart';
import 'package:zenzio/services/api_service.dart';


class RatingService {
  final ApiService _api = ApiService();

  /// ⭐ Restaurant Rating
  Future<dynamic> submitRestaurantRating({
    required String groupId,
    required int rating,
    required String description,
  }) async {
    return await _api.post(
      ApiConfig.customerRestaurantRating,
      requiresAuth: true,
      body: {
        "group_id": groupId,
        "rating": rating,
        "description": description,
      },
    );
  }

  /// ⭐ Delivery Partner Rating
  Future<dynamic> submitFleetRating({
    required String groupId,
    required int rating,
    required String description,
  }) async {
    return await _api.post(
      ApiConfig.customerFleetRating,
      requiresAuth: true,
      body: {
        "group_id": groupId,
        "rating": rating,
        "description": description,
      },
    );
  }

  /// ⭐ Submit BOTH ratings in a single screen flow
  Future<void> submitBothRatings({
    required String groupId,
    required int restaurantRating,
    required int deliveryRating,
    required String description,
  }) async {
    await submitRestaurantRating(
      groupId: groupId,
      rating: restaurantRating,
      description: description,
    );

    await submitFleetRating(
      groupId: groupId,
      rating: deliveryRating,
      description: description,
    );
  }
}
