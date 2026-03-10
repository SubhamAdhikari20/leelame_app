// lib/features/seller/presentation/pages/screens/seller_home_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/app/routes/app_routes.dart';
import 'package:leelame/app/theme/app_colors.dart';
import 'package:leelame/core/services/proximity_service.dart';
import 'package:leelame/core/services/storage/user_session_service.dart';
import 'package:leelame/core/utils/snackbar_util.dart';
import 'package:leelame/features/product/domain/entities/product_entity.dart';
import 'package:leelame/features/product/presentation/pages/seller_product_view_details_page.dart';
import 'package:leelame/features/product/presentation/states/product_state.dart';
import 'package:leelame/features/product/presentation/viewmodels/product_view_model.dart';
import 'package:leelame/features/seller/presentation/states/seller_state.dart';
import 'package:leelame/features/seller/presentation/view_models/seller_view_model.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SellerHomeScreen extends ConsumerStatefulWidget {
  const SellerHomeScreen({super.key});

  @override
  ConsumerState<SellerHomeScreen> createState() => _SellerHomeScreenState();
}

enum _HomeFilter { all, active, endingSoon, ended }

class _SellerHomeScreenState extends ConsumerState<SellerHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ProximitySensorService _proximitySvc = ProximitySensorService();

  String? _sellerId;
  String _searchQuery = '';
  _HomeFilter _selectedFilter = _HomeFilter.all;
  StreamSubscription<AccelerometerEvent>? _accelSub;
  DateTime? _lastShake;
  int _shakeCount = 0;

  @override
  void initState() {
    super.initState();
    _proximitySvc.start();
    _proximitySvc.isPrivacyMode.addListener(_onPrivacyModeChanged);

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sellerId = ref.read(userSessionServiceProvider).getUserId();
      _refreshDashboard();
      _startShakeDetection();
    });
  }

  void _onPrivacyModeChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _proximitySvc.isPrivacyMode.removeListener(_onPrivacyModeChanged);
    _proximitySvc.dispose();
    _accelSub?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _startShakeDetection() {
    _accelSub = accelerometerEventStream().listen((event) {
      final magnitude = sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      );

      if (magnitude <= 15) return;

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
        _refreshDashboard();
        if (mounted) {
          SnackbarUtil.showSuccess(context, 'Dashboard refreshed');
        }
      }
    });
  }

  Future<void> _refreshDashboard() async {
    if (_sellerId == null) return;
    await ref
        .read(sellerViewModelProvider.notifier)
        .getCurrentUser(sellerId: _sellerId!);
    await ref
        .read(productViewModelProvider.notifier)
        .getAllProductsBySellerId(_sellerId!);
  }

  double _fontSize(double base, double width) {
    final scale = (width / 390).clamp(0.92, 1.32);
    return base * scale;
  }

  List<ProductEntity> _applyFilters(List<ProductEntity> products) {
    final now = DateTime.now();
    final query = _searchQuery;

    return products.where((product) {
      final endsIn = product.endDate.difference(now);
      final isEnded = endsIn.isNegative || product.isSoldOut;
      final isEndingSoon = !isEnded && endsIn <= const Duration(hours: 24);

      final matchesSearch =
          query.isEmpty ||
          product.productName.toLowerCase().contains(query) ||
          (product.description ?? '').toLowerCase().contains(query);

      if (!matchesSearch) return false;

      switch (_selectedFilter) {
        case _HomeFilter.all:
          return true;
        case _HomeFilter.active:
          return !isEnded;
        case _HomeFilter.endingSoon:
          return isEndingSoon;
        case _HomeFilter.ended:
          return isEnded;
      }
    }).toList()..sort((a, b) => a.endDate.compareTo(b.endDate));
  }

  String _formatAmount(double value) {
    final fixed = value.toStringAsFixed(0);
    final chars = fixed.split('').reversed.toList();
    final buffer = StringBuffer();

    for (var i = 0; i < chars.length; i++) {
      if (i > 0 && i % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(chars[i]);
    }

    return buffer.toString().split('').reversed.join();
  }

  String _timeLeftLabel(DateTime endDate) {
    final diff = endDate.difference(DateTime.now());
    if (diff.isNegative) return 'Ended';
    if (diff.inDays > 0) return '${diff.inDays}d left';
    if (diff.inHours > 0) return '${diff.inHours}h left';
    return '${diff.inMinutes.clamp(1, 59)}m left';
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required double width,
    required bool isPrivate,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppColors.softShadow,
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'OpenSans Medium',
                    fontSize: _fontSize(12, width),
                    color: AppColors.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 2),
                PrivacyText(
                  value,
                  isPrivate: isPrivate,
                  style: TextStyle(
                    fontFamily: 'OpenSans Bold',
                    fontSize: _fontSize(16, width),
                    color: AppColors.textPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sellerState = ref.watch(sellerViewModelProvider);
    final productState = ref.watch(productViewModelProvider);

    ref.listen<SellerState>(sellerViewModelProvider, (_, next) {
      if (next.sellerStatus == SellerStatus.error && mounted) {
        SnackbarUtil.showError(
          context,
          next.errorMessage ?? 'Unable to load seller profile.',
        );
      }
    });

    ref.listen<ProductState>(productViewModelProvider, (_, next) {
      if (next.productStatus == ProductStatus.error && mounted) {
        SnackbarUtil.showError(
          context,
          next.errorMessage ?? 'Unable to load product data.',
        );
      }
    });

    final width = MediaQuery.of(context).size.width;
    final isTablet = width >= 700;
    final isPrivate = _proximitySvc.isPrivacyMode.value;
    final sellerName = sellerState.seller?.fullName ?? 'Seller';

    final allProducts = productState.products
        .where((p) => _sellerId == null || p.sellerId == _sellerId)
        .toList();
    final filteredProducts = _applyFilters(allProducts);

    final total = allProducts.length;
    final active = allProducts
        .where(
          (p) =>
              !p.endDate.difference(DateTime.now()).isNegative && !p.isSoldOut,
        )
        .length;
    final ended = allProducts.length - active;
    final potentialRevenue = allProducts.fold<double>(
      0,
      (sum, p) => sum + (p.buyNowPrice ?? p.currentBidPrice),
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryButtonColor,
          onRefresh: _refreshDashboard,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    isTablet ? 32 : 16,
                    16,
                    isTablet ? 32 : 16,
                    12,
                  ),
                  child: Container(
                    padding: EdgeInsets.all(isTablet ? 24 : 18),
                    decoration: BoxDecoration(
                      gradient: AppColors.auctionPrimaryGradient,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: AppColors.elevatedShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: isTablet ? 26 : 22,
                              backgroundColor: AppColors.white30,
                              child: Icon(
                                Icons.storefront_rounded,
                                color: Colors.white,
                                size: isTablet ? 28 : 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Welcome back, $sellerName',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'OpenSans Bold',
                                  fontSize: _fontSize(20, width),
                                  color: Colors.white,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: _refreshDashboard,
                              icon: const Icon(
                                Icons.refresh_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Track performance, monitor deadlines, and keep your auctions active.',
                          style: TextStyle(
                            fontFamily: 'OpenSans Regular',
                            fontSize: _fontSize(13, width),
                            color: AppColors.white90,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 16),
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(
                      fontFamily: 'OpenSans Medium',
                      fontSize: _fontSize(14, width),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search auctions by product name',
                      hintStyle: TextStyle(
                        fontFamily: 'OpenSans Regular',
                        color: AppColors.textTertiaryColor,
                        fontSize: _fontSize(13, width),
                      ),
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              onPressed: () => _searchController.clear(),
                              icon: const Icon(Icons.clear_rounded),
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: AppColors.borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: AppColors.borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: AppColors.primaryButtonColor,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(isTablet ? 32 : 16, 12, 16, 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final filter in _HomeFilter.values)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(
                                switch (filter) {
                                  _HomeFilter.all => 'All',
                                  _HomeFilter.active => 'Active',
                                  _HomeFilter.endingSoon => 'Ending Soon',
                                  _HomeFilter.ended => 'Ended',
                                },
                                style: TextStyle(
                                  fontFamily: 'OpenSans SemiBold',
                                  fontSize: _fontSize(12, width),
                                  color: _selectedFilter == filter
                                      ? Colors.white
                                      : AppColors.textPrimaryColor,
                                ),
                              ),
                              selected: _selectedFilter == filter,
                              onSelected: (_) {
                                setState(() {
                                  _selectedFilter = filter;
                                });
                              },
                              selectedColor: AppColors.primaryButtonColor,
                              backgroundColor: Colors.white,
                              side: BorderSide(color: AppColors.borderColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 16),
                sliver: SliverGrid(
                  delegate: SliverChildListDelegate([
                    _buildStatCard(
                      title: 'Total Auctions',
                      value: '$total',
                      icon: Icons.inventory_2_rounded,
                      iconColor: AppColors.info,
                      width: width,
                      isPrivate: isPrivate,
                    ),
                    _buildStatCard(
                      title: 'Active',
                      value: '$active',
                      icon: Icons.trending_up_rounded,
                      iconColor: AppColors.success,
                      width: width,
                      isPrivate: isPrivate,
                    ),
                    _buildStatCard(
                      title: 'Ended',
                      value: '$ended',
                      icon: Icons.hourglass_disabled_rounded,
                      iconColor: AppColors.warning,
                      width: width,
                      isPrivate: isPrivate,
                    ),
                    _buildStatCard(
                      title: 'Potential NPR',
                      value: 'Rs ${_formatAmount(potentialRevenue)}',
                      icon: Icons.paid_rounded,
                      iconColor: AppColors.primaryButtonColor,
                      width: width,
                      isPrivate: isPrivate,
                    ),
                  ]),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isTablet ? 4 : 2,
                    childAspectRatio: isTablet ? 2.7 : 1.45,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    isTablet ? 32 : 16,
                    18,
                    isTablet ? 32 : 16,
                    8,
                  ),
                  child: Text(
                    'Recent Activity',
                    style: TextStyle(
                      fontFamily: 'OpenSans Bold',
                      fontSize: _fontSize(18, width),
                      color: AppColors.textPrimaryColor,
                    ),
                  ),
                ),
              ),
              if (productState.productStatus == ProductStatus.loading &&
                  allProducts.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (filteredProducts.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 80 : 30,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: isTablet ? 64 : 52,
                            color: AppColors.textSecondary60,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'No results matched your search.'
                                : 'No auctions found for this filter.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'OpenSans SemiBold',
                              fontSize: _fontSize(15, width),
                              color: AppColors.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    isTablet ? 32 : 16,
                    0,
                    isTablet ? 32 : 16,
                    16,
                  ),
                  sliver: SliverList.builder(
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      final isEnded =
                          product.endDate
                              .difference(DateTime.now())
                              .isNegative ||
                          product.isSoldOut;
                      final imageUrl = product.productImageUrls.isEmpty
                          ? null
                          : product.productImageUrls.first;

                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          if (product.productId == null ||
                              product.categoryId == null ||
                              product.conditionId == null ||
                              _sellerId == null) {
                            SnackbarUtil.showError(
                              context,
                              'Unable to open product details.',
                            );
                            return;
                          }

                          AppRoutes.push(
                            context,
                            SellerProductViewDetailsPage(
                              productId: product.productId!,
                              categoryId: product.categoryId!,
                              productConditionId: product.conditionId!,
                              currentUserId: _sellerId!,
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.borderColor),
                            boxShadow: AppColors.softShadow,
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: SizedBox(
                                  width: isTablet ? 84 : 72,
                                  height: isTablet ? 84 : 72,
                                  child: imageUrl == null
                                      ? Container(
                                          color: AppColors.surfaceVariantColor,
                                          child: Icon(
                                            Icons.image_not_supported_outlined,
                                            color: AppColors.textSecondaryColor,
                                          ),
                                        )
                                      : Image.network(
                                          imageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              Container(
                                                color: AppColors
                                                    .surfaceVariantColor,
                                                child: Icon(
                                                  Icons.broken_image_outlined,
                                                  color: AppColors
                                                      .textSecondaryColor,
                                                ),
                                              ),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.productName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: 'OpenSans Bold',
                                        fontSize: _fontSize(15, width),
                                        color: AppColors.textPrimaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Current Bid: Rs ${_formatAmount(product.currentBidPrice)}',
                                      style: TextStyle(
                                        fontFamily: 'OpenSans Medium',
                                        fontSize: _fontSize(12.5, width),
                                        color: AppColors.textSecondaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isEnded
                                            ? AppColors.warning.withValues(
                                                alpha: 0.16,
                                              )
                                            : AppColors.success.withValues(
                                                alpha: 0.16,
                                              ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        _timeLeftLabel(product.endDate),
                                        style: TextStyle(
                                          fontFamily: 'OpenSans SemiBold',
                                          fontSize: _fontSize(11, width),
                                          color: isEnded
                                              ? AppColors.warning
                                              : AppColors.success,
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
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
