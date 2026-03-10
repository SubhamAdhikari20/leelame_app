// lib/features/buyer/presentation/pages/my_bids_page.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/app/theme/app_colors.dart';
import 'package:leelame/core/services/storage/user_session_service.dart';
import 'package:leelame/core/utils/snackbar_util.dart';
import 'package:leelame/features/bid/domain/entities/bid_entity.dart';
import 'package:leelame/features/bid/presentation/states/bid_state.dart';
import 'package:leelame/features/bid/presentation/view_models/bid_view_model.dart';
import 'package:leelame/features/product/domain/entities/product_entity.dart';
import 'package:leelame/features/product/presentation/pages/product_view_details_page.dart';
import 'package:leelame/features/product/presentation/states/product_state.dart';
import 'package:leelame/features/product/presentation/viewmodels/product_view_model.dart';

enum _MyBidStatus { winning, outbid, won, lost }

class _MyBidCardData {
  final ProductEntity product;
  final double myHighestBid;
  final int myTotalBids;
  final DateTime? myLastBidAt;
  final _MyBidStatus status;

  const _MyBidCardData({
    required this.product,
    required this.myHighestBid,
    required this.myTotalBids,
    required this.myLastBidAt,
    required this.status,
  });
}

class MyBidsScreen extends ConsumerStatefulWidget {
  const MyBidsScreen({super.key});

  @override
  ConsumerState<MyBidsScreen> createState() => _MyBidsScreenState();
}

class _MyBidsScreenState extends ConsumerState<MyBidsScreen> {
  String? _currentBuyerId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final buyerId = ref.read(userSessionServiceProvider).getUserId();
    if (buyerId == null) {
      if (!mounted) {
        return;
      }
      SnackbarUtil.showError(context, 'User session not found. Please log in.');
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _currentBuyerId = buyerId;
    });

    await Future.wait([
      ref.read(productViewModelProvider.notifier).getAllProducts(),
      ref.read(bidViewModelProvider.notifier).getAllBids(),
    ]);
  }

  String _formatAmount(double amount) => 'Rs. ${amount.toStringAsFixed(2)}';

  String _formatDateTime(DateTime? value) {
    if (value == null) {
      return 'N/A';
    }

    final local = value.toLocal();
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final month = months[local.month - 1];
    final day = local.day.toString().padLeft(2, '0');
    final year = local.year;

    final hour24 = local.hour;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = hour24 >= 12 ? 'PM' : 'AM';
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;

    return '$month $day, $year - ${hour12.toString().padLeft(2, '0')}:$minute $period';
  }

  String _timeLeft(DateTime endDate) {
    final now = DateTime.now();
    final difference = endDate.toLocal().difference(now);

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

  List<_MyBidCardData> _buildCardData({
    required List<BidEntity> allBids,
    required List<ProductEntity> products,
    required String buyerId,
  }) {
    final now = DateTime.now();
    const epsilon = 0.0001;
    final productMap = {
      for (final product in products) product.productId: product,
    };
    final allBidsByProduct = <String, List<BidEntity>>{};
    final myBidsByProduct = <String, List<BidEntity>>{};

    for (final bid in allBids) {
      final productId = bid.productId;
      if (productId == null) {
        continue;
      }
      allBidsByProduct.putIfAbsent(productId, () => []).add(bid);
      if (bid.buyerId == buyerId) {
        myBidsByProduct.putIfAbsent(productId, () => []).add(bid);
      }
    }

    final items = <_MyBidCardData>[];
    myBidsByProduct.forEach((productId, myProductBids) {
      final product = productMap[productId];
      if (product == null) {
        return;
      }

      final productAllBids = allBidsByProduct[productId] ?? const <BidEntity>[];

      final myHighestBid = myProductBids
          .map((bid) => bid.bidAmount)
          .fold<double>(0, (previous, amount) => max(previous, amount));

      final highestBidFromAllBids = productAllBids
          .map((bid) => bid.bidAmount)
          .fold<double>(0, (previous, amount) => max(previous, amount));
      final effectiveHighestBid = max(
        product.currentBidPrice,
        highestBidFromAllBids,
      );
      final isMyTopBid = (myHighestBid + epsilon) >= effectiveHighestBid;

      final lastBid =
          myProductBids
              .where((bid) => bid.updatedAt != null || bid.createdAt != null)
              .toList()
            ..sort((a, b) {
              final aTime = a.updatedAt ?? a.createdAt ?? DateTime(1970);
              final bTime = b.updatedAt ?? b.createdAt ?? DateTime(1970);
              return bTime.compareTo(aTime);
            });

      final lastBidAt = lastBid.isEmpty
          ? null
          : (lastBid.first.updatedAt ?? lastBid.first.createdAt);

      final isAuctionEnded =
          product.endDate.toLocal().isBefore(now) || product.isSoldOut;
      final isSoldToMe =
          product.soldToBuyerId != null && product.soldToBuyerId == buyerId;
      final isSoldToOther =
          product.soldToBuyerId != null && product.soldToBuyerId != buyerId;

      _MyBidStatus status;
      if (isSoldToMe || (isAuctionEnded && !isSoldToOther && isMyTopBid)) {
        status = _MyBidStatus.won;
      } else if (isAuctionEnded || isSoldToOther) {
        status = _MyBidStatus.lost;
      } else if (isMyTopBid) {
        status = _MyBidStatus.winning;
      } else {
        status = _MyBidStatus.outbid;
      }

      items.add(
        _MyBidCardData(
          product: product,
          myHighestBid: myHighestBid,
          myTotalBids: myProductBids.length,
          myLastBidAt: lastBidAt,
          status: status,
        ),
      );
    });

    items.sort((a, b) {
      final aIsActive =
          a.status == _MyBidStatus.winning || a.status == _MyBidStatus.outbid;
      final bIsActive =
          b.status == _MyBidStatus.winning || b.status == _MyBidStatus.outbid;

      if (aIsActive != bIsActive) {
        return aIsActive ? -1 : 1;
      }

      final aTime = a.myLastBidAt ?? DateTime(1970);
      final bTime = b.myLastBidAt ?? DateTime(1970);
      return bTime.compareTo(aTime);
    });

    return items;
  }

  void _openProductDetails(ProductEntity product) {
    final buyerId = _currentBuyerId;
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

    Navigator.of(context).push(
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
  }

  @override
  Widget build(BuildContext context) {
    final bidState = ref.watch(bidViewModelProvider);
    final productState = ref.watch(productViewModelProvider);

    ref.listen<BidState>(bidViewModelProvider, (previous, next) {
      if (next.bidStatus == BidStatus.error) {
        SnackbarUtil.showError(
          context,
          next.errorMessage ?? 'Failed to load your bids.',
        );
      }
    });

    ref.listen<ProductState>(productViewModelProvider, (previous, next) {
      if (next.productStatus == ProductStatus.error) {
        SnackbarUtil.showError(
          context,
          next.errorMessage ?? 'Failed to load products.',
        );
      }
    });

    final buyerId = _currentBuyerId;
    final cards = buyerId == null
        ? <_MyBidCardData>[]
        : _buildCardData(
            allBids: bidState.bids,
            products: productState.products,
            buyerId: buyerId,
          );

    final currentlyBiddingCards = cards
        .where(
          (card) =>
              card.status == _MyBidStatus.winning ||
              card.status == _MyBidStatus.outbid,
        )
        .toList();

    final wonCount = cards
        .where((card) => card.status == _MyBidStatus.won)
        .length;
    final winningCount = cards
        .where((card) => card.status == _MyBidStatus.winning)
        .length;

    final isLoading =
        bidState.bidStatus == BidStatus.loading ||
        productState.productStatus == ProductStatus.loading;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            children: [
              const Text(
                'My Bids',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Track your active bids and auction results.',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              _MyBidsSummaryCard(
                totalBids: cards.length,
                activeBids: currentlyBiddingCards.length,
                winningBids: winningCount,
                wonBids: wonCount,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Currently Bidding',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryColor,
                    ),
                  ),
                  Text(
                    '${currentlyBiddingCards.length}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (isLoading && cards.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 50),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (currentlyBiddingCards.isEmpty)
                _EmptyStateCard(
                  title: 'No active bids yet',
                  subtitle:
                      'Your active bid cards will appear here when you place bids.',
                )
              else
                ...currentlyBiddingCards.map(
                  (card) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _MyBidProductCard(
                      data: card,
                      timeLeftText: _timeLeft(card.product.endDate),
                      formatAmount: _formatAmount,
                      formatDateTime: _formatDateTime,
                      onTap: () => _openProductDetails(card.product),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              const Text(
                'All Bids',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 12),
              if (cards.isEmpty && !isLoading)
                _EmptyStateCard(
                  title: 'No bids found',
                  subtitle:
                      'When you place your first bid, it will show up here.',
                )
              else
                ...cards.map(
                  (card) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _MyBidProductCard(
                      data: card,
                      timeLeftText: _timeLeft(card.product.endDate),
                      formatAmount: _formatAmount,
                      formatDateTime: _formatDateTime,
                      onTap: () => _openProductDetails(card.product),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MyBidsSummaryCard extends StatelessWidget {
  const _MyBidsSummaryCard({
    required this.totalBids,
    required this.activeBids,
    required this.winningBids,
    required this.wonBids,
  });

  final int totalBids;
  final int activeBids;
  final int winningBids;
  final int wonBids;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.auctionPrimaryGradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bid Overview',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _SummaryMetric(label: 'Total', value: '$totalBids'),
              ),
              Expanded(
                child: _SummaryMetric(label: 'Active', value: '$activeBids'),
              ),
              Expanded(
                child: _SummaryMetric(label: 'Winning', value: '$winningBids'),
              ),
              Expanded(
                child: _SummaryMetric(label: 'Won', value: '$wonBids'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFEAFDE4),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _MyBidProductCard extends StatelessWidget {
  const _MyBidProductCard({
    required this.data,
    required this.timeLeftText,
    required this.formatAmount,
    required this.formatDateTime,
    required this.onTap,
  });

  final _MyBidCardData data;
  final String timeLeftText;
  final String Function(double amount) formatAmount;
  final String Function(DateTime? value) formatDateTime;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusStyle = _statusStyle(data.status);

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
                _ProductThumb(
                  imageUrl: data.product.productImageUrls.firstOrNull,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.product.productName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
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
                          color: statusStyle.background,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          statusStyle.label,
                          style: TextStyle(
                            color: statusStyle.foreground,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ValuePill(
                  label: 'Your highest bid',
                  value: formatAmount(data.myHighestBid),
                  icon: Icons.gavel_rounded,
                ),
                _ValuePill(
                  label: 'Current highest',
                  value: formatAmount(data.product.currentBidPrice),
                  icon: Icons.trending_up_rounded,
                ),
                _ValuePill(
                  label: 'Your total bids',
                  value: '${data.myTotalBids}',
                  icon: Icons.format_list_numbered_rounded,
                ),
              ],
            ),
            const SizedBox(height: 10),
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
                      color: Colors.grey.shade700,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  'Last bid: ${formatDateTime(data.myLastBidAt)}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
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
        width: 70,
        height: 70,
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
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7E8EE)),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 36, color: Colors.grey.shade400),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _StatusStyle {
  final String label;
  final Color background;
  final Color foreground;

  const _StatusStyle({
    required this.label,
    required this.background,
    required this.foreground,
  });
}

_StatusStyle _statusStyle(_MyBidStatus status) {
  switch (status) {
    case _MyBidStatus.winning:
      return const _StatusStyle(
        label: 'Winning',
        background: Color(0xFFE8F8EC),
        foreground: Color(0xFF1F8D39),
      );
    case _MyBidStatus.outbid:
      return const _StatusStyle(
        label: 'Outbid',
        background: Color(0xFFFFF2E6),
        foreground: Color(0xFFE67E22),
      );
    case _MyBidStatus.won:
      return const _StatusStyle(
        label: 'Won',
        background: Color(0xFFE8F8EC),
        foreground: Color(0xFF1F8D39),
      );
    case _MyBidStatus.lost:
      return const _StatusStyle(
        label: 'Lost',
        background: Color(0xFFFDEBEC),
        foreground: Color(0xFFCC3A3A),
      );
  }
}
