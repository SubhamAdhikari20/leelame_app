// lib/features/products/presentation/widgets/favorite_button_widget.dart
import 'package:flutter/material.dart';

class FavoriteButtonWidget extends StatelessWidget {
  const FavoriteButtonWidget({
    super.key,
    required this.onFavoriteToggle,
    required this.isFavorite,
    this.size,
  });

  final ValueChanged<bool> onFavoriteToggle;
  final bool isFavorite;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onFavoriteToggle(isFavorite),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
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
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? Colors.redAccent : Colors.grey.shade800,
          size: size ?? 22,
        ),
      ),
    );
  }
}
