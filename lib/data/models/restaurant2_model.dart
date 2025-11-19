class RestaurantModel {
  final int id;
  final String name;
  final String image;
  final double rating;
  final String time;
  final String? discount;
  final String? offer;
  final String? badge;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.image,
    required this.rating,
    required this.time,
    this.discount,
    this.offer,
    this.badge,
  });
}