// lib/features/seller/presentation/pages/screens/seller_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/app/routes/app_routes.dart';
import 'package:leelame/app/theme/app_colors.dart';
import 'package:leelame/core/utils/snackbar_util.dart';
import 'package:leelame/core/widgets/custom_primary_button.dart';
import 'package:leelame/features/auth/presentation/pages/seller/seller_login_sign_up_page.dart';
import 'package:leelame/features/auth/presentation/states/seller_auth_state.dart';
import 'package:leelame/features/auth/presentation/view_models/seller_auth_view_model.dart';

class SellerProfileScreen extends ConsumerStatefulWidget {
  const SellerProfileScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SellerProfileScreenState();
}

class _SellerProfileScreenState extends ConsumerState<SellerProfileScreen> {
  Future<void> _handleLogout() async {
    await ref.read(sellerAuthViewModelProvider.notifier).logout();
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
            onPressed: () => AppRoutes.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textPrimaryColor),
            ),
          ),
          TextButton(
            onPressed: _handleLogout,
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
    final sellerAuthState = ref.watch(sellerAuthViewModelProvider);

    ref.listen<SellerAuthState>(sellerAuthViewModelProvider, (previous, next) {
      if (next.sellerAuthStatus == SellerAuthStatus.error &&
          next.errorMessage != null) {
        SnackbarUtil.showError(context, next.errorMessage ?? "Logout Failed!");
      } else if (next.sellerAuthStatus == SellerAuthStatus.unauthenticated) {
        SnackbarUtil.showSuccess(context, "Logged out successfully.");

        // Navigate to seller login and sign up page
        AppRoutes.pop(context);
        AppRoutes.pushAndRemoveUntil(context, const SellerLoginSignUpPage());
      }
    });

    return Scaffold(
      body: Center(
        child: CustomPrimaryButton(
          onPressed: () {
            _showLogoutDialog(context);
          },
          text: "Logout",
          isLoading:
              sellerAuthState.sellerAuthStatus == SellerAuthStatus.loading,
        ),
      ),
    );
  }
}
