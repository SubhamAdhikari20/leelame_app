// lib/core/services/hive/hive_service.dart
import 'package:hive/hive.dart';
import 'package:leelame/core/constants/hive_table_constant.dart';
import 'package:leelame/features/auth/data/models/buyer_hive_model.dart';
import 'package:leelame/features/auth/data/models/user_hive_model.dart';
import 'package:path_provider/path_provider.dart';

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

  // ========================= CRUD Operations ========================
  // ---------------------------- Users ------------------------------
  // Get users box
  Box<UserHiveModel> get _usersBox =>
      Hive.box<UserHiveModel>(HiveTableConstant.usersTable);

  // Create a new user
  Future<UserHiveModel?> createUser(UserHiveModel userModel) async {
    await _usersBox.put(userModel.id, userModel);
    return userModel;
  }

  // Create a existing user
  Future<UserHiveModel?> updateUser(UserHiveModel userModel) async {
    await _usersBox.put(userModel.id, userModel);
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

  // ---------------------------- Buyers ------------------------------
  // Get buyers box
  Box<BuyerHiveModel> get _buyersBox =>
      Hive.box<BuyerHiveModel>(HiveTableConstant.buyersTable);

  // Create a new buyer
  Future<BuyerHiveModel?> createBuyer(BuyerHiveModel buyerModel) async {
    await _buyersBox.put(buyerModel.id, buyerModel);
    return buyerModel;
  }

  // Create a existing buyer
  Future<BuyerHiveModel?> updateBuyer(BuyerHiveModel buyerModel) async {
    await _buyersBox.put(buyerModel.id, buyerModel);
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
