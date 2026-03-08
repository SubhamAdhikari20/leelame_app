// lib/features/seller/presentation/pages/seller_dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/app/routes/app_routes.dart';
import 'package:leelame/app/theme/app_colors.dart';
import 'package:leelame/core/custom_icons/home_filled_icon.dart';
import 'package:leelame/core/custom_icons/home_outlined_icon.dart';
import 'package:leelame/core/custom_icons/person_filled_icon.dart';
import 'package:leelame/core/custom_icons/person_outlined_icon.dart';
import 'package:leelame/core/services/storage/user_session_service.dart';
import 'package:leelame/core/utils/snackbar_util.dart';
import 'package:leelame/features/product/presentation/pages/add_new_product_page.dart';
import 'package:leelame/features/seller/presentation/pages/screens/seller_analytics_screen.dart';
import 'package:leelame/features/seller/presentation/pages/screens/seller_home_screen.dart';
import 'package:leelame/features/seller/presentation/pages/screens/seller_my_products_screen.dart';
import 'package:leelame/features/seller/presentation/pages/screens/seller_profile_screen.dart';
import 'package:leelame/features/seller/presentation/states/seller_state.dart';
import 'package:leelame/features/seller/presentation/view_models/seller_view_model.dart';

class SellerDashboardPage extends ConsumerStatefulWidget {
  const SellerDashboardPage({super.key});

  @override
  ConsumerState<SellerDashboardPage> createState() =>
      _SellerDashboardPageState();
}

class _SellerDashboardPageState extends ConsumerState<SellerDashboardPage> {
  int _selectedIndex = 0;

  List<Widget> lstBottomScreen = [
    SellerHomeScreen(),
    SellerMyProductsScreen(),
    SellerAnalyticsScreen(),
    SellerProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentUser();
    });
  }

  Future<void> _loadCurrentUser() async {
    final userSessionService = ref.read(userSessionServiceProvider);
    final sellerId = userSessionService.getUserId();
    if (sellerId != null) {
      await ref
          .read(sellerViewModelProvider.notifier)
          .getCurrentUser(sellerId: sellerId);
    }
  }

  void _onCreateNewAuctionPressed({required String sellerId}) {
    AppRoutes.push(context, AddNewProductPage(sellerId: sellerId));
  }

  @override
  Widget build(BuildContext context) {
    final sellerState = ref.watch(sellerViewModelProvider);

    ref.listen<SellerState>(sellerViewModelProvider, (previous, next) {
      if (next.sellerStatus == SellerStatus.error) {
        SnackbarUtil.showError(
          context,
          next.errorMessage ?? "Error loading current user!",
        );
      }
    });

    return Scaffold(
      body: lstBottomScreen[_selectedIndex],
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: AppColors.buttonShadow,
        ),
        child: FloatingActionButton(
          onPressed: () {
            _onCreateNewAuctionPressed(sellerId: sellerState.seller!.sellerId!);
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Icon(Icons.add_rounded, color: Colors.white, size: 32),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(top: 10),
        decoration: BoxDecoration(color: Colors.white),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          iconSize: 25,
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF2ADA03),
          unselectedItemColor: Color(0xFF555555),
          selectedLabelStyle: TextStyle(fontFamily: "OpenSans SemiBold"),
          selectedFontSize: 15,
          unselectedFontSize: 14,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              activeIcon: Icon(HomeFilledIcon.icon),
              icon: Icon(HomeOutlinedIcon.icon),
              label: "Home",
            ),
            BottomNavigationBarItem(
              activeIcon: Icon(Icons.shopping_bag),
              icon: Icon(Icons.shopping_bag_outlined),
              label: "My Products",
            ),
            BottomNavigationBarItem(
              activeIcon: Icon(Icons.analytics),
              icon: Icon(Icons.analytics_outlined),
              label: "Analytics",
            ),
            BottomNavigationBarItem(
              activeIcon: Icon(PersonFilledIcon.icon),
              icon: Icon(PersonOutlinedIcon.icon),
              label: "Profile",
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }
}
