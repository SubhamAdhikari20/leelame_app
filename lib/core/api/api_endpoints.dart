// lib/core/api/api_endpoints.dart
import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();
  // Base URL - change this for production
  // static const String baseUrl = "http://10.0.2.2:3000/api";
  // static const String baseUrl = "http://localhost:3000/api";
  // For Android Emulator use: "http://10.0.2.2:3000/api"
  // For iOS Simulator use: "http://localhost:5000/api"
  // For Physical Device use your computer's IP: "http://192.168.x.x:5000/api"

  static const bool isPhysicalDevice = true;
  static const String _ipAddress = "192.168.1.205";
  // static const String _ipAddress = "192.168.1.67";
  static const int _port = 5050;

  // Base URLs
  static String get _host {
    if (isPhysicalDevice) {
      return _ipAddress;
    }
    if (kIsWeb || Platform.isIOS) {
      return "localhost";
    }
    if (Platform.isAndroid) {
      return "10.0.2.2";
    }
    return "localhost";
  }

  static String get serverUrl => "http://$_host:$_port";
  static String get baseUrl => "$serverUrl/api";
  static String get mediaServerUrl => serverUrl;

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ======================= Base User Auth Endpoints =======================
  static const String users = "/users";
  static String userById(String id) => "/user/$id";
  static String userByEmail(String email) => "/user/$email";

  // ======================= Buyer Auth Endpoints =======================
  static const String buyerSignUp = "/users/buyer/sign-up";
  static const String buyerLogin = "/users/buyer/login";
  static const String buyerVerifyAccountRegistration =
      "/users/buyer/verify-account/registration";
  static const String buyerSendVerificationEmailRegistration =
      "/users/buyer/send-verification-email-registration";
  static const String buyerLogout = "/users/buyer/logout";
  static String buyerById(String id) => "/users/buyer/$id";
  static String currentBuyer(String id) => "/users/buyer/get-current-buyer/$id";
  static String buyerByBaseUserId(String baseUserId) =>
      "/users/buyer/$baseUserId";
  static String buyerUploadProfilePicture(String id) =>
      "/users/buyer/upload-profile-picture/$id";
  static String buyerUpdateById(String id) =>
      "/users/buyer/update-profile-details/$id";
  static const String getAllBuyers = "/users/buyer/get-all-buyers";
  static String buyerByUsername(String username) => "/users/buyer/$username";
  static String buyerByPhoneNumber(String phoneNumber) =>
      "/users/buyer/$phoneNumber";

  // ======================= Seller Auth Endpoints =======================
  static const String sellerSignUp = "/users/seller/sign-up";
  static const String sellerLogin = "/users/seller/login";
  static const String sellerVerifyAccountRegistration =
      "/users/seller/verify-account-registration";
  static const String sellerSendVerificationEmailRegistration =
      "/users/seller/send-verification-email-registration";
  static const String sellerLogout = "/users/seller/logout";
  static String sellerById(String id) => "/users/seller/$id";
  static String currentSeller(String id) =>
      "/users/seller/get-current-seller/$id";
  static String sellerByBaseUserId(String baseUserId) =>
      "/users/seller/$baseUserId";
  static String sellerUploadProfilePicture(String id) =>
      "/users/seller/upload-profile-picture/$id";
  static String sellerUpdateById(String id) =>
      "/users/seller/update-profile-details/$id";
  static const String getAllSellers = "/users/seller/get-all-sellers";
  static String sellerByPhoneNumber(String phoneNumber) =>
      "/users/seller/$phoneNumber";

  // ======================= Category Endpoints =======================
  static const String createCategory = "/category/create-category";
  static String updateCategory(String id) =>
      "/category/update-category-details/$id";
  static String deleteCategory(String id) => "/category/delete-category/$id";
  static String categoryById(String id) => "/category/$id";
  static const String getAllCategories = "/category/get-all-categories";

  // ======================= Product Condition Endpoints =======================
  static const String createProductCondition =
      "/product-condition/create-product-condition";
  static String updateProductCondition(String id) =>
      "/product-condition/update-product-condition-details/$id";
  static String deleteProductCondition(String id) =>
      "/product-condition/delete-product-condition/$id";
  static String productConditionById(String id) => "/product-condition/$id";
  static const String getAllProductConditions =
      "/product-condition/get-all-product-conditions";

  // ======================= Product Endpoints =======================
  static const String createProduct = "/product/create-product";
  static String updateProduct(String id) =>
      "/product/update-product-details/$id";
  static String deleteProduct(String id) => "/product/delete-product/$id";
  static String productById(String id) => "/product/$id";
  static const String getAllProducts = "/product/get-all-verified-products";
  static String getAllProductsByBuyerId(String buyerId) =>
      "/product/get-all-verified-products-by-buyerId/$buyerId";
  static String getAllProductsBySellerId(String sellerId) =>
      "/product/get-all-verified-products-by-sellerId/$sellerId";

  // ======================= Bid Endpoints =======================
  static const String createBid = "/bid/create-bid";
  static String updateBid(String id) => "/bid/update-bid-details/$id";
  static String deleteBid(String id) => "/bid/delete-bid/$id";
  static String bidById(String id) => "/bid/$id";
  static const String getAllBids = "/bid/get-all-bids";
  static String getAllBidsByProductId(String productId) =>
      "/bid/get-all-bids/$productId";
  static String getAllBidsByBuyerId(String buyerId) =>
      "/bid/get-all-bids/$buyerId";
  static String getAllBidsBySellerId(String sellerId) =>
      "/bid/get-all-bids/$sellerId";
}
