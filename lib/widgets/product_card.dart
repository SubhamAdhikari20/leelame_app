// lib/widgets/product_card.dart
import 'package:flutter/material.dart';
import 'package:gradient_elevated_button/gradient_elevated_button.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.tags,
    required this.imageAsset,
    required this.title,
    required this.location,
    required this.price,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onTap,
    required this.onPlaceBid,
    required this.timeLeft,
    required this.bidCount,
    required this.ownerName,
    required this.ownerAvatar,
  });

  final List<String> tags;
  final String imageAsset;
  final String title;
  final String location;
  final String price;
  final bool isFavorite;
  final ValueChanged<bool> onFavoriteToggle;
  final VoidCallback onTap;
  final VoidCallback onPlaceBid;
  final String timeLeft;
  final int bidCount;
  final String ownerName;
  final String ownerAvatar;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.cardColor,
      elevation: 2,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(14),
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
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.network(
                        imageAsset,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }
                          return Container(
                            color: Colors.grey.shade200,
                            child: Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
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
                              (tag) =>
                                  SmallTag(label: tag, color: getTagColor(tag)),
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
                        child: InkWell(
                          onTap: () => onFavoriteToggle(!isFavorite),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.scaffoldBackgroundColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite
                                  ? Colors.redAccent
                                  : Colors.grey.shade800,
                              size: 22,
                            ),
                          ),
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
                    // Title and location
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      location,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
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
                                price,
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
                                  timeLeft,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.purple,
                                  ),
                                ),
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
                                  '$bidCount bids',
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
                          backgroundImage: ownerAvatar.isNotEmpty
                              ? NetworkImage(ownerAvatar)
                              : null,
                          backgroundColor: Colors.grey.shade200,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            ownerName,
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
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          child: Text(
                            'Place Bid',
                            style: TextStyle(color: Colors.white),
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

class SmallTag extends StatelessWidget {
  const SmallTag({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontFamily: "OpenSans Medium",
        ),
      ),
    );
  }
}
