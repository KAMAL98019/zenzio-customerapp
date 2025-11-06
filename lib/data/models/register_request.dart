class RegisterRequest {
  final String name;
  final String email;
  final String password;
  final String? phone;
  final String? countryCode;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    this.phone,
    this.countryCode,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'email': email,
      'password': password,
    };
    
    if (phone != null) {
      map['phone'] = phone;
    }
    
    if (countryCode != null) {
      map['countryCode'] = countryCode;
    }
    
    return map;
  }
}