// lib/core/constants/hive_table_constant.dart
class HiveTableConstant {
  HiveTableConstant._();

  // Database Name
  static const String dbName = "leelame";

  static const int usersTypeId = 0;
  static const String usersTable = "users";

  static const int buyersTypeId = 1;
  static const String buyersTable = "buyers";

  static const int pendingEmailsTypeId = 2;
  static const String pendingEmailsTable = "pending_emails";

  static const int sellersTypeId = 3;
  static const String sellersTable = "sellers";

  static const int productsTypeId = 4;
  static const String productsTable = "products";

  static const int categoriesTypeId = 5;
  static const String categoriesTable = "categories";

  static const int productConditionsTypeId = 6;
  static const String productConditionsTable = "product_conditions";

  static const int bidsTypeId = 7;
  static const String bidsTable = "bids";
}
