// lib/features/buyer/presentation/pages/watchlist_page.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/app/theme/app_colors.dart';
import 'package:leelame/core/services/storage/user_session_service.dart';
import 'package:leelame/core/services/storage/wishlist_service.dart';
import 'package:leelame/core/utils/snackbar_util.dart';
import 'package:leelame/features/bid/presentation/states/bid_state.dart';
import 'package:leelame/features/bid/presentation/view_models/bid_view_model.dart';
import 'package:leelame/features/product/domain/entities/product_entity.dart';
import 'package:leelame/features/product/presentation/pages/product_view_details_page.dart';
import 'package:leelame/features/product/presentation/states/product_state.dart';
import 'package:leelame/features/product/presentation/viewmodels/product_view_model.dart';
import 'package:sensors_plus/sensors_plus.dart';

class WatchlistScreen extends ConsumerStatefulWidget {
  const WatchlistScreen({super.key});

  @override
  ConsumerState<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends ConsumerState<WatchlistScreen> {
  String? _buyerId;
  Set<String> _watchlistedProductIds = <String>{};
  String _query = '';

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
      _loadData();
      _startShakeDetection();
    });
  }

  void _startShakeDetection() {
    if (_accelSubscription != null) {
      return;
    }

    _accelSubscription = accelerometerEventStream().listen((event) {
      final magnitude = sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      );

      if (magnitude > _shakeThreshold) {
        final now = DateTime.now();

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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Refreshing watchlist...'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );

    try {
      await _loadData();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Watchlist refreshed'),
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
          content: Text('Failed to refresh watchlist: ${e.toString()}'),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _accelSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    final buyerId = ref.read(userSessionServiceProvider).getUserId();
    if (buyerId == null) {
      SnackbarUtil.showError(context, 'User session not found. Please log in.');
      return;
    }

    final watchlistIds = ref
        .read(wishlistServiceProvider)
        .getWishlistProductIds(buyerId);

    if (mounted) {
      setState(() {
        _buyerId = buyerId;
        _watchlistedProductIds = watchlistIds;
      });
    }

    await Future.wait([
      ref.read(productViewModelProvider.notifier).getAllProducts(),
      ref.read(bidViewModelProvider.notifier).getAllBids(),
    ]);

    if (!mounted) {
      return;
    }

    // Re-sync after navigation/back or async writes from other pages.
    setState(() {
      _watchlistedProductIds = ref
          .read(wishlistServiceProvider)
          .getWishlistProductIds(buyerId);
    });
  }

  Future<void> _removeFromWatchlist(ProductEntity product) async {
    final buyerId = _buyerId;
    final productId = product.productId;
    if (buyerId == null || productId == null) {
      return;
    }

    await ref
        .read(wishlistServiceProvider)
        .toggleWishlist(
          userId: buyerId,
          productId: productId,
          shouldBeFavorite: false,
        );

    if (!mounted) {
      return;
    }

    setState(() {
      _watchlistedProductIds.remove(productId);
    });

    SnackbarUtil.showSuccess(context, 'Removed from watchlist');
  }

  Future<void> _openProductDetails(ProductEntity product) async {
    final buyerId = _buyerId;
    if (buyerId == null) {
      SnackbarUtil.showError(context, 'User session not found. Please log in.');
      return;
    }

    if (product.productId == null ||
        product.categoryId == null ||
        product.conditionId == null ||
        product.sellerId == null) {
      SnackbarUtil.showError(context, 'Product details are incomplete.');
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductViewDetailsPage(
          productId: product.productId!,
          categoryId: product.categoryId!,
          productConditionId: product.conditionId!,
          sellerId: product.sellerId!,
          currentUserId: buyerId,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _watchlistedProductIds = ref
          .read(wishlistServiceProvider)
          .getWishlistProductIds(buyerId);
    });
  }

  String _formatAmount(double amount) => 'Rs. ${amount.toStringAsFixed(2)}';

  String _timeLeft(DateTime endDate) {
    final difference = endDate.toLocal().difference(DateTime.now());

    if (difference.isNegative) {
      return 'Auction ended';
    }
    if (difference.inDays > 0) {
      return '${difference.inDays}d ${difference.inHours % 24}h left';
    }
    if (difference.inHours > 0) {
      return '${difference.inHours}h ${difference.inMinutes % 60}m left';
    }
    return '${difference.inMinutes}m left';
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productViewModelProvider);
    final bidState = ref.watch(bidViewModelProvider);

    ref.listen<ProductState>(productViewModelProvider, (previous, next) {
      if (next.productStatus == ProductStatus.error &&
          previous?.productStatus != ProductStatus.error) {
        SnackbarUtil.showError(
          context,
          next.errorMessage ?? 'Failed to load watchlist products.',
        );
      }
    });

    ref.listen<BidState>(bidViewModelProvider, (previous, next) {
      if (next.bidStatus == BidStatus.error &&
          previous?.bidStatus != BidStatus.error) {
        SnackbarUtil.showError(
          context,
          next.errorMessage ?? 'Failed to load bid details.',
        );
      }
    });

    final allWatchlistedProducts =
        productState.products
            .where(
              (product) =>
                  product.productId != null &&
                  _watchlistedProductIds.contains(product.productId),
            )
            .toList()
          ..sort((a, b) {
            final aEnded =
                a.endDate.toLocal().isBefore(DateTime.now()) || a.isSoldOut;
            final bEnded =
                b.endDate.toLocal().isBefore(DateTime.now()) || b.isSoldOut;
            if (aEnded != bEnded) {
              return aEnded ? 1 : -1;
            }
            return a.endDate.compareTo(b.endDate);
          });

    final filteredProducts = _query.trim().isEmpty
        ? allWatchlistedProducts
        : allWatchlistedProducts.where((product) {
            final q = _query.toLowerCase();
            return product.productName.toLowerCase().contains(q) ||
                (product.description?.toLowerCase().contains(q) ?? false);
          }).toList();

    final activeCount = allWatchlistedProducts
        .where(
          (p) => !p.isSoldOut && p.endDate.toLocal().isAfter(DateTime.now()),
        )
        .length;

    final endingSoonCount = allWatchlistedProducts.where((p) {
      final remaining = p.endDate.toLocal().difference(DateTime.now());
      return !p.isSoldOut &&
          !remaining.isNegative &&
          remaining <= const Duration(hours: 24);
    }).length;

    final isLoading =
        productState.productStatus == ProductStatus.loading &&
        productState.products.isEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth >= 700;
              final horizontalPadding = isTablet ? 28.0 : 16.0;
              final titleSize = isTablet ? 34.0 : 28.0;

              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        14,
                        horizontalPadding,
                        8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Watchlist',
                            style: TextStyle(
                              fontFamily: 'OpenSans ExtraBold',
                              fontSize: titleSize,
                              color: AppColors.textPrimaryColor,
                              height: 1.05,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Keep track of favorites and jump into bids quickly.',
                            style: TextStyle(
                              fontFamily: 'OpenSans Medium',
                              color: AppColors.textSecondaryColor,
                              fontSize: isTablet ? 15 : 13.5,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _WatchlistSummaryCard(
                            total: allWatchlistedProducts.length,
                            active: activeCount,
                            endingSoon: endingSoonCount,
                          ),
                          const SizedBox(height: 14),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFE7E8EE),
                              ),
                            ),
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  _query = value;
                                });
                              },
                              style: const TextStyle(
                                fontFamily: 'OpenSans Medium',
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Search watchlist products...',
                                hintStyle: TextStyle(
                                  fontFamily: 'OpenSans Regular',
                                  color: AppColors.textSecondaryColor,
                                ),
                                prefixIcon: Icon(Icons.search_rounded),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isLoading)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (filteredProducts.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          18,
                          horizontalPadding,
                          18,
                        ),
                        child: _EmptyWatchlistCard(
                          title: allWatchlistedProducts.isEmpty
                              ? 'Your watchlist is empty'
                              : 'No match found',
                          subtitle: allWatchlistedProducts.isEmpty
                              ? 'Tap the heart icon on products to add items here.'
                              : 'Try a different search term to find your item.',
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        10,
                        horizontalPadding,
                        20,
                      ),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final product = filteredProducts[index];
                          final totalBids = bidState.bids
                              .where(
                                (bid) => bid.productId == product.productId,
                              )
                              .length;
                          return _WatchlistProductCard(
                            product: product,
                            totalBids: totalBids,
                            formatAmount: _formatAmount,
                            timeLeftText: _timeLeft(product.endDate),
                            onTap: () => _openProductDetails(product),
                            onRemove: () => _removeFromWatchlist(product),
                          );
                        }, childCount: filteredProducts.length),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isTablet ? 2 : 1,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: isTablet ? 1.34 : 1.42,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _WatchlistSummaryCard extends StatelessWidget {
  const _WatchlistSummaryCard({
    required this.total,
    required this.active,
    required this.endingSoon,
  });

  final int total;
  final int active;
  final int endingSoon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1C9C77), Color(0xFF146B7D)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2424666B),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _MetricItem(label: 'Total', value: '$total'),
          ),
          Expanded(
            child: _MetricItem(label: 'Active', value: '$active'),
          ),
          Expanded(
            child: _MetricItem(label: 'Ending Soon', value: '$endingSoon'),
          ),
        ],
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  const _MetricItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'OpenSans ExtraBold',
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'OpenSans SemiBold',
            color: AppColors.white80,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _WatchlistProductCard extends StatelessWidget {
  const _WatchlistProductCard({
    required this.product,
    required this.totalBids,
    required this.formatAmount,
    required this.timeLeftText,
    required this.onTap,
    required this.onRemove,
  });

  final ProductEntity product;
  final int totalBids;
  final String Function(double amount) formatAmount;
  final String timeLeftText;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final isEnded =
        product.endDate.toLocal().isBefore(DateTime.now()) || product.isSoldOut;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE7E8EE)),
          boxShadow: AppColors.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProductThumb(imageUrl: product.productImageUrls.firstOrNull),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.productName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'OpenSans Bold',
                          fontSize: 15,
                          color: AppColors.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: isEnded
                              ? const Color(0xFFFDEBEC)
                              : const Color(0xFFE8F8EC),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          isEnded ? 'Auction Ended' : 'Active Auction',
                          style: TextStyle(
                            fontFamily: 'OpenSans SemiBold',
                            fontSize: 11.5,
                            color: isEnded
                                ? const Color(0xFFCC3A3A)
                                : const Color(0xFF1F8D39),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onRemove,
                  tooltip: 'Remove from watchlist',
                  icon: const Icon(
                    Icons.favorite_rounded,
                    color: Color(0xFFE5484D),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ValuePill(
                  label: 'Current Bid',
                  value: formatAmount(product.currentBidPrice),
                  icon: Icons.trending_up_rounded,
                ),
                _ValuePill(
                  label: 'Bid Step',
                  value: formatAmount(product.bidIntervalPrice),
                  icon: Icons.add_chart_rounded,
                ),
                _ValuePill(
                  label: 'Total Bids',
                  value: '$totalBids',
                  icon: Icons.gavel_rounded,
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    timeLeftText,
                    style: TextStyle(
                      fontFamily: 'OpenSans SemiBold',
                      color: Colors.grey.shade700,
                      fontSize: 12.8,
                    ),
                  ),
                ),
                Text(
                  'Tap to view',
                  style: TextStyle(
                    fontFamily: 'OpenSans Medium',
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductThumb extends StatelessWidget {
  const _ProductThumb({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 74,
        height: 74,
        color: const Color(0xFFF2F3F7),
        child: imageUrl == null || imageUrl!.isEmpty
            ? Icon(
                Icons.image_not_supported_outlined,
                color: Colors.grey.shade500,
              )
            : Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Icon(
                  Icons.broken_image_outlined,
                  color: Colors.grey.shade500,
                ),
              ),
      ),
    );
  }
}

class _ValuePill extends StatelessWidget {
  const _ValuePill({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7FB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondaryColor),
          const SizedBox(width: 5),
          Text(
            '$label: $value',
            style: const TextStyle(
              fontFamily: 'OpenSans SemiBold',
              fontSize: 12,
              color: AppColors.textPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyWatchlistCard extends StatelessWidget {
  const _EmptyWatchlistCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7E8EE)),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFFFDADA), Color(0xFFFFE9E2)],
              ),
            ),
            child: const Icon(
              Icons.favorite_outline_rounded,
              color: Color(0xFFE65353),
              size: 30,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'OpenSans Bold',
              fontSize: 16,
              color: AppColors.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'OpenSans Regular',
              color: AppColors.textSecondaryColor,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
