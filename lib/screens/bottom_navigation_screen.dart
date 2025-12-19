// lib/screens/bottom_navigation_screen.dart
import 'package:flutter/material.dart';
import 'package:leelame/bottom_screens/home_screen.dart';
import 'package:leelame/bottom_screens/my_bids_screen.dart';
import 'package:leelame/bottom_screens/profile_screen.dart';
import 'package:leelame/bottom_screens/watchlist_screen.dart';
import 'package:leelame/custom_icons/bid_hammer_filled_icon.dart';
import 'package:leelame/custom_icons/bid_hammer_outlined_icon.dart';
import 'package:leelame/custom_icons/home_filled_icon.dart';
import 'package:leelame/custom_icons/home_outlined_icon.dart';
import 'package:leelame/custom_icons/person_filled_icon.dart';
import 'package:leelame/custom_icons/person_outlined_icon.dart';
import 'package:leelame/custom_icons/watchlist_filled_icon.dart';
import 'package:leelame/custom_icons/watchlist_outlined_icon.dart';

class BottomNavigationScreen extends StatefulWidget {
  const BottomNavigationScreen({super.key});

  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
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
        decoration: BoxDecoration(
          color: Colors.white,
        ),
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
