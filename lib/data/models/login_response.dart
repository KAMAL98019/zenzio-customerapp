import 'user_model.dart';

class LoginResponse {
  final String? token;
  final String? refreshToken;
  final User? user;
  final String? message;

  LoginResponse({
    this.token,
    this.refreshToken,
    this.user,
    this.message,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json['user']; // ✅ Handles both formats

    return LoginResponse(
      token: json['token'] ?? json['access_token'],
      refreshToken: json['refreshToken'] ?? json['refresh_token'],
      user: data != null ? User.fromJson(data) : null,
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'refreshToken': refreshToken,
      'user': user?.toJson(),
      'message': message,
    };
  }
}
