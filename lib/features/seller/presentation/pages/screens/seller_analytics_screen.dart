// lib/features/seller/presentation/pages/screens/seller_analytics_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/app/theme/app_colors.dart';
import 'package:leelame/core/services/proximity_service.dart';
import 'package:leelame/core/services/storage/user_session_service.dart';
import 'package:leelame/core/utils/snackbar_util.dart';
import 'package:leelame/features/product/domain/entities/product_entity.dart';
import 'package:leelame/features/product/presentation/states/product_state.dart';
import 'package:leelame/features/product/presentation/viewmodels/product_view_model.dart';
import 'package:leelame/features/seller/presentation/states/seller_state.dart';
import 'package:leelame/features/seller/presentation/view_models/seller_view_model.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SellerAnalyticsScreen extends ConsumerStatefulWidget {
  const SellerAnalyticsScreen({super.key});

  @override
  ConsumerState<SellerAnalyticsScreen> createState() =>
      _SellerAnalyticsScreenState();
}

enum _AnalyticsRange { weekly, monthly, allTime }

class _SellerAnalyticsScreenState extends ConsumerState<SellerAnalyticsScreen> {
  final ProximitySensorService _proximitySvc = ProximitySensorService();

  String? _sellerId;
  _AnalyticsRange _selectedRange = _AnalyticsRange.monthly;
  StreamSubscription<AccelerometerEvent>? _accelSub;
  DateTime? _lastShake;
  int _shakeCount = 0;

  @override
  void initState() {
    super.initState();
    _proximitySvc.start();
    _proximitySvc.isPrivacyMode.addListener(_onPrivacyModeChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sellerId = ref.read(userSessionServiceProvider).getUserId();
      _refreshAnalytics();
      _startShakeDetection();
    });
  }

  @override
  void dispose() {
    _proximitySvc.isPrivacyMode.removeListener(_onPrivacyModeChanged);
    _proximitySvc.dispose();
    _accelSub?.cancel();
    super.dispose();
  }

  void _onPrivacyModeChanged() {
    if (!mounted) return;
    setState(() {});
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
        _refreshAnalytics();
        if (mounted) {
          SnackbarUtil.showSuccess(context, 'Analytics refreshed');
        }
      }
    });
  }

  Future<void> _refreshAnalytics() async {
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

  List<ProductEntity> _productsForRange(List<ProductEntity> all) {
    if (_selectedRange == _AnalyticsRange.allTime) return all;

    final now = DateTime.now();
    final days = _selectedRange == _AnalyticsRange.weekly ? 7 : 30;
    final threshold = now.subtract(Duration(days: days));

    return all.where((p) => p.endDate.isAfter(threshold)).toList();
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required IconData icon,
    required Color accent,
    required bool isPrivate,
    required bool isSensitive,
    required double width,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'OpenSans Medium',
                    fontSize: _fontSize(12, width),
                    color: AppColors.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 3),
                PrivacyText(
                  value,
                  isPrivate: isPrivate && isSensitive,
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
          next.errorMessage ?? 'Unable to load seller details.',
        );
      }
    });

    ref.listen<ProductState>(productViewModelProvider, (_, next) {
      if (next.productStatus == ProductStatus.error && mounted) {
        SnackbarUtil.showError(
          context,
          next.errorMessage ?? 'Unable to load analytics data.',
        );
      }
    });

    final width = MediaQuery.of(context).size.width;
    final isTablet = width >= 700;
    final isPrivate = _proximitySvc.isPrivacyMode.value;

    final allProducts = productState.products
        .where((p) => _sellerId == null || p.sellerId == _sellerId)
        .toList();
    final scoped = _productsForRange(allProducts);

    final sold = scoped.where((p) => p.isSoldOut).length;
    final verified = scoped.where((p) => p.isVerified).length;
    final active = scoped
        .where((p) => !p.endDate.isBefore(DateTime.now()) && !p.isSoldOut)
        .length;
    final endingSoon = scoped
        .where(
          (p) =>
              !p.endDate.isBefore(DateTime.now()) &&
              p.endDate.difference(DateTime.now()) <= const Duration(hours: 24),
        )
        .length;

    final grossRevenue = scoped.fold<double>(
      0,
      (sum, p) => sum + p.currentBidPrice,
    );
    final estimatedNet = scoped.fold<double>(
      0,
      (sum, p) => sum + (p.currentBidPrice * (1 - p.commission)),
    );
    final averageBid = scoped.isEmpty ? 0.0 : grossRevenue / scoped.length;
    final conversionRate = scoped.isEmpty ? 0.0 : (sold / scoped.length) * 100;

    final topGainers = [...scoped]
      ..sort(
        (a, b) => (b.currentBidPrice - b.startPrice).compareTo(
          a.currentBidPrice - a.startPrice,
        ),
      );

    final displayTop = topGainers.take(4).toList();
    final maxGain = displayTop.isEmpty
        ? 1.0
        : displayTop
              .map((p) => max(0.0, p.currentBidPrice - p.startPrice))
              .reduce(max)
              .clamp(1.0, double.infinity);

    final sellerName = sellerState.seller?.fullName ?? 'Seller';

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryButtonColor,
          onRefresh: _refreshAnalytics,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    isTablet ? 30 : 16,
                    16,
                    isTablet ? 30 : 16,
                    12,
                  ),
                  child: Container(
                    padding: EdgeInsets.all(isTablet ? 24 : 18),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: AppColors.elevatedShadow,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$sellerName Analytics',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'OpenSans Bold',
                                  fontSize: _fontSize(20, width),
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Track sales momentum, product performance, and conversion trends.',
                                style: TextStyle(
                                  fontFamily: 'OpenSans Regular',
                                  fontSize: _fontSize(13, width),
                                  color: AppColors.white90,
                                  height: 1.35,
                                ),
                              ),
                              if (isPrivate)
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.white20,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'Privacy Mode Active',
                                      style: TextStyle(
                                        fontFamily: 'OpenSans SemiBold',
                                        fontSize: _fontSize(11, width),
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: _refreshAnalytics,
                          icon: const Icon(
                            Icons.refresh_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 30 : 16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final range in _AnalyticsRange.values)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(
                                switch (range) {
                                  _AnalyticsRange.weekly => 'Last 7 Days',
                                  _AnalyticsRange.monthly => 'Last 30 Days',
                                  _AnalyticsRange.allTime => 'All Time',
                                },
                                style: TextStyle(
                                  fontFamily: 'OpenSans SemiBold',
                                  fontSize: _fontSize(12, width),
                                  color: _selectedRange == range
                                      ? Colors.white
                                      : AppColors.textPrimaryColor,
                                ),
                              ),
                              selected: _selectedRange == range,
                              selectedColor: AppColors.primaryButtonColor,
                              backgroundColor: Colors.white,
                              side: BorderSide(color: AppColors.borderColor),
                              onSelected: (_) {
                                setState(() {
                                  _selectedRange = range;
                                });
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  isTablet ? 30 : 16,
                  12,
                  isTablet ? 30 : 16,
                  0,
                ),
                sliver: SliverGrid(
                  delegate: SliverChildListDelegate([
                    _buildMetricCard(
                      label: 'Gross Revenue',
                      value: 'Rs ${_formatAmount(grossRevenue)}',
                      icon: Icons.monetization_on_rounded,
                      accent: AppColors.success,
                      isPrivate: isPrivate,
                      isSensitive: true,
                      width: width,
                    ),
                    _buildMetricCard(
                      label: 'Estimated Net',
                      value: 'Rs ${_formatAmount(estimatedNet)}',
                      icon: Icons.account_balance_wallet_rounded,
                      accent: AppColors.info,
                      isPrivate: isPrivate,
                      isSensitive: true,
                      width: width,
                    ),
                    _buildMetricCard(
                      label: 'Sold Items',
                      value: '$sold',
                      icon: Icons.sell_rounded,
                      accent: AppColors.warning,
                      isPrivate: isPrivate,
                      isSensitive: true,
                      width: width,
                    ),
                    _buildMetricCard(
                      label: 'Conversion',
                      value: '${conversionRate.toStringAsFixed(1)}%',
                      icon: Icons.percent_rounded,
                      accent: AppColors.primaryButtonColor,
                      isPrivate: isPrivate,
                      isSensitive: true,
                      width: width,
                    ),
                  ]),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isTablet ? 4 : 2,
                    childAspectRatio: isTablet ? 2.7 : 1.5,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    isTablet ? 30 : 16,
                    18,
                    isTablet ? 30 : 16,
                    0,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.borderColor),
                      boxShadow: AppColors.softShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pipeline Snapshot',
                          style: TextStyle(
                            fontFamily: 'OpenSans Bold',
                            fontSize: _fontSize(16, width),
                            color: AppColors.textPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildMetricCard(
                                label: 'Active',
                                value: '$active',
                                icon: Icons.flash_on_rounded,
                                accent: AppColors.success,
                                isPrivate: isPrivate,
                                isSensitive: true,
                                width: width,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildMetricCard(
                                label: 'Ending Soon',
                                value: '$endingSoon',
                                icon: Icons.timer_rounded,
                                accent: AppColors.warning,
                                isPrivate: isPrivate,
                                isSensitive: true,
                                width: width,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildMetricCard(
                                label: 'Verified',
                                value: '$verified',
                                icon: Icons.verified_rounded,
                                accent: AppColors.info,
                                isPrivate: isPrivate,
                                isSensitive: false,
                                width: width,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        PrivacyText(
                          'Average Current Bid: Rs ${_formatAmount(averageBid)}',
                          isPrivate: isPrivate,
                          style: TextStyle(
                            fontFamily: 'OpenSans SemiBold',
                            fontSize: _fontSize(13, width),
                            color: AppColors.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    isTablet ? 30 : 16,
                    18,
                    isTablet ? 30 : 16,
                    10,
                  ),
                  child: Text(
                    'Top Performing Auctions',
                    style: TextStyle(
                      fontFamily: 'OpenSans Bold',
                      fontSize: _fontSize(17, width),
                      color: AppColors.textPrimaryColor,
                    ),
                  ),
                ),
              ),
              if (productState.productStatus == ProductStatus.loading &&
                  scoped.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (displayTop.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'No product analytics data available for the selected range.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'OpenSans SemiBold',
                          fontSize: _fontSize(14, width),
                          color: AppColors.textSecondaryColor,
                        ),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    isTablet ? 30 : 16,
                    0,
                    isTablet ? 30 : 16,
                    20,
                  ),
                  sliver: SliverList.builder(
                    itemCount: displayTop.length,
                    itemBuilder: (context, index) {
                      final product = displayTop[index];
                      final gain = max(
                        0.0,
                        product.currentBidPrice - product.startPrice,
                      );
                      final progress = (gain / maxGain).clamp(0.08, 1.0);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderColor),
                          boxShadow: AppColors.softShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    product.productName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'OpenSans Bold',
                                      fontSize: _fontSize(14, width),
                                      color: AppColors.textPrimaryColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                PrivacyText(
                                  '+Rs ${_formatAmount(gain)}',
                                  isPrivate: isPrivate,
                                  style: TextStyle(
                                    fontFamily: 'OpenSans SemiBold',
                                    fontSize: _fontSize(12, width),
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 8,
                                color: AppColors.primaryButtonColor,
                                backgroundColor: AppColors.surfaceVariantColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Start: Rs ${_formatAmount(product.startPrice)}',
                                  style: TextStyle(
                                    fontFamily: 'OpenSans Regular',
                                    fontSize: _fontSize(11.5, width),
                                    color: AppColors.textSecondaryColor,
                                  ),
                                ),
                                PrivacyText(
                                  'Current: Rs ${_formatAmount(product.currentBidPrice)}',
                                  isPrivate: isPrivate,
                                  style: TextStyle(
                                    fontFamily: 'OpenSans SemiBold',
                                    fontSize: _fontSize(11.5, width),
                                    color: AppColors.textPrimaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
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
