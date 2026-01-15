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
  static const String buyers = "/buyers";
  static const String buyerSignUp = "/buyer/sign-up";
  static const String buyerLogin = "/buyer/login";
  static const String buyerLogout = "/buyer/logout";
  static String buyerById(String id) => "/buyer/$id";
  static String buyerByBaseUserId(String baseUserId) => "/buyer/$baseUserId";
  static String buyerByUsername(String username) => "/buyer/$username";
  static String buyerByPhoneNumber(String phoneNumber) => "/buyer/$phoneNumber";
}
