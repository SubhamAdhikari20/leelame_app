// lib/bottom_screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:leelame/custom_icons/notification_outlined_icon.dart';
import 'package:leelame/custom_icons/search_icon.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 2,
        shadowColor: Colors.grey.shade300,
        leading: Padding(
          padding: EdgeInsets.only(left: 10),
          child: Image.asset(
            "assets/images/leelame_logo_cropped_png.png",
            width: MediaQuery.of(context).size.width * 0.25,
            height: MediaQuery.of(context).size.width * 0.25,
            fit: BoxFit.contain,
          ),
        ),
        leadingWidth: 75,
        actions: [
          IconButton(icon: Icon(SearchIcon.icon), onPressed: () {}),
          IconButton(
            icon: Icon(NotificationOutlinedIcon.icon),
            onPressed: () {},
          ),
        ],
        actionsPadding: EdgeInsets.only(right: 10),
      ),
      body: SizedBox.expand(
        child: Center(
          child: Text(
            "Welcome to Dashbord",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
