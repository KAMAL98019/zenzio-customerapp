
import 'package:zenzio_customer/data/models/restaurant2_model.dart';

class RestaurantService {
  static List<RestaurantModel> getTopOffers() {
    return [
      RestaurantModel(
        id: 1,
        name: "Burger Kingdom",
        image: "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&h=300&fit=crop",
        discount: "50% OFF on Burgers",
        rating: 4.8,
        time: "20-30 min",
      ),
      RestaurantModel(
        id: 2,
        name: "Pizza Paradise",
        image: "https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400&h=300&fit=crop",
        offer: "Buy 1 Get 1 Pizza",
        rating: 4.7,
        time: "25-35 min",
      ),
    ];
  }

  static List<RestaurantModel> getPopularRestaurants() {
    return [
      RestaurantModel(
        id: 3,
        name: "Burger Kingdom",
        image: "https://images.unsplash.com/photo-1550547660-d9450f859349?w=400&h=300&fit=crop",
        rating: 4.8,
        time: "20-30 min",
        badge: "FAST FOOD",
      ),
      RestaurantModel(
        id: 4,
        name: "Pizza Paradise",
        image: "https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=400&h=300&fit=crop",
        rating: 4.7,
        time: "25-35 min",
        badge: "GREAT OFFER",
      ),
      RestaurantModel(
        id: 5,
        name: "Sushi Master",
        image: "https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=400&h=300&fit=crop",
        rating: 4.8,
        time: "35-45 min",
      ),
    ];
  }

  static List<RestaurantModel> getNewRestaurants() {
    return [
      RestaurantModel(
        id: 6,
        name: "Thai Flavor",
        image: "https://images.unsplash.com/photo-1559314809-0d155014e29e?w=400&h=300&fit=crop",
        rating: 4.5,
        time: "30-40 min",
      ),
      RestaurantModel(
        id: 7,
        name: "Chinese Wok",
        image: "https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?w=400&h=300&fit=crop",
        rating: 4.6,
        time: "25-35 min",
      ),
    ];
  }

  static List<RestaurantModel> searchRestaurants(String query) {
    final all = [
      ...getTopOffers(),
      ...getPopularRestaurants(),
      ...getNewRestaurants(),
    ];
    return all
        .where((r) => r.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
