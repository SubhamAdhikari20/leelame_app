// lib/features/buyer/presentation/pages/profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/app/routes/app_routes.dart';
import 'package:leelame/app/theme/app_colors.dart';
import 'package:leelame/core/services/storage/user_session_service.dart';
import 'package:leelame/core/utils/snackbar_util.dart';
import 'package:leelame/features/auth/presentation/pages/buyer/buyer_login_page.dart';
import 'package:leelame/features/auth/presentation/states/buyer_auth_state.dart';
import 'package:leelame/features/auth/presentation/view_models/buyer_auth_view_model.dart';
import 'package:leelame/features/buyer/presentation/models/buyer_ui_model.dart';
import 'package:leelame/features/buyer/presentation/pages/edit_profile_page.dart';
import 'package:leelame/features/buyer/presentation/states/buyer_state.dart';
import 'package:leelame/features/buyer/presentation/view_models/buyer_view_model.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadCurrentUser());
  }

  void _loadCurrentUser() async {
    final userSessionService = ref.read(userSessionServiceProvider);
    final buyerId = userSessionService.getUserId();
    if (buyerId != null) {
      await ref
          .read(buyerViewModelProvider.notifier)
          .getCurrentUser(buyerId: buyerId);
    }
  }

  Future<void> _handleLogout() async {
    await ref.read(buyerAuthViewModelProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context) {
    final buyerAuthState = ref.watch(buyerAuthViewModelProvider);
    final buyerState = ref.watch(buyerViewModelProvider);
    final userData = buyerState.buyer;

    ref.listen<BuyerState>(buyerViewModelProvider, (previous, next) {
      if ((next.buyerStatus == BuyerStatus.error)) {
        SnackbarUtil.showError(
          context,
          next.errorMessage ?? "Error loading current user!",
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
                            child: const CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.person_rounded,
                                size: 60,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          Text(
                            userData?.fullName ?? "Guest",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),

                          Text(
                            userData?.username ?? "guest07",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 4),

                          Text(
                            userData?.userEntity?.email ?? "guest@gmail.com.np",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Stats Row
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _StatItem(title: 'Active Bids', value: '12'),
                                Container(
                                  width: 1,
                                  height: 40,
                                  color: AppColors.white30,
                                ),
                                _StatItem(title: 'Won Bids', value: '8'),
                                Container(
                                  width: 1,
                                  height: 40,
                                  color: AppColors.white30,
                                ),
                                _StatItem(title: 'Watchlist', value: '5'),
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
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          _MenuItem(
                            icon: Icons.person_outline_rounded,
                            title: 'Edit Profile',
                            onTap: () {
                              AppRoutes.push(
                                context,
                                EditProfilePage(
                                  buyerUiModel: userData != null
                                      ? BuyerUiModel.fromEntity(userData)
                                      : null,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          _MenuItem(
                            icon: Icons.history_rounded,
                            title: 'My Items',
                            onTap: () {},
                          ),
                          const SizedBox(height: 12),
                          _MenuItem(
                            icon: Icons.notifications_outlined,
                            title: 'Notifications',
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: AppColors.secondaryGradient,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '3',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            onTap: () {},
                          ),
                          const SizedBox(height: 12),
                          _MenuItem(
                            icon: Icons.security_rounded,
                            title: 'Privacy & Security',
                            onTap: () {},
                          ),
                          const SizedBox(height: 12),
                          _MenuItem(
                            icon: Icons.help_outline_rounded,
                            title: 'Help & Support',
                            onTap: () {},
                          ),
                          const SizedBox(height: 12),
                          _MenuItem(
                            icon: Icons.info_outline_rounded,
                            title: 'About',
                            onTap: () {},
                          ),
                          const SizedBox(height: 24),
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
            onPressed: () {
              AppRoutes.pop(context);
              _handleLogout();
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

  const _StatItem({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(title, style: TextStyle(fontSize: 12, color: AppColors.white80)),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? titleColor;

  const _MenuItem({
    required this.icon,
    required this.title,
    this.trailing,
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
                trailing ??
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
