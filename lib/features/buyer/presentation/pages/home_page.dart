// lib/features/buyer/presentation/pages/home_screen.dart
import 'package:flutter/material.dart';
import 'package:leelame/core/custom_icons/notification_outlined_icon.dart';
import 'package:leelame/core/custom_icons/search_icon.dart';
import 'package:leelame/core/widgets/category_toggle_item.dart';
import 'package:leelame/core/widgets/custom_tab_item.dart';

import 'package:leelame/features/products/presentation/widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
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

  final List<Map<String, dynamic>> products = [
    {
      'tags': ['Electronics', 'Refurbished'],
      // 'image': 'assets/images/iphone_mock.png',
      'image': 'https://i.ytimg.com/vi/q2Ktw2yVeAQ/sddefault.jpg',
      'title': 'iPhone 15 Pro Max 256GB',
      'location': 'Kathmandu, Nepal',
      'price': 'Rs. 220,000',
      'isFavorite': false,
      'ownerName': 'Rajesh Kumar',
      'ownerAvatar':
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&q=80&auto=format&fit=crop',
      'timeLeft': '2h 30m',
      'bids': 24,
    },
    {
      'tags': ['Fashion'],
      // 'image': 'assets/images/shoes_mock.png',
      'image':
          'https://static.nike.com/a/images/f_auto,cs_srgb/w_1920,c_limit/187bd092-6b79-4576-872c-36c6fca5e536/the-best-nike-shoes-for-running-an-ultramarathon.jpg',
      'title': 'Nike Running Shoes',
      'location': 'Pokhara, Nepal',
      'price': 'Rs. 9,500',
      'isFavorite': true,
      'ownerName': 'Rajesh Kumar',
      'ownerAvatar':
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&q=80&auto=format&fit=crop',
      'timeLeft': '2h 30m',
      'bids': 24,
    },
    {
      'tags': ['House'],
      // 'image': 'assets/images/sofa_mock.png',
      'image':
          'https://pelicanessentials.com/cdn/shop/files/three_seater_grey_0002-Photoroom.jpg',
      'title': '3-Seater Fabric Sofa',
      'location': 'Lalitpur, Nepal',
      'price': 'Rs. 45,000',
      'isFavorite': false,
      'ownerName': 'Rajesh Kumar',
      'ownerAvatar':
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&q=80&auto=format&fit=crop',
      'timeLeft': '2h 30m',
      'bids': 24,
    },
  ];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
      //   leadingWidth: 65,
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
              leadingWidth: 65,
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
                        horizontal: 15,
                        vertical: 8,
                      ),
                      child: Row(
                        children: List.generate(categories.length, (index) {
                          final category = categories[index];
                          return Padding(
                            padding: EdgeInsets.only(right: 8),
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
                              selectedColor: Colors.blue.withValues(alpha: 0.2),
                              showCheckmark: false,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
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

            SliverPersistentHeader(
              pinned: true,
              delegate: SliverAppBarDelegate(
                minHeight: 50,
                maxHeight: 50,
                child: Material(
                  elevation: 2,
                  child: Container(
                    // margin: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      // borderRadius: BorderRadius.all(Radius.circular(25)),
                      color: Theme.of(context).colorScheme.onPrimary,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 8,
                          spreadRadius: 2,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TabBar(
                      padding: EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 5,
                      ),
                      controller: _tabController,
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF9831E0), Color(0xFFCF2988)],
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.purple,
                      tabs: [
                        CustomTabItem(title: 'Live Auctions', count: 0),
                        CustomTabItem(title: 'Ending Soon', count: 0),
                        CustomTabItem(title: 'New', count: 0),
                        // Tab(
                        //   child: Text(
                        //     "Live Auctions",
                        //     style: TextStyle(fontFamily: "OpenSans Medium"),
                        //   ),
                        // ),
                        // Tab(
                        //   child: Text(
                        //     "Ending Soon",
                        //     style: TextStyle(fontFamily: "OpenSans Medium"),
                        //   ),
                        // ),
                        // Tab(
                        //   child: Text(
                        //     "New",
                        //     style: TextStyle(fontFamily: "OpenSans Medium"),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final product = products[index % products.length];
                  return Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: ProductCard(
                      tags: List<String>.from(product['tags'] as List),
                      imageAsset: product['image'] as String,
                      title: product['title'] as String,
                      location: product['location'] as String,
                      price: product['price'] as String,
                      isFavorite: product['isFavorite'] as bool,
                      timeLeft: product['timeLeft'] as String? ?? '',
                      bidCount: product['bids'] as int? ?? 0,
                      ownerName: product['ownerName'] as String? ?? '',
                      ownerAvatar: product['ownerAvatar'] as String? ?? '',
                      onFavoriteToggle: (val) {
                        setState(() {
                          products[index]['isFavorite'] = val;
                        });
                      },
                      onTap: () {},
                      onPlaceBid: () {},
                    ),
                  );
                }, childCount: products.length),
              ),
            ),

            // SliverToBoxAdapter(
            //   child: SizedBox(
            //     height: MediaQuery.of(context).padding.bottom + 12,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

class SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  const SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(SliverAppBarDelegate oldDelegate) {
    return minHeight != oldDelegate.minHeight ||
        maxHeight != oldDelegate.maxHeight ||
        child != oldDelegate.child;
  }
}
