import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/services/storage/user_session_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final wishlistServiceProvider = Provider<WishlistService>((ref) {
  return WishlistService(prefs: ref.read(sharedPreferencesProvider));
});

class WishlistService {
  WishlistService({required SharedPreferences prefs}) : _prefs = prefs;

  final SharedPreferences _prefs;
  static const String _wishlistKeyPrefix = 'wishlist_product_ids_';

  String _buildKey(String userId) => '$_wishlistKeyPrefix$userId';

  Set<String> getWishlistProductIds(String userId) {
    final list = _prefs.getStringList(_buildKey(userId)) ?? <String>[];
    return list.toSet();
  }

  bool isWishlisted({required String userId, required String productId}) {
    return getWishlistProductIds(userId).contains(productId);
  }

  Future<Set<String>> toggleWishlist({
    required String userId,
    required String productId,
    required bool shouldBeFavorite,
  }) async {
    final current = getWishlistProductIds(userId);

    if (shouldBeFavorite) {
      current.add(productId);
    } else {
      current.remove(productId);
    }

    await _prefs.setStringList(_buildKey(userId), current.toList());
    return current;
  }
}
