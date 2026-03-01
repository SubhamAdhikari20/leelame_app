// lib/features/products/presentation/widgets/product_card.dart
import 'package:flutter/material.dart';
import 'package:gradient_elevated_button/gradient_elevated_button.dart';
import 'package:leelame/features/bid/presentation/models/bid_ui_model.dart';
import 'package:leelame/features/buyer/presentation/models/buyer_ui_model.dart';
import 'package:leelame/features/category/presentation/models/category_ui_model.dart';
import 'package:leelame/features/product/presentation/models/product_ui_model.dart';
import 'package:leelame/features/product/presentation/widgets/favorite_button_widget.dart';
import 'package:leelame/features/product/presentation/widgets/small_tag_widget.dart';
import 'package:leelame/features/product_condition/presentation/models/product_condition_ui_model.dart';
import 'package:leelame/features/seller/presentation/models/seller_ui_model.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.category,
    required this.productCondition,
    required this.seller,
    this.bid = const [],
    this.buyer,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteToggle,
    required this.onPlaceBid,
  });

  final ProductUiModel product;
  final CategoryUiModel category;
  final ProductConditionUiModel productCondition;
  final SellerUiModel seller;
  final List<BidUiModel> bid;
  final BuyerUiModel? buyer;
  final bool isFavorite;
  final VoidCallback onTap;
  final ValueChanged<bool> onFavoriteToggle;
  final VoidCallback onPlaceBid;

  Color getTagColor(String label) {
    switch (label.toLowerCase()) {
      case 'electronics':
        return Colors.blue;
      case 'refurbished':
      case 'used once':
        return Colors.green;
      case 'fashion':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  List<String> get tags => [
    category.categoryName,
    productCondition.productConditionName,
  ];

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
    final format = amount.toStringAsFixed(2);
    return "Rs. $format";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.cardColor,
      elevation: 2,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with tag pills and favorite overlay
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: product.productImageUrls.isNotEmpty
                          ? Image.network(
                              product.productImageUrls.first,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) {
                                      return child;
                                    }
                                    return Container(
                                      color: Colors.grey.shade200,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.shade200,
                                  child: Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      size: 36,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              },
                            )
                          : Image.asset(
                              'assets/images/placeholder.png',
                              fit: BoxFit.cover,
                            ),
                    ),

                    // Top-left tags (inside white space with slight shadow)
                    // Positioned(
                    //   left: 12,
                    //   top: 12,
                    //   child: Row(
                    //     children: tags.map((t) => SmallTag(label: t)).toList(),
                    //   ),
                    // ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Wrap(
                        spacing: 6,
                        children: tags
                            .map(
                              (tag) => SmallTagWidget(
                                label: tag,
                                color: getTagColor(tag),
                              ),
                            )
                            .toList(),
                      ),
                    ),

                    // favorite
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Material(
                        color: Colors.transparent,
                        child: FavoriteButtonWidget(
                          onFavoriteToggle: onFavoriteToggle,
                          isFavorite: isFavorite,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name and
                    Text(
                      product.productName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6),
                    product.description != null
                        ? Text(
                            product.description!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          )
                        : SizedBox.shrink(),
                    SizedBox(height: 12),

                    // Current bid, timer and bids
                    Row(
                      children: [
                        // left: label + price
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current Bid',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                _formatAmount(product.currentBidPrice),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // right: timer and bid count
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_outlined,
                                  size: 16,
                                  color: Colors.purple,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  _calculateTimeLeft(product.endDate),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.purple,
                                  ),
                                ),
                                // Text(
                                //   product.endDate
                                //               .difference(DateTime.now())
                                //               .inHours >
                                //           0
                                //       ? '${product.endDate.difference(DateTime.now()).inHours}h left'
                                //       : 'Ending soon',
                                //   style: TextStyle(
                                //     fontSize: 13,
                                //     color: Colors.purple,
                                //   ),
                                // ),
                              ],
                            ),
                            SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.gavel_outlined,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  "${bid.length} bids",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 12),

                    // owner + place bid button
                    Row(
                      children: [
                        // owner avatar + name
                        CircleAvatar(
                          radius: 18,
                          backgroundImage: seller.profilePictureUrl != null
                              ? NetworkImage(seller.profilePictureUrl!)
                              : null,
                          backgroundColor: Colors.grey.shade200,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            seller.fullName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        // Place Bid button
                        GradientElevatedButton(
                          onPressed: onPlaceBid,
                          style: GradientElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundGradient: LinearGradient(
                              colors: [Color(0xFF9831E0), Color(0xFFCF2988)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            // backgroundColor: Colors.purple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 20),
                          ),
                          child: Text(
                            'Place Bid',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
