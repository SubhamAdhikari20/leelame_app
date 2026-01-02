// lib/features/buyer/presentation/pages/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:leelame/features/buyer/presentation/pages/home_page.dart';
import 'package:leelame/features/buyer/presentation/pages/my_bids_page.dart';
import 'package:leelame/features/buyer/presentation/pages/profile_page.dart';
import 'package:leelame/features/buyer/presentation/pages/watchlist_page.dart';
import 'package:leelame/core/custom_icons/bid_hammer_filled_icon.dart';
import 'package:leelame/core/custom_icons/bid_hammer_outlined_icon.dart';
import 'package:leelame/core/custom_icons/home_filled_icon.dart';
import 'package:leelame/core/custom_icons/home_outlined_icon.dart';
import 'package:leelame/core/custom_icons/person_filled_icon.dart';
import 'package:leelame/core/custom_icons/person_outlined_icon.dart';
import 'package:leelame/core/custom_icons/watchlist_filled_icon.dart';
import 'package:leelame/core/custom_icons/watchlist_outlined_icon.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  List<Widget> lstBottomScreen = [
    HomeScreen(),
    MyBidsScreen(),
    WatchlistScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: lstBottomScreen[_selectedIndex],
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
              activeIcon: Icon(BidHammerFilledIcon.icon),
              icon: Icon(BidHammerOutlinedIcon.icon),
              label: "My Bids",
            ),
            BottomNavigationBarItem(
              activeIcon: Icon(WatchlistFilledIcon.icon),
              icon: Icon(WatchlistOutlinedIcon.icon),
              label: "Watchlist",
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
