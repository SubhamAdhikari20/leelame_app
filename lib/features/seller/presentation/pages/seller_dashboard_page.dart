// lib/features/seller/presentation/pages/seller_dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/app/routes/app_routes.dart';
import 'package:leelame/app/theme/app_colors.dart';
import 'package:leelame/core/custom_icons/home_filled_icon.dart';
import 'package:leelame/core/custom_icons/home_outlined_icon.dart';
import 'package:leelame/core/custom_icons/person_filled_icon.dart';
import 'package:leelame/core/custom_icons/person_outlined_icon.dart';
import 'package:leelame/features/auction/presentation/pages/create_new_auction_page.dart';
import 'package:leelame/features/seller/presentation/pages/screens/seller_analytics_screen.dart';
import 'package:leelame/features/seller/presentation/pages/screens/seller_home_screen.dart';
import 'package:leelame/features/seller/presentation/pages/screens/seller_orders_screen.dart';
import 'package:leelame/features/seller/presentation/pages/screens/seller_profile_screen.dart';

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
    SellerOrdersScreen(),
    SellerAnalyticsScreen(),
    SellerProfileScreen(),
  ];

  void _onCreateNewAuctionPressed() {
    AppRoutes.push(context, const CreateNewAuctionPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: lstBottomScreen[_selectedIndex],
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: AppColors.buttonShadow,
        ),
        child: FloatingActionButton(
          onPressed: _onCreateNewAuctionPressed,
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
              label: "Oders",
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
