// lib/core/api/api_endpoints.dart
class ApiEndpoints {
  ApiEndpoints._();
  // Base URL - change this for production
  static const String baseUrl = "http://10.0.2.2:3000/api/v1";
  //static const String baseUrl = "http://localhost:3000/api/v1";
  // For Android Emulator use: "http://10.0.2.2:3000/api/v1"
  // For iOS Simulator use: "http://localhost:5000/api/v1"
  // For Physical Device use your computer's IP: "http://192.168.x.x:5000/api/v1"

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ======================= Base User Auth Endpoints =======================
  static const String users = "/users";
  static String userById(String id) => "/user/$id";
  static String userByEmail(String email) => "/user/$email";

  // ======================= Buyer Auth Endpoints =======================
  static const String buyers = "/users/buyer";
  static const String buyerSignUp = "/users/buyer/sign-up";
  static const String buyerLogin = "/users/buyer/login";
  static const String buyerVerifyAccountRegistration =
      "/users/buyer/verify-account-registration";
  static const String buyerSendVerificationEmailRegistration =
      "/users/buyer/send-verification-email-registration";
  static const String buyerLogout = "/users/buyer/logout";
  static String buyerById(String id) => "/users/buyer/$id";
  static String buyerByBaseUserId(String baseUserId) =>
      "/users/buyer/$baseUserId";
  static String buyerByUsername(String username) => "/users/buyer/$username";
  static String buyerByPhoneNumber(String phoneNumber) =>
      "/users/buyer/$phoneNumber";

  // ======================= Seller Auth Endpoints =======================
  static const String sellers = "/users/seller";
  static const String sellerSignUp = "/users/seller/sign-up";
  static const String sellerLogin = "/users/seller/login";
  static const String sellerVerifyAccountRegistration =
      "/users/seller/verify-account-registration";
  static const String sellerSendVerificationEmailRegistration =
      "/users/seller/send-verification-email-registration";
  static const String sellerLogout = "/users/seller/logout";
  static String sellerById(String id) => "/users/seller/$id";
  static String sellerByBaseUserId(String baseUserId) =>
      "/users/seller/$baseUserId";
  static String sellerByPhoneNumber(String phoneNumber) =>
      "/users/seller/$phoneNumber";
}
