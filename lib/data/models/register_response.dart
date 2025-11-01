import 'user_model.dart';


class RegisterResponse {
  final String? token;
  final String? refreshToken;
  final User? user;
  final String? message;

  RegisterResponse({
    this.token,
    this.refreshToken,
    this.user,
    this.message,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      token: json['token'] ?? json['access_token'],
      refreshToken: json['refreshToken'] ?? json['refresh_token'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
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