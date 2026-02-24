// lib/features/auction/presentation/pages/create_new_auction.dart
import 'package:flutter/material.dart';
import 'package:gradient_elevated_button/gradient_elevated_button.dart';
import 'package:leelame/app/routes/app_routes.dart';
import 'package:leelame/app/theme/app_colors.dart';
import 'package:leelame/core/utils/snackbar_util.dart';

class CreateNewAuctionPage extends StatefulWidget {
  const CreateNewAuctionPage({super.key});

  @override
  State<CreateNewAuctionPage> createState() => _CreateNewAuctionPageState();
}

class _CreateNewAuctionPageState extends State<CreateNewAuctionPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final _createNewAuctionFormKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _startingBidController = TextEditingController();
  final _buyNowController = TextEditingController();
  final _shippingController = TextEditingController();

  String? _selectedCategory = "Electronics";
  String _selectedCondition = "Like New";
  String _selectedDuration = "7 Days";

  final List<String> _categories = [
    "Electronics",
    "Personal",
    "Accessories",
    "Documents",
    "Keys",
    "Bags",
    "Other",
  ];
  final List<String> _conditions = ["Refurbished", "Like New", "Used"];
  final List<String> _durations = ["1 Day", "3 Days", "7 Days", "14 Days"];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_pageListener);
  }

  void _pageListener() {
    // If you want to update via scroll, keep this minimal - onPageChanged will set page index.
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _descriptionController.dispose();
    _startingBidController.dispose();
    _buyNowController.dispose();
    _shippingController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    if (page < 0 || page > 2) {
      return;
    }
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() => _currentPage = page);
  }

  void _onBackPressed() {
    if (_currentPage == 0) {
      AppRoutes.pop(context);
    } else {
      _goToPage(_currentPage - 1);
    }

    // _pageController.previousPage(
    //   duration: const Duration(milliseconds: 300),
    //   curve: Curves.easeIn,
    // );
  }

  void _onContinuePressed() {
    if (_currentPage < 2) {
      _goToPage(_currentPage + 1);
    } else {
      SnackbarUtil.showSuccess(context, "Auction published (demo)!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0xFFDDDDDD),
                    width: 1.0,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => AppRoutes.pop(context),
                        child: Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: AppColors.arrowButtonPrimaryBackgroundColor,
                            boxShadow: AppColors.softShadow,
                            shape: BoxShape.circle,
                            // borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            color: AppColors.textPrimaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Create New Auction",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimaryColor,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "Step ${_currentPage + 1} of 3",
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 13),

                  // Dots Indicator
                  Row(
                    children: List.generate(
                      3,
                      (index) => Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          height: 7,
                          decoration: BoxDecoration(
                            gradient: _currentPage == index
                                ? AppColors.auctionPrimaryGradient
                                : const LinearGradient(
                                    colors: [
                                      Color(0xFFDDDDDD),
                                      Color(0xFFDDDDDD),
                                    ],
                                  ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),

            Expanded(
              child: Form(
                key: _createNewAuctionFormKey,
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: _buildStep1(),
                    ),
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: _buildStep2(),
                    ),
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: _buildStep3(),
                    ),
                  ],
                ),
              ),
            ),

            // Continue Button at the bottom fixed
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: const Color(0xFFDDDDDD), width: 1.0),
                ),
              ),
              child: _currentPage == 0
                  ? SizedBox(
                      width: double.infinity,
                      child: GradientElevatedButton(
                        style: GradientElevatedButton.styleFrom(
                          backgroundGradient: AppColors.auctionPrimaryGradient,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(20),
                          elevation: 2,
                        ),
                        onPressed: _onContinuePressed,
                        child: Text(
                          "Continue",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[200],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(20),
                              elevation: 0,
                            ),
                            onPressed: _onBackPressed,
                            child: Text(
                              "Back",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: GradientElevatedButton(
                            style: GradientElevatedButton.styleFrom(
                              backgroundGradient:
                                  AppColors.auctionPrimaryGradient,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 20,
                              ),
                              elevation: 2,
                            ),
                            onPressed: _onContinuePressed,
                            child: Text(
                              _currentPage < 2 ? "Continue" : "Publish",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
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
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Photo Upload Section
        Text(
          "Product Images",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 10),

        Row(
          children: [
            // Add Image Button
            GestureDetector(
              onTap: () {},
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.borderColor,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: AppColors.auctionPrimaryGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.add_a_photo_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Add Image",
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Item Title
        Text(
          "Product Name",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 12),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColors.softShadow,
          ),
          child: TextFormField(
            controller: _productNameController,
            decoration: const InputDecoration(
              hintText: "e.g., iPhone 17 Pro, Gucci Bag",
              hintStyle: TextStyle(color: AppColors.textTertiaryColor),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter product product name";
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 20),

        // Product Category
        Text(
          "Category",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 12),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColors.softShadow,
          ),
          child: DropdownButtonFormField<String>(
            initialValue: _selectedCategory,
            decoration: InputDecoration(
              hintText: "Select category",
              hintStyle: TextStyle(color: AppColors.textTertiaryColor),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            items: _categories.map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                _selectedCategory = newValue;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter location";
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 20),

        // Condition
        Text(
          "Condition",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _conditions.map((condition) {
            final isSelected = _selectedCondition == condition;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCondition = condition;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? AppColors.auctionPrimaryGradient
                      : null,
                  color: isSelected ? null : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: AppColors.softShadow,
                ),
                child: Text(
                  condition,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : AppColors.textSecondaryColor,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        // Description
        Text(
          'Description',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColors.softShadow,
          ),
          child: TextFormField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: "Write additional details about the product...",
              hintStyle: TextStyle(color: AppColors.textTertiaryColor),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Starting Bid",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: AppColors.softShadow,
          ),
          child: TextFormField(
            controller: _startingBidController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              prefixText: '\$ ',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          "Buy Now Price (Optional)",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: AppColors.softShadow,
          ),
          child: TextFormField(
            controller: _buyNowController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              prefixText: '\$ ',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          "Auction Duration",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _durations.map((d) {
            final selected = _selectedDuration == d;
            return GestureDetector(
              onTap: () => setState(() => _selectedDuration = d),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: selected ? AppColors.auctionPrimaryGradient : null,
                  color: selected ? null : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: AppColors.softShadow,
                ),
                child: Text(
                  d,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? Colors.white
                        : AppColors.textSecondaryColor,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        Text(
          "Shipping Cost",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: AppColors.softShadow,
          ),
          child: TextFormField(
            controller: _shippingController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              prefixText: '\$ ',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Example tips card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: AppColors.auctionSecondaryGradient,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: AppColors.primaryButtonColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Pricing Tips",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Set a competitive starting bid to attract more bidders. The buy now price should be higher than your expected final bid.",
                      style: TextStyle(color: AppColors.textSecondaryColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep3() {
    final productName = _productNameController.text.isNotEmpty
        ? _productNameController.text
        : 'Not set';
    final category = _selectedCategory ?? 'Not set';
    final condition = _selectedCondition;
    final description = _descriptionController.text.isNotEmpty
        ? _descriptionController.text
        : 'Not set';
    final starting = _startingBidController.text.isNotEmpty
        ? '\$${_startingBidController.text}'
        : '\$0';
    final buyNow = _buyNowController.text.isNotEmpty
        ? '\$${_buyNowController.text}'
        : 'Not set';
    final shipping = _shippingController.text.isNotEmpty
        ? '\$${_shippingController.text}'
        : '\$0';
    final duration = _selectedDuration;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Review Your Listing",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: AppColors.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _reviewRow('Prodcut Name', productName),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _reviewRow('Category', category)),
                  Expanded(child: _reviewRow('Condition', condition)),
                ],
              ),
              const SizedBox(height: 8),
              _reviewRow('Description', description),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _reviewRow('Starting Bid', starting, isPrice: true),
                  ),
                  Expanded(
                    child: _reviewRow('Buy Now Price', buyNow, isPrice: true),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _reviewRow('Duration', duration)),
                  Expanded(child: _reviewRow('Shipping', shipping)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        // Seller protection card (gradient)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppColors.auctionPrimaryGradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: AppColors.softShadow,
          ),
          child: Row(
            children: [
              const Icon(Icons.shield_outlined, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Seller Protection\nYour listing is protected by Leelame's seller guarantee. We ensure secure payments and buyer verification.",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _reviewRow(String label, String value, {bool isPrice = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: AppColors.textSecondaryColor)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: isPrice ? FontWeight.bold : FontWeight.w600,
              color: isPrice
                  ? AppColors.primaryButtonColor
                  : AppColors.textPrimaryColor,
              fontSize: isPrice ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
