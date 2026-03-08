import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/app/theme/app_colors.dart';
import 'package:leelame/core/services/storage/user_session_service.dart';
import 'package:leelame/core/utils/snackbar_util.dart';
import 'package:leelame/features/product/presentation/models/product_ui_model.dart';
import 'package:leelame/features/product/presentation/pages/add_new_product_page.dart';
import 'package:leelame/features/product/presentation/pages/update_product_details_page.dart';
import 'package:leelame/features/product/presentation/states/product_state.dart';
import 'package:leelame/features/product/presentation/viewmodels/product_view_model.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SellerMyProductsScreen extends ConsumerStatefulWidget {
  const SellerMyProductsScreen({super.key});

  @override
  ConsumerState<SellerMyProductsScreen> createState() =>
      _SellerMyProductsScreenState();
}

class _SellerMyProductsScreenState extends ConsumerState<SellerMyProductsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  StreamSubscription<AccelerometerEvent>? _accelSub;
  DateTime? _lastShake;
  int _shakeCount = 0;

  String _searchQuery = '';
  bool _isGridView = true;
  String? _sellerId;

  static const _tabs = ['All', 'Active', 'Ended'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _searchController.addListener(
      () => setState(() => _searchQuery = _searchController.text.toLowerCase()),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sellerId = ref.read(userSessionServiceProvider).getUserId();
      _loadProducts();
      _startShake();
    });
  }

  void _loadProducts() {
    if (_sellerId == null) return;
    ref
        .read(productViewModelProvider.notifier)
        .getAllProductsBySellerId(_sellerId!);
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
          _loadProducts();
          if (mounted) SnackbarUtil.showSuccess(context, 'Products refreshed');
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _accelSub?.cancel();
    super.dispose();
  }

  List<ProductUiModel> _filtered(List<dynamic> raw, int tabIndex) {
    final all = raw
        .map((p) => ProductUiModel.fromEntity(p))
        .where(
          (p) =>
              p.sellerId == _sellerId &&
              p.productName.toLowerCase().contains(_searchQuery),
        )
        .toList();

    if (tabIndex == 1) {
      return all
          .where((p) => !p.endDate.difference(DateTime.now()).isNegative)
          .toList();
    }
    if (tabIndex == 2) {
      return all
          .where((p) => p.endDate.difference(DateTime.now()).isNegative)
          .toList();
    }
    return all;
  }

  void _confirmDelete(ProductUiModel product) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _DeleteConfirmDialog(
        productName: product.productName,
        onConfirm: () => ref
            .read(productViewModelProvider.notifier)
            .deleteProduct(productId: product.productId!),
      ),
    );
  }

  void _goToEdit(ProductUiModel product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UpdateProductPage(
          categoryId: product.categoryId ?? '',
          productConditionId: product.conditionId ?? '',
          productId: product.productId ?? "",
          sellerId: _sellerId ?? '',
        ),
      ),
    ).then((_) => _loadProducts());
  }

  void _goToDetail(ProductUiModel product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UpdateProductPage(
          productId: product.productId ?? "",
          categoryId: product.categoryId ?? '',
          productConditionId: product.conditionId ?? '',
          sellerId: _sellerId ?? '',
        ),
      ),
    ).then((_) => _loadProducts());
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productViewModelProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final hPad = isTablet ? screenWidth * 0.04 : 16.0;

    ref.listen<ProductState>(productViewModelProvider, (_, next) {
      if (next.productStatus == ProductStatus.error) {
        SnackbarUtil.showError(
          context,
          next.errorMessage ?? 'Something went wrong.',
        );
      } else if (next.productStatus == ProductStatus.deleted) {
        SnackbarUtil.showSuccess(context, 'Product deleted successfully.');
        _loadProducts();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(isTablet: isTablet, hPad: hPad),
            _buildSearchBar(isTablet: isTablet, hPad: hPad),
            _buildTabStrip(isTablet: isTablet),
            Expanded(
              child:
                  productState.productStatus == ProductStatus.loading &&
                      (productState.products.isEmpty)
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: List.generate(_tabs.length, (i) {
                        final products = _filtered(productState.products, i);
                        if (products.isEmpty) {
                          return _EmptyState(
                            isTablet: isTablet,
                            onAdd: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddNewProductPage(
                                  sellerId: _sellerId ?? '',
                                ),
                              ),
                            ).then((_) => _loadProducts()),
                          );
                        }
                        return RefreshIndicator(
                          onRefresh: () async => _loadProducts(),
                          child: _isGridView
                              ? _ProductGrid(
                                  products: products,
                                  isTablet: isTablet,
                                  hPad: hPad,
                                  screenWidth: screenWidth,
                                  onTap: _goToDetail,
                                  onEdit: _goToEdit,
                                  onDelete: _confirmDelete,
                                )
                              : _ProductList(
                                  products: products,
                                  isTablet: isTablet,
                                  hPad: hPad,
                                  onTap: _goToDetail,
                                  onEdit: _goToEdit,
                                  onDelete: _confirmDelete,
                                ),
                        );
                      }),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddNewProductPage(sellerId: _sellerId ?? ''),
          ),
        ).then((_) => _loadProducts()),
        backgroundColor: AppColors.primaryButtonColor,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'Add Product',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: isTablet ? 15 : 13,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader({required bool isTablet, required double hPad}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 18, hPad, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Products',
                  style: TextStyle(
                    fontSize: isTablet ? 28 : 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Manage your auction listings',
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    color: AppColors.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _isGridView = !_isGridView),
            child: Container(
              width: isTablet ? 48 : 42,
              height: isTablet ? 48 : 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: AppColors.softShadow,
              ),
              child: Icon(
                _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
                color: AppColors.textPrimaryColor,
                size: isTablet ? 24 : 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar({required bool isTablet, required double hPad}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 14, hPad, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppColors.softShadow,
        ),
        child: TextField(
          controller: _searchController,
          style: TextStyle(fontSize: isTablet ? 16 : 14),
          decoration: InputDecoration(
            hintText: 'Search products...',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade400),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: Colors.grey.shade400,
                      size: 20,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: isTablet ? 16 : 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabStrip({required bool isTablet}) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primaryButtonColor,
        unselectedLabelColor: AppColors.textSecondaryColor,
        indicatorColor: AppColors.primaryButtonColor,
        indicatorWeight: 3,
        labelStyle: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: isTablet ? 15 : 13,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: isTablet ? 15 : 13,
        ),
        tabs: _tabs.map((t) => Tab(text: t)).toList(),
      ),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({
    required this.products,
    required this.isTablet,
    required this.hPad,
    required this.screenWidth,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final List<ProductUiModel> products;
  final bool isTablet;
  final double hPad;
  final double screenWidth;
  final void Function(ProductUiModel) onTap;
  final void Function(ProductUiModel) onEdit;
  final void Function(ProductUiModel) onDelete;

  int get _crossCount {
    if (screenWidth >= 1100) return 4;
    if (screenWidth >= 750) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(hPad, 18, hPad, 120),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _crossCount,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.68,
      ),
      itemCount: products.length,
      itemBuilder: (_, i) => _ProductGridCard(
        product: products[i],
        isTablet: isTablet,
        onTap: () => onTap(products[i]),
        onEdit: () => onEdit(products[i]),
        onDelete: () => onDelete(products[i]),
      ),
    );
  }
}

class _ProductList extends StatelessWidget {
  const _ProductList({
    required this.products,
    required this.isTablet,
    required this.hPad,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final List<ProductUiModel> products;
  final bool isTablet;
  final double hPad;
  final void Function(ProductUiModel) onTap;
  final void Function(ProductUiModel) onEdit;
  final void Function(ProductUiModel) onDelete;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(hPad, 18, hPad, 120),
      itemCount: products.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: _ProductListCard(
          product: products[i],
          isTablet: isTablet,
          onTap: () => onTap(products[i]),
          onEdit: () => onEdit(products[i]),
          onDelete: () => onDelete(products[i]),
        ),
      ),
    );
  }
}

class _ProductGridCard extends StatelessWidget {
  const _ProductGridCard({
    required this.product,
    required this.isTablet,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final ProductUiModel product;
  final bool isTablet;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  String _timeLeft() {
    final diff = product.endDate.difference(DateTime.now());
    if (diff.isNegative) return 'Ended';
    if (diff.inDays > 0) return '${diff.inDays}d left';
    if (diff.inHours > 0) return '${diff.inHours}h left';
    return '${diff.inMinutes}m left';
  }

  Color _timeColor() {
    final diff = product.endDate.difference(DateTime.now());
    if (diff.isNegative) return const Color(0xFFE53935);
    if (diff.inHours < 24) return const Color(0xFFF57C00);
    return const Color(0xFF2E7D32);
  }

  @override
  Widget build(BuildContext context) {
    final hasImg = product.productImageUrls.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: hasImg
                      ? Image.network(
                          product.productImageUrls.first,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (_, child, p) =>
                              p == null ? child : _imgLoading(),
                          errorBuilder: (_, _,_) => _imgPlaceholder(),
                        )
                      : _imgPlaceholder(),
                ),
                Positioned(
                  top: 9,
                  left: 9,
                  child: _Badge(label: _timeLeft(), color: _timeColor()),
                ),
                if (product.buyNowPrice != null)
                  Positioned(
                    top: 9,
                    right: 9,
                    child: _Badge(
                      label: 'Buy Now',
                      color: const Color(0xFFF57F17),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
              child: Text(
                product.productName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isTablet ? 14 : 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryColor,
                  height: 1.3,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Bid',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondaryColor,
                          ),
                        ),
                        Text(
                          'Rs. ${product.currentBidPrice.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryButtonColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (product.buyNowPrice != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Buy Now',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondaryColor,
                          ),
                        ),
                        Text(
                          'Rs. ${product.buyNowPrice!.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF57F17),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const Spacer(),
            Container(height: 1, color: const Color(0xFFF0F0F0)),
            Row(
              children: [
                Expanded(
                  child: _CardAction(
                    icon: Icons.edit_outlined,
                    label: 'Edit',
                    color: const Color(0xFF1565C0),
                    onTap: onEdit,
                  ),
                ),
                Container(width: 1, height: 38, color: const Color(0xFFF0F0F0)),
                Expanded(
                  child: _CardAction(
                    icon: Icons.delete_outline_rounded,
                    label: 'Delete',
                    color: const Color(0xFFC62828),
                    onTap: onDelete,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _imgPlaceholder() => Container(
    height: 150,
    color: Colors.grey.shade100,
    child: Center(
      child: Icon(Icons.image_outlined, size: 48, color: Colors.grey.shade300),
    ),
  );

  Widget _imgLoading() => Container(
    height: 150,
    color: Colors.grey.shade100,
    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
  );
}

class _ProductListCard extends StatelessWidget {
  const _ProductListCard({
    required this.product,
    required this.isTablet,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final ProductUiModel product;
  final bool isTablet;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  String _timeLeft() {
    final diff = product.endDate.difference(DateTime.now());
    if (diff.isNegative) return 'Ended';
    if (diff.inDays > 0) return '${diff.inDays}d left';
    if (diff.inHours > 0) return '${diff.inHours}h left';
    return '${diff.inMinutes}m left';
  }

  bool get _isEnded => product.endDate.difference(DateTime.now()).isNegative;

  @override
  Widget build(BuildContext context) {
    final imgSize = isTablet ? 120.0 : 100.0;
    final hasImg = product.productImageUrls.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
              child: hasImg
                  ? Image.network(
                      product.productImageUrls.first,
                      width: imgSize,
                      height: imgSize,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _imgPlaceholder(imgSize),
                    )
                  : _imgPlaceholder(imgSize),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.productName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          'Rs. ${product.currentBidPrice.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: isTablet ? 15 : 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryButtonColor,
                          ),
                        ),
                        if (product.buyNowPrice != null) ...[
                          const SizedBox(width: 10),
                          Text(
                            'BN: Rs. ${product.buyNowPrice!.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFFF57F17),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _isEnded
                            ? Colors.red.shade50
                            : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _timeLeft(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _isEnded
                              ? Colors.red.shade600
                              : Colors.green.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _SmallAction(
                          icon: Icons.edit_outlined,
                          label: 'Edit',
                          color: const Color(0xFF1565C0),
                          onTap: onEdit,
                        ),
                        const SizedBox(width: 10),
                        _SmallAction(
                          icon: Icons.delete_outline_rounded,
                          label: 'Delete',
                          color: const Color(0xFFC62828),
                          onTap: onDelete,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imgPlaceholder(double size) => Container(
    width: size,
    height: size,
    color: Colors.grey.shade100,
    child: Icon(Icons.image_outlined, color: Colors.grey.shade300, size: 36),
  );
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CardAction extends StatelessWidget {
  const _CardAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallAction extends StatelessWidget {
  const _SmallAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isTablet, required this.onAdd});

  final bool isTablet;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: isTablet ? 110 : 88,
              height: isTablet ? 110 : 88,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                size: isTablet ? 54 : 42,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No products found',
              style: TextStyle(
                fontSize: isTablet ? 22 : 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first auction listing to get started.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isTablet ? 15 : 13,
                color: AppColors.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryButtonColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
              ),
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text(
                'Add Product',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteConfirmDialog extends StatelessWidget {
  const _DeleteConfirmDialog({
    required this.productName,
    required this.onConfirm,
  });

  final String productName;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Container(
        constraints: BoxConstraints(maxWidth: isTablet ? 440 : double.infinity),
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
            const SizedBox(height: 20),
            Text(
              'Delete Product?',
              style: TextStyle(
                fontSize: isTablet ? 22 : 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 12),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontSize: isTablet ? 15 : 13,
                  color: AppColors.textSecondaryColor,
                  height: 1.5,
                ),
                children: [
                  const TextSpan(text: 'You are about to permanently delete '),
                  TextSpan(
                    text: '"$productName"',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryColor,
                    ),
                  ),
                  const TextSpan(text: '. This cannot be undone.'),
                ],
              ),
            ),
            const SizedBox(height: 28),
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
                      onConfirm();
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
  }
}
