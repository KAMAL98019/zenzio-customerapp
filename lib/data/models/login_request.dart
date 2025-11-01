class LoginRequest {
  final String? email;
  final String? phone;
  final String? countryCode;
  final String password;

  LoginRequest({
    this.email,
    this.phone,
    this.countryCode,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'password': password,
    };
    
    if (email != null) {
      map['email'] = email;
    }
    
    if (phone != null) {
      map['phone'] = phone;
      if (countryCode != null) {
        map['countryCode'] = countryCode;
      }
    }
    
    return map;
  }
}