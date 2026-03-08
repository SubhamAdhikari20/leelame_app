// lib/features/seller/presentation/pages/screens/seller_profile_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/app/routes/app_routes.dart';
import 'package:leelame/app/theme/app_colors.dart';
import 'package:leelame/core/services/proximity_service.dart';
import 'package:leelame/core/services/storage/user_session_service.dart';
import 'package:leelame/core/utils/snackbar_util.dart';
import 'package:leelame/features/auth/presentation/pages/seller/seller_login_sign_up_page.dart';
import 'package:leelame/features/auth/presentation/states/seller_auth_state.dart';
import 'package:leelame/features/auth/presentation/view_models/seller_auth_view_model.dart';
import 'package:leelame/features/product/presentation/models/product_ui_model.dart';
import 'package:leelame/features/product/presentation/states/product_state.dart';
import 'package:leelame/features/product/presentation/viewmodels/product_view_model.dart';
import 'package:leelame/features/seller/presentation/models/seller_ui_model.dart';
import 'package:leelame/features/seller/presentation/pages/seller_edit_profile_page.dart';
import 'package:leelame/features/seller/presentation/states/seller_state.dart';
import 'package:leelame/features/seller/presentation/view_models/seller_view_model.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SellerProfileScreen extends ConsumerStatefulWidget {
  const SellerProfileScreen({super.key});

  @override
  ConsumerState<SellerProfileScreen> createState() =>
      _SellerProfileScreenState();
}

class _SellerProfileScreenState extends ConsumerState<SellerProfileScreen> {
  final ProximitySensorService _proximitySvc = ProximitySensorService();
  StreamSubscription<AccelerometerEvent>? _accelSub;
  DateTime? _lastShake;
  int _shakeCount = 0;

  @override
  void initState() {
    super.initState();
    _proximitySvc.start();
    _proximitySvc.isPrivacyMode.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();

      _startShake();
    });
  }

  void _loadData() {
    final sellerId = ref.read(userSessionServiceProvider).getUserId();
    if (sellerId != null) {
      ref
          .read(sellerViewModelProvider.notifier)
          .getCurrentUser(sellerId: sellerId);
      ref
          .read(productViewModelProvider.notifier)
          .getAllProductsBySellerId(sellerId);
    }
  }

  void _startShake() {
    _accelSub = accelerometerEventStream().listen((e) {
      final mag = sqrt(e.x * e.x + e.y * e.y + e.z * e.z);
      if (mag > 15) {
        final now = DateTime.now();
        if (_lastShake != null &&
            now.difference(_lastShake!) < const Duration(milliseconds: 500)) {
          _shakeCount++;
        } else {
          _shakeCount = 1;
        }
        _lastShake = now;
        if (_shakeCount >= 2) {
          _shakeCount = 0;
          _loadData();
          if (mounted) SnackbarUtil.showSuccess(context, 'Profile refreshed');
        }
      }
    });
  }

  @override
  void dispose() {
    _proximitySvc.dispose();
    _accelSub?.cancel();
    super.dispose();
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(sellerAuthViewModelProvider.notifier).logout();
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

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productViewModelProvider);
    final sellerState = ref.watch(sellerViewModelProvider);
    final seller = sellerState.seller;
    final isPrivate = _proximitySvc.isPrivacyMode.value;

    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    ref.listen<SellerState>(sellerViewModelProvider, (_, next) {
      if (next.sellerStatus == SellerStatus.error) {
        SnackbarUtil.showError(
          context,
          next.errorMessage ?? 'Error loading profile.',
        );
      }
    });

    ref.listen<SellerAuthState>(sellerAuthViewModelProvider, (_, next) {
      if (next.sellerAuthStatus == SellerAuthStatus.unauthenticated) {
        AppRoutes.pushAndRemoveUntil(context, const SellerLoginSignUpPage());
      }
    });

    ref.listen<ProductState>(productViewModelProvider, (_, next) {
      if (next.productStatus == ProductStatus.error) {
        SnackbarUtil.showError(
          context,
          next.errorMessage ?? 'Error loading products.',
        );
      } else if (next.productStatus != ProductStatus.loaded) {
        SnackbarUtil.showError(
          context,
          next.errorMessage ?? 'Error loading products.',
        );
      }
    });

    if (sellerState.sellerStatus == SellerStatus.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return seller == null
        ? Scaffold(
            body: Center(
              child: Text(
                'Seller not found.',
                style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
              ),
            ),
          )
        : Scaffold(
            backgroundColor: const Color(0xFFF7F8FC),
            body: SafeArea(
              child: isTablet && isLandscape
                  ? Row(
                      children: [
                        Expanded(
                          child: _buildHeader(
                            seller: SellerUiModel.fromEntity(seller),
                            productState: productState,
                            isPrivate: isPrivate,
                            isTablet: isTablet,
                            isColumn: true,
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(32),
                            child: _buildMenuBody(
                              seller: SellerUiModel.fromEntity(seller),
                              isPrivate: isPrivate,
                              isTablet: isTablet,
                            ),
                          ),
                        ),
                      ],
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildHeader(
                            seller: SellerUiModel.fromEntity(seller),
                            productState: productState,
                            isPrivate: isPrivate,
                            isTablet: isTablet,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 40 : 20,
                              vertical: 24,
                            ),
                            child: _buildMenuBody(
                              seller: SellerUiModel.fromEntity(seller),
                              isPrivate: isPrivate,
                              isTablet: isTablet,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          );
  }

  Widget _buildHeader({
    required SellerUiModel seller,
    required ProductState productState,
    required bool isPrivate,
    required bool isTablet,
    bool isColumn = false,
  }) {
    final avatarRadius = isTablet ? 70.0 : 56.0;
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.auctionPrimaryGradient,
        borderRadius: isColumn
            ? null
            : const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.black20,
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: avatarRadius,
              backgroundColor: Colors.white,
              backgroundImage: seller.profilePictureUrl != null && !isPrivate
                  ? NetworkImage(seller.profilePictureUrl!)
                  : null,
              child: seller.profilePictureUrl == null || isPrivate
                  ? Icon(
                      Icons.storefront_rounded,
                      size: avatarRadius,
                      color: Colors.grey.shade400,
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          PrivacyText(
            seller.fullName,
            isPrivate: isPrivate,
            style: TextStyle(
              fontSize: isTablet ? 26 : 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          PrivacyText(
            seller.userUiModel?.email ?? '',
            isPrivate: isPrivate,
            style: TextStyle(
              fontSize: isTablet ? 14 : 13,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Verified Seller',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatBadge(
                  label: 'Products',
                  value: productState.products.length.toString(),
                  // value: seller?.totalProducts?.toString() ?? '0',
                  isPrivate: isPrivate,
                ),
                Container(width: 1, height: 36, color: Colors.white30),
                _StatBadge(
                  label: 'Sold',
                  value: productState.products
                      .map((product) => product.isSoldOut ? 1 : 0)
                      .reduce((a, b) => a + b)
                      .toString(),
                  // value: seller?.totalSold?.toString() ?? '0',
                  isPrivate: isPrivate,
                ),
                // Container(width: 1, height: 36, color: Colors.white30),
                // _StatBadge(
                //     label: 'Rating',
                //     value: '4.8',
                //     isPrivate: isPrivate),
              ],
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }

  Widget _buildMenuBody({
    required SellerUiModel seller,
    required bool isPrivate,
    required bool isTablet,
  }) {
    return Column(
      children: [
        if (isPrivate)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.visibility_off_outlined,
                  color: Colors.orange.shade700,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Privacy mode active',
                  style: TextStyle(fontSize: 12, color: Colors.orange.shade800),
                ),
              ],
            ),
          ),
        _MenuItem(
          icon: Icons.person_outline_rounded,
          title: 'Edit Profile',
          isTablet: isTablet,
          onTap: () {
            if (seller.sellerId != null) {
              AppRoutes.push(
                context,
                SellerEditProfilePage(sellerId: seller.sellerId!),
              );
            }
          },
        ),
        const SizedBox(height: 12),
        _MenuItem(
          icon: Icons.inventory_2_outlined,
          title: 'My Products',
          isTablet: isTablet,
          onTap: () => _loadData(),
        ),
        const SizedBox(height: 12),
        _MenuItem(
          icon: Icons.bar_chart_rounded,
          title: 'Sales Analytics',
          isTablet: isTablet,
          onTap: () {},
        ),
        const SizedBox(height: 12),
        // _MenuItem(
        //   icon: Icons.notifications_outlined,
        //   title: 'Notifications',
        //   isTablet: isTablet,
        //   onTap: () {},
        // ),
        // const SizedBox(height: 24),
        _MenuItem(
          icon: Icons.logout_rounded,
          title: 'Logout',
          isTablet: isTablet,
          iconColor: AppColors.error,
          titleColor: AppColors.error,
          onTap: _showLogoutDialog,
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({
    required this.label,
    required this.value,
    required this.isPrivate,
  });

  final String label;
  final String value;
  final bool isPrivate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          isPrivate ? '●●' : value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.isTablet,
    this.iconColor,
    this.titleColor,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isTablet;
  final Color? iconColor;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? AppColors.primaryButtonColor;
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
            padding: EdgeInsets.all(isTablet ? 18 : 16),
            child: Row(
              children: [
                Container(
                  width: isTablet ? 52 : 46,
                  height: isTablet ? 52 : 46,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: isTablet ? 26 : 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: isTablet ? 17 : 15,
                      fontWeight: FontWeight.w600,
                      color: titleColor ?? AppColors.textPrimaryColor,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 15,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:leelame/app/routes/app_routes.dart';
// import 'package:leelame/app/theme/app_colors.dart';
// import 'package:leelame/core/utils/snackbar_util.dart';
// import 'package:leelame/core/widgets/custom_primary_button.dart';
// import 'package:leelame/features/auth/presentation/pages/seller/seller_login_sign_up_page.dart';
// import 'package:leelame/features/auth/presentation/states/seller_auth_state.dart';
// import 'package:leelame/features/auth/presentation/view_models/seller_auth_view_model.dart';

// class SellerProfileScreen extends ConsumerStatefulWidget {
//   const SellerProfileScreen({super.key});

//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() =>
//       _SellerProfileScreenState();
// }

// class _SellerProfileScreenState extends ConsumerState<SellerProfileScreen> {
//   Future<void> _handleLogout() async {
//     await ref.read(sellerAuthViewModelProvider.notifier).logout();
//   }

//   void _showLogoutDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
//         content: Text('Are you sure you want to logout?'),
//         actions: [
//           TextButton(
//             onPressed: () => AppRoutes.pop(context),
//             child: Text(
//               'Cancel',
//               style: TextStyle(color: AppColors.textPrimaryColor),
//             ),
//           ),
//           TextButton(
//             onPressed: _handleLogout,
//             child: Text(
//               'Logout',
//               style: TextStyle(
//                 color: AppColors.error,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final sellerAuthState = ref.watch(sellerAuthViewModelProvider);

//     ref.listen<SellerAuthState>(sellerAuthViewModelProvider, (previous, next) {
//       if (next.sellerAuthStatus == SellerAuthStatus.error &&
//           next.errorMessage != null) {
//         SnackbarUtil.showError(context, next.errorMessage ?? "Logout Failed!");
//       } else if (next.sellerAuthStatus == SellerAuthStatus.unauthenticated) {
//         SnackbarUtil.showSuccess(context, "Logged out successfully.");

//         // Navigate to seller login and sign up page
//         AppRoutes.pop(context);
//         AppRoutes.pushAndRemoveUntil(context, const SellerLoginSignUpPage());
//       }
//     });

//     return Scaffold(
//       body: Center(
//         child: CustomPrimaryButton(
//           onPressed: () {
//             _showLogoutDialog(context);
//           },
//           text: "Logout",
//           isLoading:
//               sellerAuthState.sellerAuthStatus == SellerAuthStatus.loading,
//         ),
//       ),
//     );
//   }
// }
