// // lib/data/models/restaurant_model.dart
// class Restaurant {
//   final String id;
//   final String restName;
//   final String restAddress;
//   final String avgCostTwo;
//   final String? restLogo;
//   final String contactPersonName;
//   final String contactEmail;
//   final String contactNumber;
//   final String? operationalHours;
//   final String? fssaiCertificate;
//   final String? gstCertificate;
//   final String status;
//   final String deliveryType;
//   final double? deliveryRadius;
//   final String? minOrderAmount;
//   final String? baseDeliveryFee;
//   final DateTime createdAt;
//   final DateTime updatedAt;

//   Restaurant({
//     required this.id,
//     required this.restName,
//     required this.restAddress,
//     required this.avgCostTwo,
//     this.restLogo,
//     required this.contactPersonName,
//     required this.contactEmail,
//     required this.contactNumber,
//     this.operationalHours,
//     this.fssaiCertificate,
//     this.gstCertificate,
//     required this.status,
//     required this.deliveryType,
//     this.deliveryRadius,
//     this.minOrderAmount,
//     this.baseDeliveryFee,
//     required this.createdAt,
//     required this.updatedAt,
//   });

//   factory Restaurant.fromJson(Map<String, dynamic> json) {
//     return Restaurant(
//       id: json['id'] ?? '',
//       restName: json['rest_name'] ?? '',
//       restAddress: json['rest_address'] ?? '',
//       avgCostTwo: json['avg_cost_two']?.toString() ?? '0',
//       restLogo: json['rest_logo'],
//       contactPersonName: json['contact_person_name'] ?? '',
//       contactEmail: json['contact_email'] ?? '',
//       contactNumber: json['contact_number'] ?? '',
//       operationalHours: json['operational_hours'],
//       fssaiCertificate: json['fssai_certificate'],
//       gstCertificate: json['gst_certificate'],
//       status: json['status'] ?? 'active',
//       deliveryType: json['deliveryType'] ?? 'RADIUS',
//       deliveryRadius: json['deliveryRadius']?.toDouble(),
//       minOrderAmount: json['minOrderAmount']?.toString(),
//       baseDeliveryFee: json['baseDeliveryFee']?.toString(),
//       createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
//       updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'rest_name': restName,
//       'rest_address': restAddress,
//       'avg_cost_two': avgCostTwo,
//       'rest_logo': restLogo,
//       'contact_person_name': contactPersonName,
//       'contact_email': contactEmail,
//       'contact_number': contactNumber,
//       'operational_hours': operationalHours,
//       'fssai_certificate': fssaiCertificate,
//       'gst_certificate': gstCertificate,
//       'status': status,
//       'deliveryType': deliveryType,
//       'deliveryRadius': deliveryRadius,
//       'minOrderAmount': minOrderAmount,
//       'baseDeliveryFee': baseDeliveryFee,
//       'createdAt': createdAt.toIso8601String(),
//       'updatedAt': updatedAt.toIso8601String(),
//     };
//   }
// }

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
    // ✅ Safe parsing with detailed logging
    try {
      print('🔍 Parsing restaurant JSON with keys: ${json.keys.toList()}');
      
      // Handle both 'id' and '_id' fields
      final id = json['id']?.toString() ?? json['_id']?.toString() ?? '';
      
      if (id.isEmpty) {
        throw Exception('Restaurant ID is missing from JSON');
      }

      return Restaurant(
        id: id,
        restName: json['rest_name']?.toString() ?? 'Unknown Restaurant',
        restAddress: json['rest_address']?.toString() ?? 'Address not available',
        avgCostTwo: json['avg_cost_two']?.toString() ?? '0',
        restLogo: json['rest_logo']?.toString(),
        contactPersonName: json['contact_person_name']?.toString() ?? '',
        contactEmail: json['contact_email']?.toString() ?? '',
        contactNumber: json['contact_number']?.toString() ?? '',
        operationalHours: json['operational_hours']?.toString(),
        fssaiCertificate: json['fssai_certificate']?.toString(),
        gstCertificate: json['gst_certificate']?.toString(),
        status: json['status']?.toString() ?? 'active',
        deliveryType: json['deliveryType']?.toString() ?? 'RADIUS',
        deliveryRadius: json['deliveryRadius'] != null 
            ? double.tryParse(json['deliveryRadius'].toString())
            : null,
        minOrderAmount: json['minOrderAmount']?.toString(),
        baseDeliveryFee: json['baseDeliveryFee']?.toString(),
        createdAt: _parseDateTime(json['createdAt']),
        updatedAt: _parseDateTime(json['updatedAt']),
      );
    } catch (e) {
      print('❌ Error parsing restaurant JSON: $e');
      print('📦 JSON data: $json');
      rethrow;
    }
  }

  // ✅ Safe DateTime parsing
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    
    try {
      if (value is String) {
        return DateTime.parse(value);
      } else if (value is DateTime) {
        return value;
      }
      return DateTime.now();
    } catch (e) {
      print('⚠️ Failed to parse DateTime: $value, using current time');
      return DateTime.now();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      '_id': id, // Include both for compatibility
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

  @override
  String toString() {
    return 'Restaurant(id: $id, name: $restName, address: $restAddress)';
  }
}