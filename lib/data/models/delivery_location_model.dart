class DeliveryLocation {
  final String address;
  final double lat;
  final double lng;
  final bool isDefault;
  final String addressType;

  DeliveryLocation({
    required this.address,
    required this.lat,
    required this.lng,
    required this.isDefault,
    required this.addressType,
  });

  Map<String, dynamic> toJson() {
    return {
      "address": address,
      "lat": lat,
      "lng": lng,
      "is_default": isDefault,
      "address_type": addressType,
    };
  }
}
