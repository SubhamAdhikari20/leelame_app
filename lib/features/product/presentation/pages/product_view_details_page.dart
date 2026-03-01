// lib/features/product/presentation/pages/product_view_details_page.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gradient_elevated_button/gradient_elevated_button.dart';
import 'package:leelame/app/routes/app_routes.dart';
import 'package:leelame/app/theme/app_colors.dart';
import 'package:leelame/core/custom_icons/notification_outlined_icon.dart';
import 'package:leelame/core/utils/snackbar_util.dart';
import 'package:leelame/features/bid/presentation/models/bid_ui_model.dart';
import 'package:leelame/features/bid/presentation/states/bid_state.dart';
import 'package:leelame/features/bid/presentation/view_models/bid_view_model.dart';
import 'package:leelame/features/buyer/presentation/models/buyer_ui_model.dart';
import 'package:leelame/features/buyer/presentation/states/buyer_state.dart';
import 'package:leelame/features/buyer/presentation/view_models/buyer_view_model.dart';
import 'package:leelame/features/category/presentation/states/category_state.dart';
import 'package:leelame/features/category/presentation/view_models/category_view_model.dart';
import 'package:leelame/features/product/presentation/models/product_ui_model.dart';
import 'package:leelame/features/product/presentation/states/product_state.dart';
import 'package:leelame/features/product/presentation/viewmodels/product_view_model.dart';
import 'package:leelame/features/product/presentation/widgets/favorite_button_widget.dart';
import 'package:leelame/features/product/presentation/widgets/time_ago_widget.dart';
import 'package:leelame/features/product_condition/presentation/states/product_condition_state.dart';
import 'package:leelame/features/product_condition/presentation/view_models/product_condition_view_model.dart';
import 'package:leelame/features/seller/presentation/states/seller_state.dart';
import 'package:leelame/features/seller/presentation/view_models/seller_view_model.dart';
import 'package:sensors_plus/sensors_plus.dart';

class ProductViewDetailsPage extends ConsumerStatefulWidget {
  const ProductViewDetailsPage({
    super.key,
    required this.productId,
    required this.categoryId,
    required this.productConditionId,
    required this.sellerId,
    required this.currentUserId,
  });

  final String productId;
  final String categoryId;
  final String productConditionId;
  final String sellerId;
  final String currentUserId;

  // const ProductViewDetailsPage({
  //   super.key,
  //   required this.product,
  //   required this.category,
  //   required this.productCondition,
  //   required this.seller,
  //   this.bids = const [],
  //   this.currentUser,
  //   this.bidders = const [],
  // });

  // final ProductUiModel product;
  // final CategoryUiModel category;
  // final ProductConditionUiModel productCondition;
  // final SellerUiModel seller;
  // final List<BidUiModel> bids;
  // final BuyerUiModel? currentUser;
  // final List<BuyerUiModel> bidders;

  @override
  ConsumerState<ProductViewDetailsPage> createState() =>
      _ProductViewDetailsPageState();
}

class _ProductViewDetailsPageState
    extends ConsumerState<ProductViewDetailsPage> {
  final TextEditingController _bidController = TextEditingController();
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  // Shake detection state
  StreamSubscription<AccelerometerEvent>? _accelSubscription;
  DateTime? _lastShakeTimestamp;
  int _shakeCount = 0;

  static const double _shakeThreshold = 15;
  static const Duration _shakeInterval = Duration(milliseconds: 500);
  static const int _requiredShakes = 2;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(categoryViewModelProvider.notifier)
          .getCategoryById(widget.categoryId);
      ref
          .read(productConditionViewModelProvider.notifier)
          .getProductConditionById(widget.productConditionId);
      ref
          .read(sellerViewModelProvider.notifier)
          .getSellerIdById(widget.sellerId);
      ref
          .read(productViewModelProvider.notifier)
          .getProductById(widget.productId);
      ref
          .read(bidViewModelProvider.notifier)
          .getAllBidsByProductId(widget.productId);
      ref.read(buyerViewModelProvider.notifier).getAllBuyers();
      ref
          .read(buyerViewModelProvider.notifier)
          .getCurrentUser(buyerId: widget.currentUserId);
      _startShakeDetection();
    });
  }

  //Shake listener logic
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
          _shakeCount = 0;
          _onDeviceShaken();
        }
      }
    });
  }

  Future<void> _onDeviceShaken() async {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    final snack = SnackBar(
      content: const Text('Refreshing bids...'),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
    );
    ScaffoldMessenger.of(context).showSnackBar(snack);

    try {
      ref
          .read(categoryViewModelProvider.notifier)
          .getCategoryById(widget.categoryId);
      ref
          .read(productConditionViewModelProvider.notifier)
          .getProductConditionById(widget.productConditionId);
      ref
          .read(sellerViewModelProvider.notifier)
          .getSellerIdById(widget.sellerId);
      ref
          .read(productViewModelProvider.notifier)
          .getProductById(widget.productId);
      ref
          .read(bidViewModelProvider.notifier)
          .getAllBidsByProductId(widget.productId);
      ref.read(buyerViewModelProvider.notifier).getAllBuyers();
      ref
          .read(buyerViewModelProvider.notifier)
          .getCurrentUser(buyerId: widget.currentUserId);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bids refreshed'),
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
          content: Text('Failed to refresh bids: ${e.toString()}'),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _bidController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  String _calculateTimeLeft(DateTime? endDate) {
    final end = endDate?.toLocal() ?? DateTime.now();
    final now = DateTime.now();
    final difference = end.difference(now);

    if (difference.isNegative) {
      return "Auction Ended";
    }

    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;
    final seconds = difference.inSeconds % 60;

    String pad(int n) => n.toString().padLeft(2, '0');
    if (days > 0) {
      return "${pad(days)}d ${pad(hours)}h ${pad(minutes)}m";
    }
    return "${pad(hours)}:${pad(minutes)}:${pad(seconds)}";
  }

  String _formatAmount(double amount) {
    return "Rs. ${amount.toStringAsFixed(2)}";
  }

  /// Returns the display name for a bid given the bidders list.
  // String _bidderName(
  //   List<BuyerUiModel> bidders,
  //   BidUiModel bid,
  //   int fallbackIndex,
  // ) {
  //   if (bidders.isNotEmpty) {
  //     // final match = bidders.firstWhere((b) => b.buyerId == bid.buyerId);
  //     final match = bidders
  //         .map((b) => b.buyerId == bid.buyerId ? b : null)
  //         .firstWhere((b) => b != null, orElse: () => null);
  //     if (match != null) {
  //       return match.fullName;
  //     }
  //   }
  //   return "Bidder ${fallbackIndex + 1}";
  // }

  Future<void> _handlePlaceBid({
    required String productId,
    required String buyerId,
    required double bidAmount,
  }) async {
    await ref
        .read(bidViewModelProvider.notifier)
        .createBid(
          productId: productId,
          buyerId: buyerId,
          bidAmount: bidAmount,
        );
  }

  void _showBidBottomSheet(ProductUiModel product) {
    final double currentBid = product.currentBidPrice;
    final double interval = product.bidIntervalPrice;
    final double minBid = currentBid + interval;

    _bidController.text = minBid.toStringAsFixed(2);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            double currentAmount() =>
                double.tryParse(_bidController.text) ?? minBid;

            void setAmount(double v) {
              setSheet(() {
                _bidController.text = v.toStringAsFixed(2);
              });
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Handle
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    'Place Your Bid',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Current bid: ${_formatAmount(currentBid)}',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 20),

                  //Bid input with plus and minus buttons
                  Text(
                    'Your Bid Amount',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // Minus button
                      _IncrementButton(
                        icon: Icons.remove,
                        onPressed: currentAmount() <= minBid
                            ? null
                            : () {
                                final next = (currentAmount() - interval).clamp(
                                  minBid,
                                  double.infinity,
                                );
                                setAmount(next);
                              },
                      ),
                      const SizedBox(width: 10),

                      // Text field
                      Expanded(
                        child: TextField(
                          controller: _bidController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          // textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            prefixText: 'Rs. ',
                            prefixStyle: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                          ),
                          onChanged: (_) => setSheet(() {}),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Plus button
                      _IncrementButton(
                        icon: Icons.add,
                        onPressed: () => setAmount(currentAmount() + interval),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Minimum bid: ${_formatAmount(minBid)}  •  Bid Interval: ${_formatAmount(interval)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 20),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(sheetCtx),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.grey.shade700,
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: GradientElevatedButton(
                          onPressed: () {
                            final bidAmount =
                                double.tryParse(_bidController.text) ?? 0;
                            if (bidAmount < minBid) {
                              SnackbarUtil.showError(
                                context,
                                'Bid must be at least ${_formatAmount(minBid)}',
                              );
                              return;
                            }
                            _handlePlaceBid(
                              productId: widget.productId,
                              buyerId: widget.currentUserId,
                              bidAmount: bidAmount,
                            );
                            // ref
                            //     .read(bidViewModelProvider.notifier)
                            //     .createBid(
                            //       productId: widget.productId,
                            //       buyerId: widget.currentUserId,
                            //       bidAmount: bidAmount,
                            //     );
                            Navigator.pop(sheetCtx);
                          },
                          style: GradientElevatedButton.styleFrom(
                            backgroundGradient:
                                AppColors.auctionPrimaryGradient,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Confirm Bid',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    final categoryState = ref.watch(categoryViewModelProvider);
    final productConditionState = ref.watch(productConditionViewModelProvider);
    final productState = ref.watch(productViewModelProvider);
    final sellerState = ref.watch(sellerViewModelProvider);
    final buyerState = ref.watch(buyerViewModelProvider);
    final bidState = ref.watch(bidViewModelProvider);

    ref.listen<CategoryState>(categoryViewModelProvider, (previous, next) {
      if (next.categoryStatus == CategoryStatus.error) {
        SnackbarUtil.showError(
          context,
          next.errorMessage ?? "Error loading category!",
        );
      }
    });

    ref.listen<ProductConditionState>(productConditionViewModelProvider, (
      previous,
      next,
    ) {
      if (next.productConditionStatus == ProductConditionStatus.error) {
        SnackbarUtil.showError(
          context,
          next.errorMessage ?? "Error loading product condition!",
        );
      }
    });

    ref.listen<ProductState>(productViewModelProvider, (previous, next) {
      if (next.productStatus == ProductStatus.error) {
        SnackbarUtil.showError(
          context,
          next.errorMessage ?? "Error loading product details!",
        );
      }
    });

    ref.listen<SellerState>(sellerViewModelProvider, (previous, next) {
      if (next.sellerStatus == SellerStatus.error) {
        SnackbarUtil.showError(
          context,
          next.errorMessage ?? "Error loading seller details!",
        );
      }
    });

    ref.listen<BuyerState>(buyerViewModelProvider, (previous, next) {
      if (next.buyerStatus == BuyerStatus.error) {
        SnackbarUtil.showError(
          context,
          next.errorMessage ?? "Error loading current user details!",
        );
      }
    });

    ref.listen<BidState>(bidViewModelProvider, (previous, next) {
      if ((next.bidStatus == BidStatus.error)) {
        SnackbarUtil.showError(
          context,
          next.errorMessage ?? "Error loading current bid!",
        );
      } else if (next.bidStatus == BidStatus.updated) {
        SnackbarUtil.showSuccess(context, "Bid details updated successfully!");
      } else if (next.bidStatus == BidStatus.created) {
        // ref
        //     .read(productViewModelProvider.notifier)
        //     .getProductById(widget.productId);
        // ref
        //     .read(bidViewModelProvider.notifier)
        //     .getAllBidsByProductId(widget.productId);
        // ref.read(buyerViewModelProvider.notifier).getAllBuyers();
        SnackbarUtil.showSuccess(context, "Bid placed successfully!");
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0xFFDDDDDD),
                    width: 1.0,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => AppRoutes.pop(context),
                        child: Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: AppColors.arrowButtonPrimaryBackgroundColor,
                            boxShadow: AppColors.softShadow,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            color: AppColors.textPrimaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          "Product Details",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryColor,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(NotificationOutlinedIcon.icon),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),

            productState.productStatus == ProductStatus.loading
                ? const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                : productState.selectedProduct == null
                ? const Expanded(
                    child: Center(child: Text("Product not found")),
                  )
                : Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Images
                          _ProductImageCarousel(
                            imageUrls:
                                productState.selectedProduct!.productImageUrls,
                            height: isTablet ? 400 : 300,
                            pageController: _pageController,
                            currentIndex: _currentImageIndex,
                            onPageChanged: (i) =>
                                setState(() => _currentImageIndex = i),
                            favoriteWidget: FavoriteButtonWidget(
                              onFavoriteToggle: (val) {},
                              isFavorite: false,
                            ),
                          ),

                          // Time Remaining and Total Bids
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _InfoBadge(
                                  label: 'Time Remaining',
                                  value: _calculateTimeLeft(
                                    productState.selectedProduct?.endDate,
                                  ),
                                  valueColor: Colors.purple,
                                ),
                                _InfoBadge(
                                  label: 'Total Bids',
                                  value: '${bidState.bids.length}',
                                  valueColor: Colors.purple,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                ),
                              ],
                            ),
                          ),

                          // Product Name
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                            child: Text(
                              productState.selectedProduct!.productName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          // Category and Condition chips
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                            child: Wrap(
                              spacing: 8,
                              children: [
                                if (categoryState.selectedCategory != null)
                                  _TagChip(
                                    label: categoryState
                                        .selectedCategory!
                                        .categoryName,
                                    color: Colors.blue,
                                    background: Colors.blue.shade100,
                                  ),
                                if (productConditionState
                                        .selectedProductCondition !=
                                    null)
                                  _TagChip(
                                    label: productConditionState
                                        .selectedProductCondition!
                                        .productConditionName,
                                    color: Colors.green,
                                    background: Colors.green.shade100,
                                  ),
                              ],
                            ),
                          ),

                          // Current Bid row
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Current Bid',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatAmount(
                                        productState
                                            .selectedProduct!
                                            .currentBidPrice,
                                      ),
                                      style: const TextStyle(
                                        fontSize: 22,
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "Interval: ${_formatAmount(productState.selectedProduct!.bidIntervalPrice)}",
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${bidState.bids.length} bid${bidState.bids.length != 1 ? 's' : ''}",
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          if (sellerState.seller != null)
                            // Seller
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: Colors.grey.shade200,
                                    backgroundImage:
                                        sellerState.seller?.profilePictureUrl !=
                                            null
                                        ? NetworkImage(
                                            sellerState
                                                .seller!
                                                .profilePictureUrl!,
                                          )
                                        : null,
                                    child:
                                        sellerState.seller!.profilePictureUrl ==
                                            null
                                        ? Icon(
                                            Icons.person,
                                            color: Colors.grey.shade400,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      sellerState.seller!.fullName,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Description
                          if (productState
                                  .selectedProduct!
                                  .description
                                  ?.isNotEmpty ==
                              true)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Description',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    productState.selectedProduct!.description!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      height: 1.6,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Bid History
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                            child: const Text(
                              'Bid History',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          if ((bidState.bidStatus == BidStatus.loading) ||
                              (buyerState.buyerStatus == BuyerStatus.loading))
                            const Padding(
                              padding: EdgeInsets.all(24),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else if (bidState.bids.isEmpty ||
                              buyerState.buyers.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              child: Center(
                                child: Text(
                                  'No bids yet — be the first!',
                                  style: TextStyle(color: Colors.grey.shade500),
                                ),
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: bidState.bids.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final bid = bidState.bids[index];
                                final isHighest =
                                    bidState.bids
                                        .map((b) => b.bidAmount)
                                        .reduce((a, b) => a > b ? a : b) ==
                                    bid.bidAmount;
                                return buyerState.buyers
                                    .map(
                                      (buyer) => buyer.buyerId == bid.buyerId
                                          ? _BidHistoryTile(
                                              buyer: BuyerUiModel.fromEntity(
                                                buyer,
                                              ),
                                              bid: BidUiModel.fromEntity(bid),
                                              isHighest: isHighest,

                                              // name: buyer.fullName,
                                              // amount: _formatAmount(
                                              //   bid.bidAmount,
                                              // ),
                                              // time: bid.createdAt != null
                                              //     ? DateTime.parse(
                                              //         bid.createdAt!.toString(),
                                              //       ).toLocal()
                                              //     : DateTime.now(),
                                              // timeAgo: bid.createdAt != null
                                              //     ? DateTime.parse(
                                              //         bid.createdAt!.toString(),
                                              //       ).toLocal().toString()
                                              //     : "",
                                            )
                                          : null,
                                    )
                                    .firstWhere(
                                      (tile) => tile != null,
                                      orElse: () => null,
                                    );
                              },
                            ),

                          //     _BidHistoryTile(
                          //       name: _bidderName(
                          //         buyerState.buyers,
                          //         bid,
                          //         index,
                          //       ),
                          //       timeAgo: "",
                          //       amount: _formatAmount(bid.bidAmount),
                          //       isHighest: isHighest,
                          //     );
                          //   },
                          // ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),

            // Fixed bottom Place Bid button
            if (productState.productStatus != ProductStatus.loading &&
                productState.selectedProduct != null)
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: const Color(0xFFDDDDDD), width: 1.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: GradientElevatedButton(
                    style: GradientElevatedButton.styleFrom(
                      backgroundGradient: AppColors.auctionPrimaryGradient,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      elevation: 2,
                    ),
                    onPressed: () => _showBidBottomSheet(
                      ProductUiModel.fromEntity(productState.selectedProduct!),
                    ),
                    child: const Text(
                      "Place Bid",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Custom Image Carousel
class _ProductImageCarousel extends StatelessWidget {
  const _ProductImageCarousel({
    required this.imageUrls,
    required this.height,
    required this.pageController,
    required this.currentIndex,
    required this.onPageChanged,
    required this.favoriteWidget,
  });

  final List<String> imageUrls;
  final double height;
  final PageController pageController;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;
  final Widget favoriteWidget;

  @override
  Widget build(BuildContext context) {
    final images = imageUrls.isNotEmpty ? imageUrls : <String>[];
    final total = images.length;

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          // PageView
          PageView.builder(
            controller: pageController,
            itemCount: total == 0 ? 1 : total,
            onPageChanged: onPageChanged,
            itemBuilder: (_, index) {
              if (total == 0) {
                return _imagePlaceholder();
              }
              return Image.network(
                images[index],
                width: double.infinity,
                height: height,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : Container(
                        color: Colors.grey.shade100,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                errorBuilder: (_, _, _) => _imagePlaceholder(),
              );
            },
          ),

          // Counter badge
          if (total > 1)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${currentIndex + 1} / $total',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

          // Favourite button
          Positioned(
            top: 12,
            left: 12,
            child: Material(color: Colors.transparent, child: favoriteWidget),
          ),

          // Dot indicators
          if (total > 1)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(total, (i) {
                  final active = i == currentIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 20 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: active
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),

          // Left arrow
          if (total > 1 && currentIndex > 0)
            Positioned(
              left: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: _CarouselArrow(
                  icon: Icons.chevron_left,
                  onTap: () => pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                ),
              ),
            ),

          // Right arrow
          if (total > 1 && currentIndex < total - 1)
            Positioned(
              right: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: _CarouselArrow(
                  icon: Icons.chevron_right,
                  onTap: () => pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: Colors.grey.shade100,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 64,
          color: Colors.grey.shade300,
        ),
      ),
    );
  }
}

class _CarouselArrow extends StatelessWidget {
  const _CarouselArrow({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 22, color: Colors.black87),
      ),
    );
  }
}

// Increment Button: Plus and Minus
class _IncrementButton extends StatelessWidget {
  const _IncrementButton({required this.icon, this.onPressed});
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: onPressed == null
              ? Colors.grey.shade100
              : Colors.grey.shade200,
          shape: BoxShape.circle,
          border: Border.all(
            color: onPressed == null
                ? Colors.grey.shade200
                : Colors.grey.shade400,
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: onPressed == null ? Colors.grey.shade400 : Colors.black87,
        ),
      ),
    );
  }
}

// Info Badge (Time Remaining / Total Bids)
class _InfoBadge extends StatelessWidget {
  const _InfoBadge({
    required this.label,
    required this.value,
    required this.valueColor,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  final String label;
  final String value;
  final Color valueColor;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.purple.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}

// Tag Chip
class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.label,
    required this.color,
    required this.background,
  });

  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// Bid History Tile
class _BidHistoryTile extends StatelessWidget {
  const _BidHistoryTile({
    required this.buyer,
    required this.bid,
    this.isHighest = false,
    // required this.time,
    // required this.amount,
    // required this.name,
    // required this.timeAgo,
  });

  final BuyerUiModel buyer;
  final BidUiModel bid;
  final bool isHighest;
  // final DateTime time;
  // final String amount;
  // final String name;
  // final String timeAgo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isHighest ? Colors.purple.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: isHighest ? Border.all(color: Colors.purple.shade100) : null,
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: buyer.profilePictureUrl != null
                ? NetworkImage(buyer.profilePictureUrl!)
                : null,
            child: buyer.profilePictureUrl == null
                ? Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.purple.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_outline,
                      color: Colors.purple.shade400,
                      size: 20,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),

          // Name & time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      buyer.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    if (isHighest) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Highest',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                TimeAgoWidget(
                  dateTime: bid.createdAt != null
                      ? DateTime.parse(bid.createdAt!.toString()).toLocal()
                      : DateTime.now(),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiaryColor,
                  ),
                ),
                // Text(
                //   timeAgo,
                //   style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                // ),
              ],
            ),
          ),

          // Amount
          Text(
            "Rs. ${bid.bidAmount.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
