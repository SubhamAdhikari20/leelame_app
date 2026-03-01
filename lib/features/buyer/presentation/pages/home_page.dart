// lib/features/buyer/presentation/pages/home_page.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/app/theme/app_colors.dart';
import 'package:leelame/core/custom_icons/notification_outlined_icon.dart';
import 'package:leelame/core/custom_icons/search_icon.dart';
import 'package:leelame/core/services/storage/user_session_service.dart';
import 'package:leelame/core/widgets/category_toggle_item.dart';
import 'package:leelame/core/widgets/custom_tab_item.dart';
import 'package:leelame/features/bid/presentation/models/bid_ui_model.dart';
import 'package:leelame/features/bid/presentation/view_models/bid_view_model.dart';
import 'package:leelame/features/buyer/presentation/view_models/buyer_view_model.dart';
import 'package:leelame/features/category/presentation/models/category_ui_model.dart';
import 'package:leelame/features/category/presentation/states/category_state.dart';
import 'package:leelame/features/category/presentation/view_models/category_view_model.dart';
import 'package:leelame/features/product/presentation/models/product_ui_model.dart';
import 'package:leelame/features/product/presentation/pages/product_view_details_page.dart';
import 'package:leelame/features/product/presentation/states/product_state.dart';
import 'package:leelame/features/product/presentation/viewmodels/product_view_model.dart';
import 'package:leelame/features/product/presentation/widgets/product_card.dart';
import 'package:leelame/features/product_condition/presentation/models/product_condition_ui_model.dart';
import 'package:leelame/features/product_condition/presentation/states/product_condition_state.dart';
import 'package:leelame/features/product_condition/presentation/view_models/product_condition_view_model.dart';
import 'package:leelame/features/seller/presentation/models/seller_ui_model.dart';
import 'package:leelame/features/seller/presentation/states/seller_state.dart';
import 'package:leelame/features/seller/presentation/view_models/seller_view_model.dart';
import 'package:sensors_plus/sensors_plus.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedCategoryId;
  String _searchQuery = "";

  late TabController _tabController;

  StreamSubscription<AccelerometerEvent>? _accelSubscription;
  DateTime? _lastShakeTimestamp;
  int _shakeCount = 0;

  static const double _shakeThreshold = 15;
  static const Duration _shakeInterval = Duration(milliseconds: 500);
  static const int _requiredShakes = 2;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoryViewModelProvider.notifier).getAllCategories();
      ref
          .read(productConditionViewModelProvider.notifier)
          .getAllProductConditions();
      ref.read(sellerViewModelProvider.notifier).getAllSellers();
      ref.read(productViewModelProvider.notifier).getAllProducts();
      ref.read(bidViewModelProvider.notifier).getAllBids();
      // ref.read(buyerViewModelProvider.notifier).getAllBuyers();
      _loadCurrentUser();
      _startShakeDetection();
    });
  }

  void _startShakeDetection() {
    if (_accelSubscription != null) {
      return;
    }

    _accelSubscription = accelerometerEventStream().listen((
      AccelerometerEvent event,
    ) {
      final magnitude = sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      );

      if (magnitude > _shakeThreshold) {
        DateTime now = DateTime.now();

        if (_lastShakeTimestamp != null &&
            now.difference(_lastShakeTimestamp!) < _shakeInterval) {
          _shakeCount += 1;
        } else {
          _shakeCount = 1;
        }

        _lastShakeTimestamp = now;

        if (_shakeCount >= _requiredShakes) {
          _shakeCount = 0; // reset
          _onDeviceShaken();
        }
      }
    });
  }

  Future<void> _onDeviceShaken() async {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    final snack = SnackBar(
      content: const Text('Refreshing home screen...'),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
    );
    ScaffoldMessenger.of(context).showSnackBar(snack);

    try {
      ref.read(categoryViewModelProvider.notifier).getAllCategories();
      ref
          .read(productConditionViewModelProvider.notifier)
          .getAllProductConditions();
      ref.read(sellerViewModelProvider.notifier).getAllSellers();
      ref.read(productViewModelProvider.notifier).getAllProducts();
      ref.read(bidViewModelProvider.notifier).getAllBids();
      //  ref.read(buyerViewModelProvider.notifier).getAllBuyers();
      _loadCurrentUser();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Home screen refreshed'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to refresh home screen: ${e.toString()}'),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _loadCurrentUser() async {
    final userSessionService = ref.read(userSessionServiceProvider);
    final buyerId = userSessionService.getUserId();
    if (buyerId != null) {
      await ref
          .read(buyerViewModelProvider.notifier)
          .getCurrentUser(buyerId: buyerId);
    }
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

  List<BidUiModel> _getAllBidsByProductId(
    String? productId,
    List<BidUiModel> allBids,
  ) {
    final allBidsByProductId = allBids
        .where((bid) => bid.productId == productId)
        .toList();
    return allBidsByProductId;
  }

  // List<BuyerUiModel> _getAllBiddersByProductId(
  //   String? productId,
  //   List<BuyerUiModel> allBuyers,
  //   List<BidUiModel> allBids,
  // ) {
  //   final allBidsByProductId = _getAllBidsByProductId(productId, allBids);
  //   final allBiddersByProductId = allBuyers
  //       .where(
  //         (buyer) =>
  //             allBidsByProductId.any((bid) => bid.buyerId == buyer.buyerId),
  //       )
  //       .toList();
  //   return allBiddersByProductId;
  // }

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

  Future<void> _openProductDetailsAndRefresh({
    required BuildContext context,
    required String productId,
    required String categoryId,
    required String productConditionId,
    required String sellerId,
    required String currentUserId,
  }) async {
    await Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => ProductViewDetailsPage(
              productId: productId,
              categoryId: categoryId,
              productConditionId: productConditionId,
              sellerId: sellerId,
              currentUserId: currentUserId,
            ),
          ),
        )
        .then((_) {
          ref.read(categoryViewModelProvider.notifier).getAllCategories();
          ref
              .read(productConditionViewModelProvider.notifier)
              .getAllProductConditions();
          ref.read(productViewModelProvider.notifier).getAllProducts();
          ref.read(sellerViewModelProvider.notifier).getAllSellers();
          ref.read(bidViewModelProvider.notifier).getAllBids();
          ref.read(buyerViewModelProvider.notifier).getAllBuyers();
          _loadCurrentUser();
        });

    // AppRoutes.push(
    //   context,
    //   ProductViewDetailsPage(
    //     productId: productId,
    //     categoryId: categoryId,
    //     productConditionId: productConditionId,
    //     sellerId: sellerId,
    //     currentUserId: currentUserId,
    //   ),
    // );

    // try {
    //   ref.read(productViewModelProvider.notifier).getAllProducts();
    //   ref.read(bidViewModelProvider.notifier).getAllBids();
    //   ref.read(sellerViewModelProvider.notifier).getAllSellers();
    //   final buyerId = ref.read(userSessionServiceProvider).getUserId();
    //   if (buyerId != null) {
    //     ref
    //         .read(buyerViewModelProvider.notifier)
    //         .getCurrentUser(buyerId: buyerId);
    //   }
    // } catch (error) {
    //   if (!context.mounted) {
    //     return;
    //   }
    //   SnackbarUtil.showError(context, 'Refresh failed: ${error.toString()}');
    // }
  }

  @override
  Widget build(BuildContext context) {
    final categoryState = ref.watch(categoryViewModelProvider);
    final productConditionState = ref.watch(productConditionViewModelProvider);
    final productState = ref.watch(productViewModelProvider);
    final sellerState = ref.watch(sellerViewModelProvider);
    final buyerState = ref.watch(buyerViewModelProvider);
    final bidState = ref.watch(bidViewModelProvider);
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
              flexibleSpace:
                  categoryState.categoryStatus == CategoryStatus.loading
                  ? null
                  : FlexibleSpaceBar(
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

            if (isLoading)
              const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(80),
                    child: CircularProgressIndicator(),
                  ),
                ),
              )
            else ...[
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
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Product List
              allProducts.isEmpty
                  ? SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.inbox_rounded,
                                size: 64,
                                color: AppColors.textTertiaryColor.withAlpha(
                                  128,
                                ),
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
                      padding: EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 20,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          // final product = productState.products[index];
                          final product = allProducts[index];

                          return Padding(
                            padding: EdgeInsets.only(bottom: 20),
                            child:
                                productState.productStatus ==
                                    ProductStatus.loading
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
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
                                    bid: _getAllBidsByProductId(
                                      product.productId,
                                      BidUiModel.fromEntityList(bidState.bids),
                                    ),
                                    isFavorite: false,
                                    onFavoriteToggle: (val) {
                                      setState(() {
                                        true;
                                      });
                                    },
                                    onTap: () {
                                      _openProductDetailsAndRefresh(
                                        context: context,
                                        productId: product.productId!,
                                        categoryId: product.categoryId!,
                                        productConditionId:
                                            product.conditionId!,
                                        sellerId: product.sellerId!,
                                        currentUserId:
                                            buyerState.buyer!.buyerId!,
                                      );
                                      // AppRoutes.push(
                                      //   context,
                                      //   ProductViewDetailsPage(
                                      //     productId: product.productId!,
                                      //     categoryId: product.categoryId!,
                                      //     productConditionId:
                                      //         product.conditionId!,
                                      //     sellerId: product.sellerId!,
                                      //     currentUserId:
                                      //         buyerState.buyer!.buyerId!,
                                      //   ),
                                      // );
                                    },
                                    onPlaceBid: () {
                                      _openProductDetailsAndRefresh(
                                        context: context,
                                        productId: product.productId!,
                                        categoryId: product.categoryId!,
                                        productConditionId:
                                            product.conditionId!,
                                        sellerId: product.sellerId!,
                                        currentUserId:
                                            buyerState.buyer!.buyerId!,
                                      );
                                      // AppRoutes.push(
                                      //   context,
                                      //   ProductViewDetailsPage(
                                      //     productId: product.productId!,
                                      //     categoryId: product.categoryId!,
                                      //     productConditionId:
                                      //         product.conditionId!,
                                      //     sellerId: product.sellerId!,
                                      //     currentUserId:
                                      //         buyerState.buyer!.buyerId!,
                                      //   ),
                                      // );
                                    },
                                  ),
                          );
                        }, childCount: allProducts.length),
                      ),
                    ),
            ],

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
