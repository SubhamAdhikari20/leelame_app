// lib/features/product/presentation/pages/product_view_details_page.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gradient_elevated_button/gradient_elevated_button.dart';
import 'package:leelame/app/routes/app_routes.dart';
import 'package:leelame/app/theme/app_colors.dart';
import 'package:leelame/core/custom_icons/notification_outlined_icon.dart';
import 'package:leelame/core/services/storage/wishlist_service.dart';
import 'package:leelame/core/utils/snackbar_util.dart';
import 'package:leelame/features/bid/presentation/models/bid_ui_model.dart';
import 'package:leelame/features/bid/presentation/states/bid_state.dart';
import 'package:leelame/features/bid/presentation/view_models/bid_view_model.dart';
import 'package:leelame/features/buyer/presentation/models/buyer_ui_model.dart';
import 'package:leelame/features/buyer/presentation/states/buyer_state.dart';
import 'package:leelame/features/buyer/presentation/view_models/buyer_view_model.dart';
import 'package:leelame/features/category/presentation/states/category_state.dart';
import 'package:leelame/features/category/presentation/view_models/category_view_model.dart';
import 'package:leelame/features/order/domain/entities/order_entity.dart';
import 'package:leelame/features/order/presentation/states/order_state.dart';
import 'package:leelame/features/order/presentation/view_models/order_view_model.dart';
import 'package:leelame/features/payment/domain/entities/payment_entity.dart';
import 'package:leelame/features/product/presentation/models/product_ui_model.dart';
import 'package:leelame/features/product/presentation/states/product_state.dart';
import 'package:leelame/features/product/presentation/viewmodels/product_view_model.dart';
import 'package:leelame/features/product/presentation/widgets/bid_history_tile_widget.dart';
import 'package:leelame/features/product/presentation/widgets/favorite_button_widget.dart';
import 'package:leelame/features/product/presentation/widgets/product_image_carousel_widget.dart';
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

  @override
  ConsumerState<ProductViewDetailsPage> createState() =>
      _ProductViewDetailsPageState();
}

class _ProductViewDetailsPageState
    extends ConsumerState<ProductViewDetailsPage> {
  final TextEditingController _bidController = TextEditingController();
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;
  bool _isFavorite = false;

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
      _loadFavoriteStatus();
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

  Future<void> _loadFavoriteStatus() async {
    final isFav = ref
        .read(wishlistServiceProvider)
        .isWishlisted(
          userId: widget.currentUserId,
          productId: widget.productId,
        );
    if (!mounted) {
      return;
    }
    setState(() {
      _isFavorite = isFav;
    });
  }

  Future<void> _toggleFavorite(bool shouldBeFavorite) async {
    await ref
        .read(wishlistServiceProvider)
        .toggleWishlist(
          userId: widget.currentUserId,
          productId: widget.productId,
          shouldBeFavorite: shouldBeFavorite,
        );

    if (!mounted) {
      return;
    }

    setState(() {
      _isFavorite = shouldBeFavorite;
    });
  }

  @override
  void dispose() {
    _accelSubscription?.cancel();
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

  double _calculateCommissionAmount({
    required double buyNowPrice,
    required double commissionRate,
  }) {
    return (buyNowPrice * commissionRate) / 100;
  }

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

  Future<void> _handleBuyNow(ProductUiModel product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Purchase'),
        content: Text(
          'Buy "${product.productName}" now for ${_formatAmount(product.buyNowPrice ?? 0)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryButtonColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Buy Now', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    // if (confirmed == true) {
    //   // Proceed with the purchase
    // }
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

            double totalWithCommission =
                currentAmount() + (currentAmount() * product.commission / 100);

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

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current bid: ${_formatAmount(currentBid)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 5),

                      Text(
                        'Service fee: ${product.commission}%',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 5),

                      Text(
                        'You will pay: ${_formatAmount(totalWithCommission)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimaryColor,
                        ),
                      ),
                    ],
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

  void _showBuyNowCheckoutSheet(ProductUiModel product, OrderState orderState) {
    final buyNowPrice = product.buyNowPrice;
    if (buyNowPrice == null) {
      SnackbarUtil.showError(context, 'Buy Now is not available for this item');
      return;
    }

    final addressController = TextEditingController();
    PaymentMethod selectedGateway = PaymentMethod.khalti;
    final commissionAmount = _calculateCommissionAmount(
      buyNowPrice: buyNowPrice,
      commissionRate: product.commission,
    );
    final totalAmount = buyNowPrice + commissionAmount;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Buy Now Checkout',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: addressController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Delivery Address',
                      hintText: 'Enter complete shipping address',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<PaymentMethod>(
                    initialValue: selectedGateway,
                    decoration: InputDecoration(
                      labelText: 'Payment Gateway (Test)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: PaymentMethod.values
                        .map(
                          (gateway) => DropdownMenuItem(
                            value: gateway,
                            child: Text(gateway.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setSheet(() => selectedGateway = value);
                    },
                  ),
                  const SizedBox(height: 14),
                  _checkoutRow('Buy Now Price', _formatAmount(buyNowPrice)),
                  _checkoutRow(
                    'Commission (${product.commission.toStringAsFixed(2)}%)',
                    _formatAmount(commissionAmount),
                  ),
                  _checkoutRow(
                    'Total',
                    _formatAmount(totalAmount),
                    isBold: true,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: GradientElevatedButton(
                      style: GradientElevatedButton.styleFrom(
                        backgroundGradient: AppColors.auctionPrimaryGradient,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        final delivaryAddress = addressController.text.trim();
                        if (delivaryAddress.isEmpty) {
                          SnackbarUtil.showError(
                            context,
                            'Please enter delivery address',
                          );
                          return;
                        }

                        final order = await ref
                            .read(orderViewModelProvider.notifier)
                            .createOrder(
                              productId: product.productId!,
                              buyerId: widget.currentUserId,
                              sellerId: product.sellerId!,
                              delivaryDate: DateTime.now().add(
                                const Duration(days: 2),
                              ),
                              delivaryAddress: delivaryAddress,
                              totalPrice: totalAmount,
                              status: OrderStatus.pending,
                            );

                        if (orderState.order == null) {
                          if (!mounted) {
                            return;
                          }
                          SnackbarUtil.showError(
                            context,
                            ref.read(orderViewModelProvider).errorMessage ??
                                'Failed to create order',
                          );
                          return;
                        }

                        // final payment = await ref
                        //     .read(paymentViewModelProvider.notifier)
                        //     .processTestGatewayPayment(
                        //       orderId: orderState.order?.orderId ?? '',
                        //       gateway: selectedGateway,
                        //       amount: totalAmount,
                        //     );

                        // if (payment == null) {
                        //   await ref
                        //       .read(orderViewModelProvider.notifier)
                        //       .updateOrderStatus(
                        //         orderId: orderState.order?.orderId ?? '',
                        //         status: OrderStatus.pending,
                        //       );
                        //   if (!mounted) {
                        //     return;
                        //   }
                        //   SnackbarUtil.showError(
                        //     context,
                        //     ref.read(paymentViewModelProvider).errorMessage ??
                        //         'Payment failed',
                        //   );
                        //   return;
                        // }

                        final updatedOrder = await ref
                            .read(orderViewModelProvider.notifier)
                            .updateOrderStatus(
                              orderId: orderState.order?.orderId ?? '',
                              status: OrderStatus.pending,
                            );

                        // final invoice = await ref
                        //     .read(invoiceViewModelProvider.notifier)
                        //     .createInvoice(

                        //       order: updatedOrder ?? order,
                        //       payment: payment,
                        //     );

                        // if (!mounted) {
                        //   return;
                        // }

                        // AppRoutes.pop(sheetCtx);

                        // if (invoice == null) {
                        //   SnackbarUtil.showSuccess(
                        //     context,
                        //     'Payment successful. Invoice generation failed.',
                        //   );
                        //   return;
                        // }

                        // SnackbarUtil.showSuccess(
                        //   context,
                        //   'Payment completed successfully!',
                        // );
                        // AppRoutes.push(
                        //   context,
                        //   InvoicePage(
                        //     invoice: InvoiceUiModel.fromEntity(invoice),
                        //   ),
                        // );
                      },
                      child: const Text(
                        'Place Order & Pay',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(addressController.dispose);
  }

  Widget _checkoutRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade700)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
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
        SnackbarUtil.showSuccess(context, "Bid placed successfully!");
      }
    });

    final hasBuyNow = productState.selectedProduct?.buyNowPrice != null;

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
                          ProductImageCarousel(
                            imageUrls:
                                productState.selectedProduct!.productImageUrls,
                            height: isTablet ? 400 : 300,
                            pageController: _pageController,
                            currentIndex: _currentImageIndex,
                            onPageChanged: (i) =>
                                setState(() => _currentImageIndex = i),
                            favoriteWidget: FavoriteButtonWidget(
                              onFavoriteToggle: _toggleFavorite,
                              isFavorite: _isFavorite,
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
                                    const SizedBox(height: 4),

                                    if (productState
                                            .selectedProduct!
                                            .buyNowPrice !=
                                        null)
                                      Text(
                                        "Buy Price: ${_formatAmount(productState.selectedProduct!.buyNowPrice!)}",
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
                                          ? BidHistoryTile(
                                              buyer: BuyerUiModel.fromEntity(
                                                buyer,
                                              ),
                                              bid: BidUiModel.fromEntity(bid),
                                              isHighest: isHighest,
                                            )
                                          : null,
                                    )
                                    .firstWhere(
                                      (tile) => tile != null,
                                      orElse: () => null,
                                    );
                              },
                            ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),

            // Fixed bottom action buttons
            if (productState.productStatus != ProductStatus.loading &&
                productState.selectedProduct != null)
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: const Border(
                    top: BorderSide(color: Color(0xFFDDDDDD), width: 1.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    if (hasBuyNow) ...[
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber.shade600,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: isTablet ? 20 : 16,
                            ),
                            elevation: 2,
                          ),
                          onPressed: () => _handleBuyNow(
                            ProductUiModel.fromEntity(
                              productState.selectedProduct!,
                            ),
                          ),
                          child: const Text(
                            'Buy Now',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],

                    Expanded(
                      flex: hasBuyNow ? 2 : 1,
                      child: GradientElevatedButton(
                        style: GradientElevatedButton.styleFrom(
                          backgroundGradient: AppColors.auctionPrimaryGradient,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: isTablet ? 20 : 16,
                          ),
                          elevation: 2,
                        ),
                        onPressed: () => _showBidBottomSheet(
                          ProductUiModel.fromEntity(
                            productState.selectedProduct!,
                          ),
                        ),
                        child: const Text(
                          'Place Bid',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
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
