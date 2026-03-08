// lib/features/product/presentation/widgets/bid_history_tile_widget.dart
// Bid History Tile
import 'package:flutter/material.dart';
import 'package:leelame/app/theme/app_colors.dart';
import 'package:leelame/features/bid/presentation/models/bid_ui_model.dart';
import 'package:leelame/features/buyer/presentation/models/buyer_ui_model.dart';
import 'package:leelame/features/product/presentation/models/product_ui_model.dart';
import 'package:leelame/features/product/presentation/widgets/time_ago_widget.dart';

class BidHistoryTile extends StatelessWidget {
  const BidHistoryTile({
    super.key,
    required this.buyer,
    required this.bid,
    required this.product,
    this.isHighest = false,
  });

  final BuyerUiModel buyer;
  final BidUiModel bid;
  final ProductUiModel product;
  final bool isHighest;

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
