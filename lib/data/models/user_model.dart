class User {
  final String? id;
  final String? name;
  final String? email;
  final String? mobile;
  final String? countryCode;
  final String? profilePhoto;
  final String? customerId;
  final DateTime? birthday;
  final DateTime? anniversary;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    this.id,
    this.name,
    this.email,
    this.mobile,
    this.countryCode,
    this.profilePhoto,
    this.customerId,
    this.birthday,
    this.anniversary,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? json['_id']?.toString(),
      name: json['name'],
      email: json['email'],
      mobile: json['mobile'] ?? json['phone'],
      countryCode: json['countryCode'] ?? json['country_code'],
      profilePhoto: json['profilePhoto'] ?? json['profile_image'] ?? json['avatar'],
      customerId: json['customerId']?.toString(),
      birthday: json['birthday'] != null ? DateTime.tryParse(json['birthday']) : null,
      anniversary: json['anniversary'] != null ? DateTime.tryParse(json['anniversary']) : null,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'mobile': mobile,
      'countryCode': countryCode,
      'profilePhoto': profilePhoto,
      'customerId': customerId,
      'birthday': birthday?.toIso8601String(),
      'anniversary': anniversary?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? mobile,
    String? countryCode,
    String? profilePhoto,
    String? customerId,
    DateTime? birthday,
    DateTime? anniversary,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      countryCode: countryCode ?? this.countryCode,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      customerId: customerId ?? this.customerId,
      birthday: birthday ?? this.birthday,
      anniversary: anniversary ?? this.anniversary,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
