// lib/bottom_screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:leelame/custom_icons/notification_outlined_icon.dart';
import 'package:leelame/custom_icons/search_icon.dart';
import 'package:leelame/widgets/category_toggle_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<bool> selectedCategories = [
    true,
    false,
    false,
    false,
    false,
    false,
    false,
  ];

  final List<Map<String, dynamic>> categories = [
    {'label': 'All', 'icon': Icons.all_inclusive, 'color': Colors.grey},
    {'label': 'Electronics', 'icon': Icons.phone_android, 'color': Colors.blue},
    {'label': 'Fashion', 'icon': Icons.shopping_bag, 'color': Colors.pink},
    {'label': 'House', 'icon': Icons.home, 'color': Colors.green},
    {'label': 'Sports', 'icon': Icons.sports_soccer, 'color': Colors.orange},
    {'label': 'Art', 'icon': Icons.palette, 'color': Colors.purple},
    {'label': 'Books', 'icon': Icons.book, 'color': Colors.yellow},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).colorScheme.onPrimary,
      //   elevation: 2,
      //   shadowColor: Colors.grey.shade300,
      //   leading: Padding(
      //     padding: EdgeInsets.only(left: 10),
      //     child: Image.asset(
      //       "assets/images/leelame_logo_cropped_png.png",
      //       width: MediaQuery.of(context).size.width * 0.25,
      //       height: MediaQuery.of(context).size.width * 0.25,
      //       fit: BoxFit.contain,
      //     ),
      //   ),
      //   leadingWidth: 75,
      //   actions: [
      //     IconButton(icon: Icon(SearchIcon.icon), onPressed: () {}),
      //     IconButton(
      //       icon: Icon(NotificationOutlinedIcon.icon),
      //       onPressed: () {},
      //     ),
      //   ],
      //   actionsPadding: EdgeInsets.only(right: 10),
      // ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 115,
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
              flexibleSpace: FlexibleSpaceBar(
                background: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.only(top: kToolbarHeight),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Row(
                        children: List.generate(categories.length, (index) {
                          final category = categories[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FilterChip(
                              label: CategoryToggleItem(
                                label: category['label'],
                              ),
                              selected: selectedCategories[index],
                              onSelected: (bool selected) {
                                setState(() {
                                  for (
                                    int i = 0;
                                    i < selectedCategories.length;
                                    i++
                                  ) {
                                    selectedCategories[i] = i == index;
                                  }
                                });
                              },
                              backgroundColor: Colors.transparent,
                              selectedColor: Colors.blue.withOpacity(
                                0.2,
                              ), // Subtle highlight for selected
                              showCheckmark:
                                  false, // No checkmark to match image style
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                side: BorderSide.none,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ),
              pinned: false,
              floating: true,
              snap: true,
            ),

            
          ],
        ),
      ),

      // body: SizedBox.expand(
      //   child: Center(
      //     child: Text(
      //       "Welcome to Dashbord",
      //       style: TextStyle(
      //         fontSize: 20,
      //         fontWeight: FontWeight.bold,
      //         color: Colors.black87,
      //         height: 1.2,
      //       ),
      //       textAlign: TextAlign.center,
      //     ),
      //   ),
      // ),
    );
  }
}
