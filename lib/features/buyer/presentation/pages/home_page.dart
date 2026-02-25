// lib/features/buyer/presentation/pages/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/app/theme/app_colors.dart';
import 'package:leelame/core/custom_icons/notification_outlined_icon.dart';
import 'package:leelame/core/custom_icons/search_icon.dart';
import 'package:leelame/core/widgets/category_toggle_item.dart';
import 'package:leelame/core/widgets/custom_tab_item.dart';
import 'package:leelame/features/category/presentation/models/category_ui_model.dart';
import 'package:leelame/features/category/presentation/states/category_state.dart';
import 'package:leelame/features/category/presentation/view_models/category_view_model.dart';
import 'package:leelame/features/product/presentation/models/product_ui_model.dart';
import 'package:leelame/features/product/presentation/states/product_state.dart';
import 'package:leelame/features/product/presentation/viewmodels/product_view_model.dart';
import 'package:leelame/features/product/presentation/widgets/product_card.dart';
import 'package:leelame/features/product_condition/presentation/models/product_condition_ui_model.dart';
import 'package:leelame/features/product_condition/presentation/states/product_condition_state.dart';
import 'package:leelame/features/product_condition/presentation/view_models/product_condition_view_model.dart';
import 'package:leelame/features/seller/presentation/models/seller_ui_model.dart';
import 'package:leelame/features/seller/presentation/states/seller_state.dart';
import 'package:leelame/features/seller/presentation/view_models/seller_view_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedCategoryId;
  String _searchQuery = "";
  // List<bool> selectedCategories = [
  //   true,
  //   false,
  //   false,
  //   false,
  //   false,
  //   false,
  //   false,
  // ];

  // final List<Map<String, dynamic>> categories = [
  //   {'label': 'All', 'icon': Icons.all_inclusive, 'color': Colors.grey},
  //   {'label': 'Electronics', 'icon': Icons.phone_android, 'color': Colors.blue},
  //   {'label': 'Fashion', 'icon': Icons.shopping_bag, 'color': Colors.pink},
  //   {'label': 'House', 'icon': Icons.home, 'color': Colors.green},
  //   {'label': 'Sports', 'icon': Icons.sports_soccer, 'color': Colors.orange},
  //   {'label': 'Art', 'icon': Icons.palette, 'color': Colors.purple},
  //   {'label': 'Books', 'icon': Icons.book, 'color': Colors.yellow},
  // ];

  // final List<Map<String, dynamic>> products = [
  //   {
  //     'tags': ['Electronics', 'Refurbished'],
  //     // 'image': 'assets/images/iphone_mock.png',
  //     'image': 'https://i.ytimg.com/vi/q2Ktw2yVeAQ/sddefault.jpg',
  //     'title': 'iPhone 15 Pro Max 256GB',
  //     'location': 'Kathmandu, Nepal',
  //     'price': 'Rs. 220,000',
  //     'isFavorite': false,
  //     'ownerName': 'Rajesh Kumar',
  //     'ownerAvatar':
  //         'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&q=80&auto=format&fit=crop',
  //     'timeLeft': '2h 30m',
  //     'bids': 24,
  //   },
  //   {
  //     'tags': ['Fashion'],
  //     // 'image': 'assets/images/shoes_mock.png',
  //     'image':
  //         'https://static.nike.com/a/images/f_auto,cs_srgb/w_1920,c_limit/187bd092-6b79-4576-872c-36c6fca5e536/the-best-nike-shoes-for-running-an-ultramarathon.jpg',
  //     'title': 'Nike Running Shoes',
  //     'location': 'Pokhara, Nepal',
  //     'price': 'Rs. 9,500',
  //     'isFavorite': true,
  //     'ownerName': 'Rajesh Kumar',
  //     'ownerAvatar':
  //         'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&q=80&auto=format&fit=crop',
  //     'timeLeft': '2h 30m',
  //     'bids': 24,
  //   },
  //   {
  //     'tags': ['House'],
  //     // 'image': 'assets/images/sofa_mock.png',
  //     'image':
  //         'https://pelicanessentials.com/cdn/shop/files/three_seater_grey_0002-Photoroom.jpg',
  //     'title': '3-Seater Fabric Sofa',
  //     'location': 'Lalitpur, Nepal',
  //     'price': 'Rs. 45,000',
  //     'isFavorite': false,
  //     'ownerName': 'Rajesh Kumar',
  //     'ownerAvatar':
  //         'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&q=80&auto=format&fit=crop',
  //     'timeLeft': '2h 30m',
  //     'bids': 24,
  //   },
  // ];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoryViewModelProvider.notifier).getAllCategories();
      ref
          .read(productConditionViewModelProvider.notifier)
          .getAllProductConditions();
      ref.read(productViewModelProvider.notifier).getAllProducts();
      ref.read(sellerViewModelProvider.notifier).getAllSellers();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<ProductUiModel> _getAllProducts(ProductState productState) {
    List<ProductUiModel> products = ProductUiModel.fromEntityList(
      productState.products,
    );

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      products = products.where((product) {
        final productNameMatch = product.productName.toLowerCase().contains(
          query,
        );
        final descriptionMatch =
            product.description?.toLowerCase().contains(query) ?? false;
        // final locationMatch = product.location.toLowerCase().contains(query);
        return productNameMatch || descriptionMatch;
      }).toList();
    }

    // Filter by category
    if (_selectedCategoryId != null) {
      products = products
          .where((product) => product.categoryId == _selectedCategoryId)
          .toList();
    }

    return products;
  }

  CategoryUiModel _getCategoryById(
    String? categoryId,
    List<CategoryUiModel> categories,
  ) {
    final category = categories.firstWhere(
      (c) => c.categoryId == categoryId,
      orElse: () => categories.first,
    );

    return category;
  }

  ProductConditionUiModel _getProductConditionById(
    String? productConditionId,
    List<ProductConditionUiModel> productConditions,
  ) {
    final productCondition = productConditions.firstWhere(
      (c) => c.productConditionId == productConditionId,
      orElse: () => productConditions.first,
    );
    return productCondition;
  }

  SellerUiModel _getSellerById(String? sellerId, List<SellerUiModel> sellers) {
    final seller = sellers.firstWhere(
      (s) => s.sellerId == sellerId,
      orElse: () => sellers.first,
    );
    return seller;
  }

  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('electronic')) {
      return Icons.phone_android;
    }
    if (name.contains('jewelry')) {
      return Icons.diamond;
    }
    if (name.contains('fashion') || name.contains('clothing')) {
      return Icons.shopping_bag;
    }
    if (name.contains("bag") || name.contains("accessory")) {
      return Icons.shopping_bag;
    }
    if (name.contains('house') ||
        name.contains('home') ||
        name.contains('furniture')) {
      return Icons.home;
    }
    if (name.contains('sport')) {
      return Icons.sports_soccer;
    }
    if (name.contains('art') || name.contains('paint')) {
      return Icons.palette;
    }
    if (name.contains('book')) {
      return Icons.book;
    }
    if (name.contains('vehicle') ||
        name.contains('car') ||
        name.contains('bike')) {
      return Icons.directions_car;
    }
    return Icons.category; // default
  }

  Color _getCategoryColor(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('electronic')) {
      return Colors.blue;
    }
    if (name.contains('fashion')) {
      return Colors.pink;
    }
    if (name.contains('house') || name.contains('home')) {
      return Colors.green;
    }
    if (name.contains('sport')) {
      return Colors.orange;
    }
    if (name.contains('art')) {
      return Colors.purple;
    }
    if (name.contains('book')) {
      return Colors.brown;
    }
    if (name.contains('bag')) {
      return Colors.yellow;
    }
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final categoryState = ref.watch(categoryViewModelProvider);
    final productConditionState = ref.watch(productConditionViewModelProvider);
    final productState = ref.watch(productViewModelProvider);
    final sellerState = ref.watch(sellerViewModelProvider);
    final allProducts = _getAllProducts(productState);

    final isLoading =
        productState.productStatus == ProductStatus.loading ||
        categoryState.categoryStatus == CategoryStatus.loading ||
        productConditionState.productConditionStatus ==
            ProductConditionStatus.loading ||
        sellerState.sellerStatus == SellerStatus.loading;

    // UI Categories with icons and colors
    final List<Map<String, dynamic>> uiCategories = [
      {
        'id': null,
        'name': 'All',
        'icon': Icons.all_inclusive,
        'color': Colors.grey,
      },
      ...categoryState.categories.map((category) {
        return {
          'id': category.categoryId,
          'name': category.categoryName,
          'icon': _getCategoryIcon(category.categoryName),
          'color': _getCategoryColor(category.categoryName),
        };
      }),
    ];

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
                      child:
                          categoryState.categoryStatus == CategoryStatus.loading
                          ? const Center(child: CircularProgressIndicator())
                          : Row(
                              children: List.generate(uiCategories.length, (
                                index,
                              ) {
                                final category = uiCategories[index];
                                final isSelected =
                                    _selectedCategoryId == category["id"];
                                return Padding(
                                  padding: EdgeInsets.only(right: 8),
                                  child: FilterChip(
                                    avatar: Icon(
                                      category['icon'] as IconData,
                                      size: 18,
                                    ),
                                    label: CategoryToggleItem(
                                      label: category["name"],
                                    ),
                                    selected: isSelected,
                                    onSelected: (bool selected) {
                                      setState(() {
                                        _selectedCategoryId = selected
                                            ? category["id"]
                                            : null;
                                      });
                                    },
                                    backgroundColor: Colors.transparent,
                                    selectedColor: Colors.blue.withValues(
                                      alpha: 0.2,
                                    ),
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

            // Product List
            isLoading
                ? const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(80),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  )
                : allProducts.isEmpty
                ? SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.inbox_rounded,
                              size: 64,
                              color: AppColors.textTertiaryColor.withAlpha(128),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No items found",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        // final product = productState.products[index];
                        final product = allProducts[index];

                        return Padding(
                          padding: EdgeInsets.only(bottom: 20),
                          child:
                              productState.productStatus ==
                                  ProductStatus.loading
                              ? const Center(child: CircularProgressIndicator())
                              : ProductCard(
                                  category: _getCategoryById(
                                    product.categoryId,
                                    CategoryUiModel.fromEntityList(
                                      categoryState.categories,
                                    ),
                                  ),
                                  productCondition: _getProductConditionById(
                                    product.conditionId,
                                    ProductConditionUiModel.fromEntityList(
                                      productConditionState.productConditions,
                                    ),
                                  ),
                                  // product: ProductUiModel.fromEntity(product),
                                  product: product,
                                  seller: _getSellerById(
                                    product.sellerId,
                                    SellerUiModel.fromEntityList(
                                      sellerState.sellers,
                                    ),
                                  ),
                                  isFavorite: false,
                                  onFavoriteToggle: (val) {},
                                  // onFavoriteToggle: (val) {
                                  //   setState(() {
                                  //     products[index]['isFavorite'] = val;
                                  //   });
                                  // },
                                  onTap: () {},
                                  onPlaceBid: () {},
                                ),
                        );
                      }, childCount: allProducts.length),
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
