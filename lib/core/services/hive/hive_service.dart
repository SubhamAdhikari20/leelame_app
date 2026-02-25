// lib/core/services/hive/hive_service.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:leelame/core/constants/hive_table_constant.dart';
import 'package:leelame/features/buyer/data/models/buyer_hive_model.dart';
import 'package:leelame/features/auth/data/models/user_hive_model.dart';
import 'package:leelame/features/category/data/models/category_hive_model.dart';
import 'package:leelame/features/product/data/models/product_hive_model.dart';
import 'package:leelame/features/product_condition/data/models/product_condition_hive_model.dart';
import 'package:leelame/features/seller/data/models/seller_hive_model.dart';
import 'package:path_provider/path_provider.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

class HiveService {
  // Initialize Hive
  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/${HiveTableConstant.dbName}";

    Hive.init(path);
    _registerAdapters();
    await _openBoxes();
  }

  // Register All Types of adapters
  void _registerAdapters() {
    if (!Hive.isAdapterRegistered(HiveTableConstant.usersTypeId)) {
      Hive.registerAdapter(UserHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTableConstant.buyersTypeId)) {
      Hive.registerAdapter(BuyerHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTableConstant.sellersTypeId)) {
      Hive.registerAdapter(SellerHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTableConstant.categoriesTypeId)) {
      Hive.registerAdapter(CategoryHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTableConstant.productConditionsTypeId)) {
      Hive.registerAdapter(ProductConditionHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTableConstant.productsTypeId)) {
      Hive.registerAdapter(ProductHiveModelAdapter());
    }
    // if (!Hive.isAdapterRegistered(HiveTableConstant.pendingEmailsTypeId)) {
    //   Hive.registerAdapter(BuyerHiveModelAdapter());
    // }
  }

  // Open all boxes
  Future<void> _openBoxes() async {
    await Hive.openBox<UserHiveModel>(HiveTableConstant.usersTable);
    await Hive.openBox<BuyerHiveModel>(HiveTableConstant.buyersTable);
    await Hive.openBox<BuyerHiveModel>(HiveTableConstant.pendingEmailsTable);
    await Hive.openBox<SellerHiveModel>(HiveTableConstant.sellersTable);
    await Hive.openBox<CategoryHiveModel>(HiveTableConstant.categoriesTable);
    await Hive.openBox<ProductConditionHiveModel>(
      HiveTableConstant.productConditionsTable,
    );
    await Hive.openBox<ProductHiveModel>(HiveTableConstant.productsTable);
  }

  // Close all boxes
  Future<void> closeBoxes() async {
    await Hive.close();
  }

  // The box file is deleted. Need to open the box again to use it.
  Future<void> deleteEntireBox() async {
    var box = await Hive.openBox('myBox');
    await box.deleteFromDisk();
  }

  // All Hive data associated with the application is removed.
  Future<void> deleteAllDatabases() async {
    await Hive.deleteFromDisk();
  }

  // ========================= CRUD Operations ========================
  // ---------------------------- Users ------------------------------
  // Get users box
  Box<UserHiveModel> get _usersBox =>
      Hive.box<UserHiveModel>(HiveTableConstant.usersTable);

  // Create a new user
  Future<UserHiveModel?> createUser(UserHiveModel userModel) async {
    await _usersBox.put(userModel.userId, userModel);
    return userModel;
  }

  // Create a existing user
  Future<UserHiveModel?> updateUser(UserHiveModel userModel) async {
    await _usersBox.put(userModel.userId, userModel);
    return userModel;
  }

  // Get a existing user by ID
  Future<UserHiveModel?> getUserById(String userId) async {
    return _usersBox.get(userId);
  }

  // Get a existing user by email
  Future<UserHiveModel?> getUserByEmail(String email) async {
    final users = _usersBox.values.where((user) => user.email == email);
    return users.first;
  }

  // Get all users
  Future<List<UserHiveModel>> getAllUsers() async {
    return _usersBox.values.toList();
  }

  // Delete a user
  Future<void> deleteUser(String userId) async {
    await _usersBox.delete(userId);
  }

  // Delete all users
  Future<void> deleteAllUsers() async {
    await _usersBox.clear();
  }

  // ---------------------------- Buyers ------------------------------
  // Get buyers box
  Box<BuyerHiveModel> get _buyersBox =>
      Hive.box<BuyerHiveModel>(HiveTableConstant.buyersTable);

  Future<BuyerHiveModel?> createBuyer(BuyerHiveModel buyerModel) async {
    await _buyersBox.put(buyerModel.buyerId, buyerModel);
    return buyerModel;
  }

  // Create a existing buyer
  Future<BuyerHiveModel?> updateBuyer(BuyerHiveModel buyerModel) async {
    await _buyersBox.put(buyerModel.buyerId, buyerModel);
    return buyerModel;
  }

  // Get a existing buyer by ID
  Future<BuyerHiveModel?> getBuyerById(String buyerId) async {
    return _buyersBox.get(buyerId);
  }

  // Get a existing buyer by Base User ID
  Future<BuyerHiveModel?> getBuyerByBaseUserId(String userId) async {
    return _buyersBox.get(userId);
  }

  // Get a existing buyer by username
  Future<BuyerHiveModel?> getBuyerByUsername(String username) async {
    final buyers = _buyersBox.values.where(
      (buyer) => buyer.username == username,
    );
    return buyers.first;
  }

  // Get a existing buyer by phoneNumber
  Future<BuyerHiveModel?> getBuyerByPhoneNumber(String phoneNumber) async {
    final buyers = _buyersBox.values.where(
      (buyer) => buyer.phoneNumber == phoneNumber,
    );
    return buyers.first;
  }

  // Get all buyers
  Future<List<BuyerHiveModel>> getAllBuyers() async {
    return _buyersBox.values.toList();
  }

  // Delete a buyer
  Future<void> deleteBuyer(String buyerId) async {
    await _buyersBox.delete(buyerId);
  }

  // Delete all buyers
  Future<void> deleteAllBuyers() async {
    await _buyersBox.clear();
  }

  // ---------------------------- Pending Emails Queue ------------------------------
  // Get pending emails box
  Box<Map<String, dynamic>> get _pendingEmailsBox =>
      Hive.box<Map<String, dynamic>>(HiveTableConstant.pendingEmailsTable);

  // Queue OTP email
  Future<String> queueOtpEmail({
    required String toEmail,
    required String fullName,
    required String otp,
    DateTime? expiryDate,
  }) async {
    final key = DateTime.now().millisecondsSinceEpoch.toString();
    final data = {
      'toEmail': toEmail,
      'fullName': fullName,
      'otp': otp,
      'expiryDate': expiryDate,
      'createdAt': DateTime.now().toIso8601String(),
      'attempts': 0,
    };
    await _pendingEmailsBox.put(key, data);
    return key;
  }

  // Returns a list of pending email entries. Each entry ALWAYS includes 'key' for deletion.
  Future<List<Map<String, dynamic>>> getPendingEmails() async {
    final List<Map<String, dynamic>> out = [];
    for (final key in _pendingEmailsBox.keys) {
      final value = _pendingEmailsBox.get(key);
      if (value is Map) {
        final map = Map<String, dynamic>.from(value as Map);
        map['key'] = key.toString();
        out.add(map);
      }
    }
    return out;
  }

  // Delete from queue
  Future<void> deleteFromQueue(String key) async {
    await _pendingEmailsBox.delete(key);
  }

  // Increment attempts counter for a queue item
  Future<void> incrementQueueAttempts(String key) async {
    final value = _pendingEmailsBox.get(key);
    if (value is Map) {
      final m = Map<String, dynamic>.from(value as Map);
      final attempts = (m['attempts'] as int?) ?? 0;
      m['attempts'] = attempts + 1;
      await _pendingEmailsBox.put(key, m);
    }
  }

  // ---------------------------- Sellers ------------------------------
  // Get sellers box
  Box<SellerHiveModel> get _sellersBox =>
      Hive.box<SellerHiveModel>(HiveTableConstant.sellersTable);

  Future<SellerHiveModel?> createSeller(SellerHiveModel sellerModel) async {
    await _sellersBox.put(sellerModel.sellerId, sellerModel);
    return sellerModel;
  }

  // Create a existing seller
  Future<SellerHiveModel?> updateSeller(SellerHiveModel sellerModel) async {
    await _sellersBox.put(sellerModel.sellerId, sellerModel);
    return sellerModel;
  }

  // Get a existing seller by ID
  Future<SellerHiveModel?> getSellerById(String sellerId) async {
    return _sellersBox.get(sellerId);
  }

  // Get a existing seller by Base User ID
  Future<SellerHiveModel?> getSellerByBaseUserId(String userId) async {
    return _sellersBox.get(userId);
  }

  // Get a existing seller by phoneNumber
  Future<SellerHiveModel?> getSellerByPhoneNumber(String phoneNumber) async {
    final sellers = _sellersBox.values.where(
      (seller) => seller.phoneNumber == phoneNumber,
    );
    return sellers.first;
  }

  // Get all sellers
  Future<List<SellerHiveModel>> getAllSellers() async {
    return _sellersBox.values.toList();
  }

  // Delete a seller
  Future<void> deleteSeller(String sellerId) async {
    await _sellersBox.delete(sellerId);
  }

  // Delete all sellers
  Future<void> deleteAllSellers() async {
    await _sellersBox.clear();
  }

  // ---------------------- Category CRUD Operations -------------------------
  // Get category box
  Box<CategoryHiveModel> get _categoryBox =>
      Hive.box(HiveTableConstant.categoriesTable);

  // Create a new category
  Future<CategoryHiveModel?> createCategory(CategoryHiveModel category) async {
    await _categoryBox.put(category.categoryId, category);
    return category;
  }

  // Update a existing category
  Future<CategoryHiveModel?> updateCategory(CategoryHiveModel category) async {
    await _categoryBox.put(category.categoryId, category);
    return category;
  }

  // Get a existing category by ID
  Future<CategoryHiveModel?> getCategoryById(String categoryId) async {
    return _categoryBox.get(categoryId);
  }

  // Get a existing category by category name
  Future<CategoryHiveModel?> getCategoryByCategoryName(
    String categoryName,
  ) async {
    final categories = _categoryBox.values.where(
      (category) => category.categoryName == categoryName,
    );
    return categories.first;
  }

  // Get all categories
  Future<List<CategoryHiveModel>> getAllCategories() async {
    return _categoryBox.values.toList();
  }

  // Delete a category
  Future<bool> deleteCategory(String categoryId) async {
    await _categoryBox.delete(categoryId);
    return true;
  }

  // Delete all categories
  Future<bool> deleteAllCategories() async {
    await _categoryBox.clear();
    return true;
  }

  // ---------------------- Product Condition CRUD Operations -------------------------
  // Get product condition box
  Box<ProductConditionHiveModel> get _productConditionBox =>
      Hive.box(HiveTableConstant.productConditionsTable);

  // Create a new product condition
  Future<ProductConditionHiveModel?> createProductCondition(
    ProductConditionHiveModel productCondition,
  ) async {
    await _productConditionBox.put(
      productCondition.productConditionId,
      productCondition,
    );
    return productCondition;
  }

  // Update a existing product condition
  Future<ProductConditionHiveModel?> updateProductCondition(
    ProductConditionHiveModel productCondition,
  ) async {
    await _productConditionBox.put(
      productCondition.productConditionId,
      productCondition,
    );
    return productCondition;
  }

  // Get a existing product condition by ID
  Future<ProductConditionHiveModel?> getProductConditionById(
    String productConditionId,
  ) async {
    return _productConditionBox.get(productConditionId);
  }

  // Get a existing product condition by product condition name
  Future<ProductConditionHiveModel?> getProductConditionByProductConditionName(
    String productConditionName,
  ) async {
    final productConditions = _productConditionBox.values.where(
      (productCondition) =>
          productCondition.productConditionName == productConditionName,
    );
    return productConditions.first;
  }

  // Get all product conditions
  Future<List<ProductConditionHiveModel>> getAllProductConditions() async {
    return _productConditionBox.values.toList();
  }

  // Delete a product condition
  Future<bool> deleteProductCondition(String productConditionId) async {
    await _productConditionBox.delete(productConditionId);
    return true;
  }

  // Delete all product conditions
  Future<bool> deleteAllProductConditions() async {
    await _productConditionBox.clear();
    return true;
  }

  // ---------------------- Product CRUD Operations -------------------------
  // Get product box
  Box<ProductHiveModel> get _productBox =>
      Hive.box(HiveTableConstant.productsTable);

  // Create a new product
  Future<ProductHiveModel?> createProduct(ProductHiveModel product) async {
    await _productBox.put(product.productId, product);
    return product;
  }

  // Update a existing product
  Future<ProductHiveModel?> updateProduct(ProductHiveModel product) async {
    await _productBox.put(product.productId, product);
    return product;
  }

  // Get a existing product by ID
  Future<ProductHiveModel?> getProductById(String productId) async {
    return _productBox.get(productId);
  }

  // Get all products
  Future<List<ProductHiveModel>> getAllProducts() async {
    final products = _productBox.values.where(
      (product) => product.isVerified == true,
    );
    return products.toList();
  }

  // Get all products by buyer ID
  Future<List<ProductHiveModel>> getAllProductsByBuyerId(String buyerId) async {
    final products = _productBox.values.where(
      (product) =>
          ((product.soldToBuyerId == buyerId) && (product.isVerified == true)),
    );
    return products.toList();
  }

  // Delete a product
  Future<bool> deleteProduct(String productId) async {
    await _productBox.delete(productId);
    return true;
  }

  // Delete all products
  Future<bool> deleteAllProducts() async {
    await _productBox.clear();
    return true;
  }
}
