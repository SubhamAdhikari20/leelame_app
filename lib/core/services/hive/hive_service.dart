// lib/core/services/hive/hive_service.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:leelame/core/constants/hive_table_constant.dart';
import 'package:leelame/features/buyer/data/models/buyer_hive_model.dart';
import 'package:leelame/features/auth/data/models/user_hive_model.dart';
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
  }

  // Open all boxes
  Future<void> _openBoxes() async {
    await Hive.openBox<UserHiveModel>(HiveTableConstant.usersTable);
    await Hive.openBox<BuyerHiveModel>(HiveTableConstant.buyersTable);
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

  // Check Email Exists
  Future<bool> isEmailExists(String email) async {
    final users = _usersBox.values.where((user) => user.email == email);
    return users.isNotEmpty;
  }

  // get current user
  Future<UserHiveModel?> getCurrentUser(String userId) async {
    return _usersBox.get(userId);
  }

  // ---------------------------- Buyers ------------------------------
  // Get buyers box
  Box<BuyerHiveModel> get _buyersBox =>
      Hive.box<BuyerHiveModel>(HiveTableConstant.buyersTable);

  // Check Username Exists
  Future<bool> isUsernameExists(String username) async {
    final buyers = _buyersBox.values.where(
      (buyer) => buyer.username == username,
    );
    return buyers.isNotEmpty;
  }

  // Check Phone Number Exists
  Future<bool> isPhoneNumberExists(String phoneNumber) async {
    final buyers = _buyersBox.values.where(
      (buyer) => buyer.phoneNumber == phoneNumber,
    );
    return buyers.isNotEmpty;
  }

  // Sign Up Buyer
  Future<BuyerHiveModel?> signUpBuyer(
    UserHiveModel userModel,
    BuyerHiveModel buyerModel,
  ) async {
    // final users = _usersBox.values.where(
    //   (user) => user.email == userModel.email,
    // );
    // if (users.isNotEmpty) {
    //   return null;
    // }
    await _usersBox.put(userModel.userId, userModel);
    await _buyersBox.put(buyerModel.buyerId, buyerModel);
    return buyerModel;
  }

  // Login Buyer
  Future<BuyerHiveModel?> loginBuyer(
    String identifier,
    String password,
    String role,
  ) async {
    final users = _usersBox.values.where(
      (user) => user.email == identifier && user.role == role,
    );

    if (users.isNotEmpty) {
      final user = users.first;
      final buyers = _buyersBox.values.where(
        (buyer) => buyer.userId == user.userId && buyer.password == password,
      );
      if (buyers.isEmpty) {
        return null;
      }
      return buyers.first;
    }

    final buyers = _buyersBox.values.where(
      (buyer) => buyer.username == identifier && buyer.password == password,
    );
    if (buyers.isEmpty) {
      return null;
    }
    return buyers.first;
  }

  // Logout
  Future<void> logoutBuyer() async {}

  // get current buyer
  Future<BuyerHiveModel?> getCurrentBuyer(String buyerId) async {
    return _buyersBox.get(buyerId);
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
}
