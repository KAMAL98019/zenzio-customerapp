class StatusCodes {
  static const String invalidLogin = "INVALID_LOGIN_CREDENTIALS";
  static const String userNotFound = "USER_NOT_FOUND";
  static const String emailExists = "EMAIL_ALREADY_EXISTS";
  static const String phoneExists = "PHONE_ALREADY_EXISTS";
  static const String accountDisabled = "ACCOUNT_DISABLED";
  static const String invalidOTP = "INVALID_OTP";
  static const String expiredOTP = "EXPIRED_OTP";
  static const String unauthorized = "UNAUTHORIZED";
  static const String forbidden = "FORBIDDEN";
  static const String notAllowed = "NOT_ALLOWED";
}

class StatusMessages {
  static String get(String code) {
    switch (code) {
      case StatusCodes.invalidLogin:
        return "Incorrect email or password";

      case StatusCodes.userNotFound:
        return "User not found";

      case StatusCodes.emailExists:
        return "Email already registered";

      case StatusCodes.phoneExists:
        return "Phone number already registered";

      case StatusCodes.accountDisabled:
        return "Your account is disabled";

      case StatusCodes.invalidOTP:
        return "Invalid OTP entered";

      case StatusCodes.expiredOTP:
        return "OTP expired. Please request a new one.";

      case StatusCodes.unauthorized:
        return "Unauthorized access";

      case StatusCodes.forbidden:
        return "You do not have permission to perform this action";

      case StatusCodes.notAllowed:
        return "Action not allowed";

      default:
        return "Something went wrong. Please try again."; // safer fallback
    }
  }
}
