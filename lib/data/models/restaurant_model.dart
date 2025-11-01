class Restaurant {
  final String id;
  final String name;
  final String address;
  final String avgCostTwo;
  final String logo;
  final String contactName;
  final String contactEmail;
  final String contactNumber;
  final String? status;

  Restaurant({
    required this.id,
    required this.name,
    required this.address,
    required this.avgCostTwo,
    required this.logo,
    required this.contactName,
    required this.contactEmail,
    required this.contactNumber,
    this.status,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] ?? '',
      name: json['rest_name'] ?? '',
      address: json['rest_address'] ?? '',
      avgCostTwo: json['avg_cost_two'] ?? '',
      logo: json['rest_logo'] ?? '',
      contactName: json['contact_person_name'] ?? '',
      contactEmail: json['contact_email'] ?? '',
      contactNumber: json['contact_number'] ?? '',
      status: json['status'] ?? '',
    );
  }
}
