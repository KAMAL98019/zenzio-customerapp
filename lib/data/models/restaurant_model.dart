// lib/data/models/restaurant_model.dart
class Restaurant {
  final String id;
  final String restName;
  final String restAddress;
  final String avgCostTwo;
  final String? restLogo;
  final String contactPersonName;
  final String contactEmail;
  final String contactNumber;
  final String? operationalHours;
  final String? fssaiCertificate;
  final String? gstCertificate;
  final String status;
  final String deliveryType;
  final double? deliveryRadius;
  final String? minOrderAmount;
  final String? baseDeliveryFee;
  final DateTime createdAt;
  final DateTime updatedAt;

  Restaurant({
    required this.id,
    required this.restName,
    required this.restAddress,
    required this.avgCostTwo,
    this.restLogo,
    required this.contactPersonName,
    required this.contactEmail,
    required this.contactNumber,
    this.operationalHours,
    this.fssaiCertificate,
    this.gstCertificate,
    required this.status,
    required this.deliveryType,
    this.deliveryRadius,
    this.minOrderAmount,
    this.baseDeliveryFee,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] ?? '',
      restName: json['rest_name'] ?? '',
      restAddress: json['rest_address'] ?? '',
      avgCostTwo: json['avg_cost_two']?.toString() ?? '0',
      restLogo: json['rest_logo'],
      contactPersonName: json['contact_person_name'] ?? '',
      contactEmail: json['contact_email'] ?? '',
      contactNumber: json['contact_number'] ?? '',
      operationalHours: json['operational_hours'],
      fssaiCertificate: json['fssai_certificate'],
      gstCertificate: json['gst_certificate'],
      status: json['status'] ?? 'active',
      deliveryType: json['deliveryType'] ?? 'RADIUS',
      deliveryRadius: json['deliveryRadius']?.toDouble(),
      minOrderAmount: json['minOrderAmount']?.toString(),
      baseDeliveryFee: json['baseDeliveryFee']?.toString(),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rest_name': restName,
      'rest_address': restAddress,
      'avg_cost_two': avgCostTwo,
      'rest_logo': restLogo,
      'contact_person_name': contactPersonName,
      'contact_email': contactEmail,
      'contact_number': contactNumber,
      'operational_hours': operationalHours,
      'fssai_certificate': fssaiCertificate,
      'gst_certificate': gstCertificate,
      'status': status,
      'deliveryType': deliveryType,
      'deliveryRadius': deliveryRadius,
      'minOrderAmount': minOrderAmount,
      'baseDeliveryFee': baseDeliveryFee,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}