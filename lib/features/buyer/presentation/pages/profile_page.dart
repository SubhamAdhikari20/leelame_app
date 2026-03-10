// lib/features/buyer/presentation/pages/profile_page.dart
import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/app/routes/app_routes.dart';
import 'package:leelame/app/theme/app_colors.dart';
import 'package:leelame/core/services/proximity_service.dart';
import 'package:leelame/core/services/storage/user_session_service.dart';
import 'package:leelame/core/services/storage/wishlist_service.dart';
import 'package:leelame/core/utils/snackbar_util.dart';
import 'package:leelame/features/auth/presentation/pages/buyer/buyer_login_page.dart';
import 'package:leelame/features/auth/presentation/states/buyer_auth_state.dart';
import 'package:leelame/features/auth/presentation/view_models/buyer_auth_view_model.dart';
import 'package:leelame/features/bid/domain/entities/bid_entity.dart';
import 'package:leelame/features/bid/presentation/states/bid_state.dart';
import 'package:leelame/features/bid/presentation/view_models/bid_view_model.dart';
import 'package:leelame/features/buyer/presentation/pages/edit_profile_page.dart';
import 'package:leelame/features/buyer/presentation/states/buyer_state.dart';
import 'package:leelame/features/buyer/presentation/view_models/buyer_view_model.dart';
import 'package:leelame/features/product/domain/entities/product_entity.dart';
import 'package:leelame/features/product/presentation/states/product_state.dart';
import 'package:leelame/features/product/presentation/viewmodels/product_view_model.dart';
import 'package:sensors_plus/sensors_plus.dart';

enum _ProfileBidStatus { winning, outbid, won, lost }

class _ProfileStats {
  final int activeBids;
  final int wonBids;
  final int watchlistCount;

  const _ProfileStats({
    required this.activeBids,
    required this.wonBids,
    required this.watchlistCount,
  });
}

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final ProximitySensorService _proximitySvc = ProximitySensorService();
  StreamSubscription<AccelerometerEvent>? _accelSub;
  DateTime? _lastShake;
  int _shakeCount = 0;

  static const double _shakeThreshold = 15;
  static const Duration _shakeInterval = Duration(milliseconds: 500);
  static const int _requiredShakes = 2;

  @override
  void initState() {
    super.initState();
    _proximitySvc.start();
    _proximitySvc.isPrivacyMode.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentUser();
      _startShake();
    });
  }

  Future<void> _loadCurrentUser() async {
    final userSessionService = ref.read(userSessionServiceProvider);
    final buyerId = userSessionService.getUserId();
    if (buyerId != null) {
      await Future.wait([
        ref
            .read(buyerViewModelProvider.notifier)
            .getCurrentUser(buyerId: buyerId),
        ref.read(bidViewModelProvider.notifier).getAllBids(),
        ref.read(productViewModelProvider.notifier).getAllProducts(),
      ]);
    }
  }

  void _startShake() {
    if (_accelSub != null) {
      return;
    }

    _accelSub = accelerometerEventStream().listen((event) {
      final magnitude = sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      );

      if (magnitude > _shakeThreshold) {
        final now = DateTime.now();
        if (_lastShake != null &&
            now.difference(_lastShake!) < _shakeInterval) {
          _shakeCount++;
        } else {
          _shakeCount = 1;
        }
        _lastShake = now;

        if (_shakeCount >= _requiredShakes) {
          _shakeCount = 0;
          _onDeviceShaken();
        }
      }
    });
  }

  Future<void> _onDeviceShaken() async {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Refreshing profile...'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );

    try {
      await _loadCurrentUser();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile refreshed'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to refresh profile: ${e.toString()}'),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _accelSub?.cancel();
    _proximitySvc.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    await ref.read(buyerAuthViewModelProvider.notifier).logout();
  }

  _ProfileStats _buildProfileStats({
    required String? buyerId,
    required List<BidEntity> bids,
    required List<ProductEntity> products,
    required Set<String> wishlistedProductIds,
  }) {
    if (buyerId == null) {
      return _ProfileStats(
        activeBids: 0,
        wonBids: 0,
        watchlistCount: wishlistedProductIds.length,
      );
    }

    const epsilon = 0.0001;
    final now = DateTime.now();
    final productById = {
      for (final product in products)
        if (product.productId != null) product.productId!: product,
    };

    final allBidsByProduct = <String, List<BidEntity>>{};
    final myBidsByProduct = <String, List<BidEntity>>{};

    for (final bid in bids) {
      final productId = bid.productId;
      if (productId == null) {
        continue;
      }

      allBidsByProduct.putIfAbsent(productId, () => []).add(bid);
      if (bid.buyerId == buyerId) {
        myBidsByProduct.putIfAbsent(productId, () => []).add(bid);
      }
    }

    var activeCount = 0;
    var wonCount = 0;

    myBidsByProduct.forEach((productId, myProductBids) {
      final product = productById[productId];
      if (product == null) {
        return;
      }

      final myHighestBid = myProductBids
          .map((bid) => bid.bidAmount)
          .fold<double>(0, (prev, amount) => max(prev, amount));

      final highestBidFromAllBids =
          (allBidsByProduct[productId] ?? const <BidEntity>[])
              .map((bid) => bid.bidAmount)
              .fold<double>(0, (prev, amount) => max(prev, amount));

      final effectiveHighestBid = max(
        product.currentBidPrice,
        highestBidFromAllBids,
      );
      final isMyTopBid = (myHighestBid + epsilon) >= effectiveHighestBid;

      final isAuctionEnded =
          product.endDate.toLocal().isBefore(now) || product.isSoldOut;
      final isSoldToMe =
          product.soldToBuyerId != null && product.soldToBuyerId == buyerId;
      final isSoldToOther =
          product.soldToBuyerId != null && product.soldToBuyerId != buyerId;

      final _ProfileBidStatus status;
      if (isSoldToMe || (isAuctionEnded && !isSoldToOther && isMyTopBid)) {
        status = _ProfileBidStatus.won;
      } else if (isAuctionEnded || isSoldToOther) {
        status = _ProfileBidStatus.lost;
      } else if (isMyTopBid) {
        status = _ProfileBidStatus.winning;
      } else {
        status = _ProfileBidStatus.outbid;
      }

      if (status == _ProfileBidStatus.won) {
        wonCount++;
      }

      if (status == _ProfileBidStatus.winning ||
          status == _ProfileBidStatus.outbid) {
        activeCount++;
      }
    });

    return _ProfileStats(
      activeBids: activeCount,
      wonBids: wonCount,
      watchlistCount: wishlistedProductIds.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isPrivate = _proximitySvc.isPrivacyMode.value;

    final buyerAuthState = ref.watch(buyerAuthViewModelProvider);
    final buyerState = ref.watch(buyerViewModelProvider);
    final bidState = ref.watch(bidViewModelProvider);
    final productState = ref.watch(productViewModelProvider);
    final userData = buyerState.buyer;
    final buyerId =
        userData?.buyerId ?? ref.read(userSessionServiceProvider).getUserId();

    final profileStats = _buildProfileStats(
      buyerId: buyerId,
      bids: bidState.bids,
      products: productState.products,
      wishlistedProductIds: buyerId == null
          ? const <String>{}
          : ref.read(wishlistServiceProvider).getWishlistProductIds(buyerId),
    );

    ref.listen<BuyerState>(buyerViewModelProvider, (previous, next) {
      if ((next.buyerStatus == BuyerStatus.error)) {
        SnackbarUtil.showError(
          context,
          next.errorMessage ?? "Error loading current user!",
        );
      }
    });

    ref.listen<BidState>(bidViewModelProvider, (previous, next) {
      if (next.bidStatus == BidStatus.error &&
          previous?.bidStatus != BidStatus.error) {
        SnackbarUtil.showError(
          context,
          next.errorMessage ?? "Error loading bid summary!",
        );
      }
    });

    ref.listen<ProductState>(productViewModelProvider, (previous, next) {
      if (next.productStatus == ProductStatus.error &&
          previous?.productStatus != ProductStatus.error) {
        SnackbarUtil.showError(
          context,
          next.errorMessage ?? "Error loading product summary!",
        );
      }
    });

    ref.listen<BuyerAuthState>(buyerAuthViewModelProvider, (previous, next) {
      if ((next.buyerAuthStatus == BuyerAuthStatus.error)) {
        SnackbarUtil.showError(
          context,
          next.errorMessage ?? "Error in logging out the user!",
        );
      } else if (next.buyerAuthStatus == BuyerAuthStatus.unauthenticated) {
        SnackbarUtil.showSuccess(context, "Logged out successfully.");

        // Navigate to login page
        AppRoutes.pushAndRemoveUntil(context, const BuyerLoginPage());
      }
    });

    return Scaffold(
      body: buyerAuthState.buyerAuthStatus == BuyerAuthStatus.loading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blueGrey),
                strokeWidth: 3,
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Header with gradient background
                    Container(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(32),
                          bottomRight: Radius.circular(32),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Profile Picture
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: const [
                                BoxShadow(
                                  color: AppColors.black20,
                                  blurRadius: 20,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: isTablet ? 72 : 60,
                              backgroundColor: Colors.white,
                              backgroundImage:
                                  buyerState.buyer?.profilePictureUrl != null &&
                                      !isPrivate
                                  ? NetworkImage(
                                      buyerState.buyer!.profilePictureUrl!,
                                    )
                                  : null,
                              child:
                                  buyerState.buyer?.profilePictureUrl == null ||
                                      isPrivate
                                  ? Icon(
                                      Icons.person_rounded,
                                      size: isTablet ? 70 : 60,
                                      color: Colors.black54,
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 16),
                          PrivacyText(
                            userData?.fullName ?? "Guest",
                            isPrivate: isPrivate,
                            style: TextStyle(
                              fontSize: isTablet ? 28 : 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),

                          PrivacyText(
                            userData?.username ?? "guest07",
                            isPrivate: isPrivate,
                            style: TextStyle(
                              fontSize: isTablet ? 17 : 16,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 4),

                          PrivacyText(
                            userData?.userEntity?.email ?? "guest@gmail.com.np",
                            isPrivate: isPrivate,
                            style: TextStyle(
                              fontSize: isTablet ? 15 : 14,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 24),

                          if (isPrivate)
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.visibility_off_outlined,
                                    color: Colors.orange.shade800,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Privacy mode active',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.orange.shade900,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Stats Row
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _StatItem(
                                  title: 'Active Bids',
                                  value: isPrivate
                                      ? '●●'
                                      : '${profileStats.activeBids}',
                                  isTablet: isTablet,
                                ),
                                Container(
                                  width: 1,
                                  height: 40,
                                  color: AppColors.white30,
                                ),
                                _StatItem(
                                  title: 'Won Bids',
                                  value: isPrivate
                                      ? '●●'
                                      : '${profileStats.wonBids}',
                                  isTablet: isTablet,
                                ),
                                Container(
                                  width: 1,
                                  height: 40,
                                  color: AppColors.white30,
                                ),
                                _StatItem(
                                  title: 'Watchlist',
                                  value: isPrivate
                                      ? '●●'
                                      : '${profileStats.watchlistCount}',
                                  isTablet: isTablet,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Menu Items
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 40.0 : 20.0,
                      ),
                      child: Column(
                        children: [
                          _MenuItem(
                            icon: Icons.person_outline_rounded,
                            title: 'Edit Profile',
                            onTap: () {
                              AppRoutes.push(
                                context,
                                EditProfilePage(buyerId: userData!.buyerId!),
                                // EditProfilePage(
                                //   buyerUiModel: userData != null
                                //       ? BuyerUiModel.fromEntity(userData)
                                //       : null,
                                // ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),

                          _MenuItem(
                            icon: Icons.logout_rounded,
                            title: 'Logout',
                            iconColor: AppColors.error,
                            titleColor: AppColors.error,
                            onTap: () {
                              _showLogoutDialog(context);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () {
              AppRoutes.pop(context);
            },
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textPrimaryColor),
            ),
          ),
          TextButton(
            onPressed: () async {
              AppRoutes.pop(context);
              await _handleLogout();
            },
            child: Text(
              'Logout',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String title;
  final String value;
  final bool isTablet;

  const _StatItem({
    required this.title,
    required this.value,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: isTablet ? 26 : 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: isTablet ? 13 : 12,
            color: AppColors.white80,
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? titleColor;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: (iconColor ?? AppColors.primaryButtonColor)
                        .withAlpha(26), // 10% opacity
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? AppColors.primaryButtonColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: titleColor ?? AppColors.textPrimaryColor,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.black20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
