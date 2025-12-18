// lib/screens/bottom_navigation_screen.dart
import 'package:flutter/material.dart';
import 'package:leelame/bottom_screens/home_screen.dart';
import 'package:leelame/bottom_screens/profile_screen.dart';
import 'package:leelame/icons/home_filled_icon.dart';
import 'package:leelame/icons/home_outlined_icon.dart';

class BottomNavigationScreen extends StatefulWidget {
  const BottomNavigationScreen({super.key});

  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  int _selectedIndex = 0;

  List<Widget> lstBottomScreen = [
    HomeScreen(),
    // ProductScreen(),
    // CartScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: lstBottomScreen[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        iconSize: 25,
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF2ADA03),
        unselectedItemColor: Colors.black,
        selectedFontSize: 15,
        unselectedFontSize: 14,
        elevation: 2,
        items: [
          BottomNavigationBarItem(
            activeIcon: Icon(HomeFilledIcon.icon),
            icon: Icon(HomeOutlinedIcon.icon),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.production_quantity_limits_sharp),
            label: "Product",
          ),
          BottomNavigationBarItem(
            label: "Cart",
            icon: Icon(HomeOutlinedIcon.icon),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
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
    );
  }
}
