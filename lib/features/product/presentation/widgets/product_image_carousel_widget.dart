// lib/features/product/presentation/widgets/bid_history_tile_widget.dart
import 'package:flutter/material.dart';

// Custom Image Carousel
class ProductImageCarousel extends StatelessWidget {
  const ProductImageCarousel({
    super.key,
    required this.imageUrls,
    required this.height,
    required this.pageController,
    required this.currentIndex,
    required this.onPageChanged,
    this.favoriteWidget,
  });

  final List<String> imageUrls;
  final double height;
  final PageController pageController;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;
  final Widget? favoriteWidget;

  @override
  Widget build(BuildContext context) {
    final images = imageUrls.isNotEmpty ? imageUrls : <String>[];
    final total = images.length;

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          // PageView
          PageView.builder(
            controller: pageController,
            itemCount: total == 0 ? 1 : total,
            onPageChanged: onPageChanged,
            itemBuilder: (_, index) {
              if (total == 0) {
                return _imagePlaceholder();
              }
              return Image.network(
                images[index],
                width: double.infinity,
                height: height,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : Container(
                        color: Colors.grey.shade100,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                errorBuilder: (_, _, _) => _imagePlaceholder(),
              );
            },
          ),

          // Counter badge
          if (total > 1)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${currentIndex + 1} / $total',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

          // Favourite button
          Positioned(
            top: 12,
            left: 12,
            child: Material(color: Colors.transparent, child: favoriteWidget),
          ),

          // Dot indicators
          if (total > 1)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(total, (i) {
                  final active = i == currentIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 20 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: active
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),

          // Left arrow
          if (total > 1 && currentIndex > 0)
            Positioned(
              left: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: _CarouselArrow(
                  icon: Icons.chevron_left,
                  onTap: () => pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                ),
              ),
            ),

          // Right arrow
          if (total > 1 && currentIndex < total - 1)
            Positioned(
              right: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: _CarouselArrow(
                  icon: Icons.chevron_right,
                  onTap: () => pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: Colors.grey.shade100,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 64,
          color: Colors.grey.shade300,
        ),
      ),
    );
  }
}

class _CarouselArrow extends StatelessWidget {
  const _CarouselArrow({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 22, color: Colors.black87),
      ),
    );
  }
}
