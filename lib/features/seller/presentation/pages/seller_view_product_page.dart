// lib/features/seller/presentation/pages/seller_view_product_page.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gradient_elevated_button/gradient_elevated_button.dart';
import 'package:leelame/app/theme/app_colors.dart';
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
import 'package:leelame/features/product/presentation/pages/update_product_details_page.dart';
import 'package:leelame/features/product/presentation/states/product_state.dart';
import 'package:leelame/features/product/presentation/viewmodels/product_view_model.dart';
import 'package:leelame/features/product/presentation/widgets/product_image_carousel_widget.dart';
import 'package:leelame/features/product_condition/presentation/states/product_condition_state.dart';
import 'package:leelame/features/product_condition/presentation/view_models/product_condition_view_model.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SellerProductDetailPage extends ConsumerStatefulWidget {
  const SellerProductDetailPage({
    super.key,
    required this.productId,
    required this.categoryId,
    required this.productConditionId,
    required this.sellerId,
  });

  final String productId;
  final String categoryId;
  final String productConditionId;
  final String sellerId;

  @override
  ConsumerState<SellerProductDetailPage> createState() =>
      _SellerProductDetailPageState();
}

class _SellerProductDetailPageState
    extends ConsumerState<SellerProductDetailPage> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  StreamSubscription<AccelerometerEvent>? _accelSub;
  DateTime? _lastShake;
  int _shakeCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAll();
      _startShake();
    });
  }

  void _loadAll() {
    ref
        .read(categoryViewModelProvider.notifier)
        .getCategoryById(widget.categoryId);
    ref
        .read(productConditionViewModelProvider.notifier)
        .getProductConditionById(widget.productConditionId);
    ref
        .read(productViewModelProvider.notifier)
        .getProductById(widget.productId);
    ref
        .read(bidViewModelProvider.notifier)
        .getAllBidsByProductId(widget.productId);
    ref.read(buyerViewModelProvider.notifier).getAllBuyers();
  }

  void _startShake() {
    _accelSub = accelerometerEventStream().listen((e) {
      final mag = sqrt(e.x * e.x + e.y * e.y + e.z * e.z);
      if (mag > 15) {
        final now = DateTime.now();
        if (_lastShake != null &&
            now.difference(_lastShake!) < const Duration(milliseconds: 500)) {
          _shakeCount++;
        } else {
          _shakeCount = 1;
        }
        _lastShake = now;
        if (_shakeCount >= 2) {
          _shakeCount = 0;
          _loadAll();
          if (mounted) SnackbarUtil.showSuccess(context, 'Data refreshed');
        }
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _accelSub?.cancel();
    super.dispose();
  }

  String _formatAmount(double v) => 'Rs. ${v.toStringAsFixed(2)}';

  String _calculateTimeLeft(DateTime? endDate) {
    if (endDate == null) return 'No end date';
    final diff = endDate.toLocal().difference(DateTime.now());
    if (diff.isNegative) return 'Auction Ended';
    final d = diff.inDays;
    final h = diff.inHours % 24;
    final m = diff.inMinutes % 60;
    final s = diff.inSeconds % 60;
    String pad(int n) => n.toString().padLeft(2, '0');
    if (d > 0) return '${pad(d)}d ${pad(h)}h ${pad(m)}m';
    return '${pad(h)}:${pad(m)}:${pad(s)}';
  }

  void _showSellerOptions(ProductUiModel product) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        final isTablet = MediaQuery.of(context).size.width > 600;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  'Product Options',
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.edit_outlined,
                      color: Colors.blue.shade600,
                    ),
                  ),
                  title: Text(
                    'Edit Product',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: isTablet ? 16 : 14,
                    ),
                  ),
                  subtitle: Text(
                    'Modify product details',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondaryColor,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UpdateProductPage(
                          categoryId: product.categoryId ?? '',
                          productConditionId: product.conditionId ?? '',
                          productId: product.productId ?? "",
                          sellerId: widget.sellerId,
                        ),
                      ),
                    ).then((_) => _loadAll());
                  },
                ),
                const SizedBox(height: 4),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.red.shade500,
                    ),
                  ),
                  title: Text(
                    'Delete Product',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: isTablet ? 16 : 14,
                      color: Colors.red.shade600,
                    ),
                  ),
                  subtitle: Text(
                    'Permanently remove this listing',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondaryColor,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmDelete(product);
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(ProductUiModel product) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        final isTablet = MediaQuery.of(context).size.width > 600;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 440 : double.infinity,
            ),
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    size: 32,
                    color: Colors.red.shade500,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Delete Product?',
                  style: TextStyle(
                    fontSize: isTablet ? 22 : 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'This action cannot be undone.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isTablet ? 15 : 13,
                    color: AppColors.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade100,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: isTablet ? 16 : 14,
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: isTablet ? 15 : 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ref
                              .read(productViewModelProvider.notifier)
                              .deleteProduct(productId: product.productId!);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade500,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: isTablet ? 16 : 14,
                          ),
                        ),
                        child: Text(
                          'Delete',
                          style: TextStyle(
                            fontSize: isTablet ? 15 : 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productViewModelProvider);
    final categoryState = ref.watch(categoryViewModelProvider);
    final conditionState = ref.watch(productConditionViewModelProvider);
    final bidState = ref.watch(bidViewModelProvider);
    final buyerState = ref.watch(buyerViewModelProvider);

    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    ref.listen<ProductState>(productViewModelProvider, (_, next) {
      if (next.productStatus == ProductStatus.error) {
        SnackbarUtil.showError(
          context,
          next.errorMessage ?? 'Error loading product.',
        );
      } else if (next.productStatus == ProductStatus.deleted) {
        SnackbarUtil.showSuccess(context, 'Product deleted.');
        Navigator.pop(context);
      } else if (next.productStatus == ProductStatus.updated) {
        SnackbarUtil.showSuccess(context, 'Product updated.');
        _loadAll();
      }
    });

    ref.listen<BidState>(bidViewModelProvider, (_, next) {
      if (next.bidStatus == BidStatus.error) {
        SnackbarUtil.showError(
          context,
          next.errorMessage ?? 'Error loading bids.',
        );
      }
    });

    if (productState.productStatus == ProductStatus.loading &&
        productState.selectedProduct == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (productState.selectedProduct == null) {
      return const Scaffold(body: Center(child: Text('Product not found.')));
    }

    final product = ProductUiModel.fromEntity(productState.selectedProduct!);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: isTablet && isLandscape
            ? _buildTabletLandscape(
                product: product,
                categoryState: categoryState,
                conditionState: conditionState,
                bidState: bidState,
                buyerState: buyerState,
                isTablet: isTablet,
              )
            : _buildPortrait(
                product: product,
                categoryState: categoryState,
                conditionState: conditionState,
                bidState: bidState,
                buyerState: buyerState,
                isTablet: isTablet,
              ),
      ),
    );
  }

  Widget _buildTabletLandscape({
    required ProductUiModel product,
    required CategoryState categoryState,
    required ProductConditionState conditionState,
    required BidState bidState,
    required BuyerState buyerState,
    required bool isTablet,
  }) {
    return Row(
      children: [
        Expanded(
          child: Stack(
            children: [
              ProductImageCarousel(
                imageUrls: product.productImageUrls,
                height: double.infinity,
                pageController: _pageController,
                currentIndex: _currentImageIndex,
                onPageChanged: (i) => setState(() => _currentImageIndex = i),
                favoriteWidget: null,
              ),
              Positioned(top: 14, left: 14, child: _BackButton()),
              Positioned(
                top: 14,
                right: 14,
                child: _MoreButton(onTap: () => _showSellerOptions(product)),
              ),
            ],
          ),
        ),
        Expanded(
          child: _DetailPanel(
            product: product,
            categoryState: categoryState,
            conditionState: conditionState,
            bidState: bidState,
            buyerState: buyerState,
            isTablet: isTablet,
            formatAmount: _formatAmount,
            timeLeft: _calculateTimeLeft(product.endDate),
            onEdit: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => UpdateProductPage(
                  categoryId: product.categoryId ?? '',
                  productConditionId: product.conditionId ?? '',
                  productId: product.productId ?? '',
                  sellerId: widget.sellerId,
                ),
              ),
            ).then((_) => _loadAll()),
            onDelete: () => _confirmDelete(product),
          ),
        ),
      ],
    );
  }

  Widget _buildPortrait({
    required ProductUiModel product,
    required CategoryState categoryState,
    required ProductConditionState conditionState,
    required BidState bidState,
    required BuyerState buyerState,
    required bool isTablet,
  }) {
    return Column(
      children: [
        _buildAppBar(product: product, isTablet: isTablet),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProductImageCarousel(
                  imageUrls: product.productImageUrls,
                  height: isTablet ? 420 : 300,
                  pageController: _pageController,
                  currentIndex: _currentImageIndex,
                  onPageChanged: (i) => setState(() => _currentImageIndex = i),
                  favoriteWidget: null,
                ),
                _DetailPanel(
                  product: product,
                  categoryState: categoryState,
                  conditionState: conditionState,
                  bidState: bidState,
                  buyerState: buyerState,
                  isTablet: isTablet,
                  formatAmount: _formatAmount,
                  timeLeft: _calculateTimeLeft(product.endDate),
                  onEdit: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UpdateProductPage(
                        productId: product.productId ?? '',
                        sellerId: widget.sellerId,
                        categoryId: product.categoryId ?? '',
                        productConditionId: product.conditionId ?? '',
                      ),
                    ),
                  ).then((_) => _loadAll()),
                  onDelete: () => _confirmDelete(product),
                  insideScroll: true,
                ),
              ],
            ),
          ),
        ),
        _buildBottomBar(product: product, isTablet: isTablet),
      ],
    );
  }

  Widget _buildAppBar({
    required ProductUiModel product,
    required bool isTablet,
  }) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, isTablet ? 16 : 12, 20, 0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _BackButton(),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Product Details',
                  style: TextStyle(
                    fontSize: isTablet ? 24 : 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryColor,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _showSellerOptions(product),
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: AppColors.textPrimaryColor,
                  size: isTablet ? 26 : 22,
                ),
                tooltip: 'Options',
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildBottomBar({
    required ProductUiModel product,
    required bool isTablet,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UpdateProductPage(
                    productId: product.productId ?? '',
                    sellerId: widget.sellerId,
                    categoryId: product.categoryId ?? '',
                    productConditionId: product.conditionId ?? '',
                  ),
                ),
              ).then((_) => _loadAll()),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: EdgeInsets.symmetric(vertical: isTablet ? 18 : 14),
                elevation: 0,
              ),
              icon: const Icon(
                Icons.edit_outlined,
                color: Colors.white,
                size: 18,
              ),
              label: Text(
                'Edit Product',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isTablet ? 15 : 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => _confirmDelete(product),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade500,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 22 : 18,
                vertical: isTablet ? 18 : 14,
              ),
              elevation: 0,
            ),
            child: Icon(
              Icons.delete_outline_rounded,
              color: Colors.white,
              size: isTablet ? 22 : 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailPanel extends StatelessWidget {
  const _DetailPanel({
    required this.product,
    required this.categoryState,
    required this.conditionState,
    required this.bidState,
    required this.buyerState,
    required this.isTablet,
    required this.formatAmount,
    required this.timeLeft,
    required this.onEdit,
    required this.onDelete,
    this.insideScroll = false,
  });

  final ProductUiModel product;
  final CategoryState categoryState;
  final ProductConditionState conditionState;
  final BidState bidState;
  final BuyerState buyerState;
  final bool isTablet;
  final String Function(double) formatAmount;
  final String timeLeft;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool insideScroll;

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTimeBidRow(context),
        _buildProductName(context),
        _buildTags(context),
        _buildPricingSection(context),
        if (product.buyNowPrice != null) _buildBuyNowBanner(context),
        if (product.description?.isNotEmpty == true) _buildDescription(context),
        _buildBidHistory(context),
        if (!insideScroll) const SizedBox(height: 20),
      ],
    );

    if (!insideScroll) {
      return Expanded(child: SingleChildScrollView(child: content));
    }
    return content;
  }

  Widget _buildTimeBidRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _InfoChip(
            label: 'Time Left',
            value: timeLeft,
            color: Colors.purple.shade400,
            bgColor: Colors.purple.shade50,
          ),
          _InfoChip(
            label: 'Total Bids',
            value: '${bidState.bids.length}',
            color: Colors.purple.shade400,
            bgColor: Colors.purple.shade50,
            alignRight: true,
          ),
        ],
      ),
    );
  }

  Widget _buildProductName(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Text(
        product.productName,
        style: TextStyle(
          fontSize: isTablet ? 24 : 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimaryColor,
        ),
      ),
    );
  }

  Widget _buildTags(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: [
          if (categoryState.selectedCategory != null)
            _TagChip(
              label: categoryState.selectedCategory!.categoryName,
              color: Colors.blue.shade700,
              bgColor: Colors.blue.shade50,
            ),
          if (conditionState.selectedProductCondition != null)
            _TagChip(
              label:
                  conditionState.selectedProductCondition!.productConditionName,
              color: Colors.green.shade700,
              bgColor: Colors.green.shade50,
            ),
        ],
      ),
    );
  }

  Widget _buildPricingSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppColors.softShadow,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Bid',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatAmount(product.currentBidPrice),
                    style: TextStyle(
                      fontSize: isTablet ? 22 : 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Container(width: 1, height: 40, color: const Color(0xFFF0F0F0)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bid Interval',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatAmount(product.bidIntervalPrice),
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryColor,
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

  Widget _buildBuyNowBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.amber.shade300),
        ),
        child: Row(
          children: [
            Icon(
              Icons.flash_on_rounded,
              color: Colors.amber.shade700,
              size: isTablet ? 24 : 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Buy Now Available',
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.amber.shade800,
                    ),
                  ),
                  Text(
                    formatAmount(product.buyNowPrice!),
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade900,
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

  Widget _buildDescription(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product.description!,
            style: TextStyle(
              fontSize: isTablet ? 15 : 14,
              height: 1.6,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBidHistory(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Row(
            children: [
              Text(
                'Bid History',
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryColor,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryButtonColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${bidState.bids.length} bids',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryButtonColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (bidState.bidStatus == BidStatus.loading ||
            buyerState.buyerStatus == BuyerStatus.loading)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (bidState.bids.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Center(
              child: Text(
                'No bids yet.',
                style: TextStyle(
                  color: AppColors.textSecondaryColor,
                  fontSize: isTablet ? 15 : 13,
                ),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: bidState.bids.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final bid = bidState.bids[index];
              final bidUi = BidUiModel.fromEntity(bid);
              final buyer = buyerState.buyers
                  .map((b) => b.buyerId == bid.buyerId ? b : null)
                  .firstWhere((b) => b != null, orElse: () => null);

              final allAmounts = bidState.bids.map((b) => b.bidAmount);
              final maxAmount = allAmounts.isNotEmpty
                  ? allAmounts.reduce((a, b) => a > b ? a : b)
                  : 0.0;
              final isHighest = bid.bidAmount == maxAmount;

              return _BidTile(
                buyerName: buyer != null
                    ? BuyerUiModel.fromEntity(buyer).fullName
                    : 'Bidder ${index + 1}',
                avatarUrl: buyer != null
                    ? BuyerUiModel.fromEntity(buyer).profilePictureUrl
                    : null,
                amount: formatAmount(bidUi.bidAmount),
                isHighest: isHighest,
                bidTime: bidUi.createdAt,
                isTablet: isTablet,
              );
            },
          ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _BidTile extends StatelessWidget {
  const _BidTile({
    required this.buyerName,
    required this.amount,
    required this.isHighest,
    required this.isTablet,
    this.avatarUrl,
    this.bidTime,
  });

  final String buyerName;
  final String? avatarUrl;
  final String amount;
  final bool isHighest;
  final DateTime? bidTime;
  final bool isTablet;

  String _timeAgo() {
    if (bidTime == null) return '';
    final diff = DateTime.now().difference(bidTime!);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isHighest ? Colors.amber.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isHighest ? Colors.amber.shade300 : const Color(0xFFF0F0F0),
          width: isHighest ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: isTablet ? 24 : 20,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: avatarUrl != null
                ? NetworkImage(avatarUrl!)
                : null,
            child: avatarUrl == null
                ? Icon(
                    Icons.person,
                    size: isTablet ? 22 : 18,
                    color: Colors.grey.shade400,
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      buyerName,
                      style: TextStyle(
                        fontSize: isTablet ? 15 : 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryColor,
                      ),
                    ),
                    if (isHighest) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade400,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Highest',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (bidTime != null)
                  Text(
                    _timeAgo(),
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondaryColor,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              fontWeight: FontWeight.bold,
              color: isHighest
                  ? Colors.amber.shade800
                  : AppColors.primaryButtonColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.value,
    required this.color,
    required this.bgColor,
    this.alignRight = false,
  });

  final String label;
  final String value;
  final Color color;
  final Color bgColor;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: AppColors.textSecondaryColor),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.label,
    required this.color,
    required this.bgColor,
  });

  final String label;
  final Color color;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
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

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.arrowButtonPrimaryBackgroundColor,
          boxShadow: AppColors.softShadow,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.arrow_back_rounded),
      ),
    );
  }
}

class _MoreButton extends StatelessWidget {
  const _MoreButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: AppColors.softShadow,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.more_vert_rounded,
          color: AppColors.textPrimaryColor,
        ),
      ),
    );
  }
}
