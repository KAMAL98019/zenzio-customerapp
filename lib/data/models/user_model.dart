// lib/data/models/user_model.dart
class User {
  final String? id;
  final String? name;
  final String? email;
  final String? mobile;
  final String? countryCode;
  final String? profilePhoto;
  final String? birthday;
  final String? anniversary;
  final bool? emailVerified;
  final bool? phoneVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    this.id,
    this.name,
    this.email,
    this.mobile,
    this.countryCode,
    this.profilePhoto,
    this.birthday,
    this.anniversary,
    this.emailVerified,
    this.phoneVerified,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      mobile: json['mobile']?.toString() ?? json['phone']?.toString(),
      countryCode: json['countryCode']?.toString() ?? json['country_code']?.toString(),
      profilePhoto: json['profilePhoto']?.toString() ?? json['profile_photo']?.toString(),
      birthday: json['birthday']?.toString(),
      anniversary: json['anniversary']?.toString(),
      emailVerified: json['emailVerified'] ?? json['email_verified'],
      phoneVerified: json['phoneVerified'] ?? json['phone_verified'],
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'].toString())
          : (json['created_at'] != null 
              ? DateTime.tryParse(json['created_at'].toString())
              : null),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : (json['updated_at'] != null
              ? DateTime.tryParse(json['updated_at'].toString())
              : null),
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
      'birthday': birthday,
      'anniversary': anniversary,
      'emailVerified': emailVerified,
      'phoneVerified': phoneVerified,
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
    String? birthday,
    String? anniversary,
    bool? emailVerified,
    bool? phoneVerified,
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
      birthday: birthday ?? this.birthday,
      anniversary: anniversary ?? this.anniversary,
      emailVerified: emailVerified ?? this.emailVerified,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}