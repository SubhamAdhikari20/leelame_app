// lib/features/bid/presentation/pages/create_new_auction.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gradient_elevated_button/gradient_elevated_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:leelame/app/routes/app_routes.dart';
import 'package:leelame/app/theme/app_colors.dart';
import 'package:leelame/core/utils/snackbar_util.dart';
import 'package:leelame/features/category/presentation/states/category_state.dart';
import 'package:leelame/features/category/presentation/view_models/category_view_model.dart';
import 'package:leelame/features/product/presentation/states/product_state.dart';
import 'package:leelame/features/product/presentation/viewmodels/product_view_model.dart';
import 'package:leelame/features/product_condition/presentation/states/product_condition_state.dart';
import 'package:leelame/features/product_condition/presentation/view_models/product_condition_view_model.dart';
import 'package:leelame/features/seller/presentation/states/seller_state.dart';
import 'package:leelame/features/seller/presentation/view_models/seller_view_model.dart';
import 'package:permission_handler/permission_handler.dart';

class AddNewProductPage extends ConsumerStatefulWidget {
  const AddNewProductPage({super.key, required this.sellerId});
  final String sellerId;

  @override
  ConsumerState<AddNewProductPage> createState() => _AddNewProductPageState();
}

class _AddNewProductPageState extends ConsumerState<AddNewProductPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final _createNewAuctionFormKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _startPriceController = TextEditingController();
  final _bidIntervalPriceController = TextEditingController();
  final _endDateController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _buyNowController = TextEditingController();
  final _shippingController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();
  final List<XFile> _selectedProductImages = [];
  String? _selectedMediaType; // 'image' or 'video'
  // final List<String> _productImageUrls = [];

  String? _selectedCategoryId = "";
  String? _selectedConditionId = "";
  DateTime? _selectedEndDate;
  TimeOfDay? _selectedEndTime;

  // String? _selectedCategory = "";
  // String _selectedCondition = "";
  // String _selectedDuration = "";
  // final List<String> _durations = ["1 Day", "3 Days", "7 Days", "14 Days"];

  // String? _selectedCategory = "Electronics";
  // String _selectedCondition = "Like New";

  // final List<String> _categories = [
  //   "Electronics",
  //   "Personal",
  //   "Accessories",
  //   "Documents",
  //   "Keys",
  //   "Bags",
  //   "Other",
  // ];
  // final List<String> _conditions = ["Refurbished", "Like New", "Used"];
  // String _selectedDuration = "7 Days";
  // final List<String> _durations = ["1 Day", "3 Days", "7 Days", "14 Days"];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_pageListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoryViewModelProvider.notifier).getAllCategories();
      ref
          .read(productConditionViewModelProvider.notifier)
          .getAllProductConditions();
      ref.read(productViewModelProvider.notifier).getAllProducts();
      ref
          .read(sellerViewModelProvider.notifier)
          .getCurrentUser(sellerId: widget.sellerId);
    });
  }

  void _pageListener() {
    // If you want to update via scroll, keep this minimal - onPageChanged will set page index.
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _descriptionController.dispose();
    _startPriceController.dispose();
    _bidIntervalPriceController.dispose();
    _endDateController.dispose();
    _endTimeController.dispose();
    _buyNowController.dispose();
    _shippingController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) {
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  Future<void> _handleAddProduct({
    List<File>? productImages,
    String? imageSubFolder,
  }) async {
    DateTime finalEndDate;

    if (_selectedEndDate != null) {
      final date = _selectedEndDate!;
      final tod = _selectedEndTime ?? TimeOfDay(hour: 23, minute: 59);
      finalEndDate = DateTime(
        date.year,
        date.month,
        date.day,
        tod.hour,
        tod.minute,
      );
    } else if (_endDateController.text.isNotEmpty) {
      try {
        final parsed = DateTime.parse(_endDateController.text);
        finalEndDate = parsed;
      } catch (_) {
        finalEndDate = DateTime.now();
      }
    } else {
      finalEndDate = DateTime.now();
    }

    await ref
        .read(productViewModelProvider.notifier)
        .addProduct(
          productName: _productNameController.text.trim(),
          description: _descriptionController.text.trim(),
          sellerId: widget.sellerId,
          categoryId: _selectedCategoryId,
          conditionId: _selectedConditionId,
          startPrice: _startPriceController.text.isNotEmpty
              ? double.tryParse(_startPriceController.text.trim()) ?? 0
              : 0,
          bidIntervalPrice: _bidIntervalPriceController.text.isNotEmpty
              ? double.tryParse(_bidIntervalPriceController.text.trim()) ?? 0
              : 0,
          endDate: finalEndDate,
          productImages: productImages,
          imageSubFolder: imageSubFolder,
          // endDate: _endDateController.text.isNotEmpty
          //     ? DateTime.tryParse(_endDateController.text.trim()) ??
          //           DateTime.now()
          //     : DateTime.now(),
          // productImages: _selectedProductImages
          //     .map((xfile) => File(xfile.path))
          //     .toList(),
          // imageSubFolder: "product-images",
        );
  }

  Future<bool> _requestPermissionFromUser(Permission permission) async {
    final status = await permission.status;
    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await permission.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialogBox();
      return false;
    }

    return true;
  }

  void _showPermissionDeniedDialogBox() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Permission Required"),
          content: Text(
            "This feature requires permission to access your camera or gallery. Please enable it in your device settings.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                AppRoutes.pop(context);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                AppRoutes.pop(context);
                openAppSettings();
              },
              child: Text("Open Settings"),
            ),
          ],
        );
      },
    );
  }

  // Camera
  Future<void> _pickFromCamera() async {
    try {
      final hasPermission = await _requestPermissionFromUser(Permission.camera);
      if (!hasPermission) {
        return;
      }

      final XFile? productImage = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (productImage != null) {
        setState(() {
          _selectedProductImages.clear();
          _selectedProductImages.add(productImage);
          _selectedMediaType = "photo";
        });
      }
    } catch (e) {
      debugPrint("Camera Error $e");

      if (mounted) {
        SnackbarUtil.showError(
          context,
          "Unable to access camera. Please try using from gallery instead.",
        );
      }
    }
  }

  // Gallery
  Future<void> _pickFromGallery({bool allowMultiple = true}) async {
    try {
      final hasPermission = await _requestPermissionFromUser(Permission.photos);

      if (!hasPermission) {
        final permission = await _requestPermissionFromUser(Permission.storage);
        if (!permission) {
          return;
        }
      }

      if (allowMultiple) {
        final List<XFile> images = await _imagePicker.pickMultiImage(
          imageQuality: 80,
        );
        if (images.isNotEmpty) {
          setState(() {
            _selectedProductImages.clear();
            _selectedProductImages.addAll(images);
            _selectedMediaType = "photo";
          });
        }
      } else {
        final XFile? productImage = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
        );

        if (productImage != null) {
          setState(() {
            _selectedProductImages.clear();
            _selectedProductImages.add(productImage);
            _selectedMediaType = "photo";
          });
        }
      }
    } catch (e) {
      debugPrint("Gallery Error $e");

      if (mounted) {
        SnackbarUtil.showError(
          context,
          "Unable to access gallery. Please try using the camera instead.",
        );
      }
    }
  }

  // Dialog Box for image option.
  Future<void> _pickMedia() async {
    if (!mounted) {
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.camera_alt),
                  title: Text("Open Camera"),
                  onTap: () {
                    AppRoutes.pop(context);
                    _pickFromCamera();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo_library),
                  title: Text("Open Gallery"),
                  onTap: () {
                    AppRoutes.pop(context);
                    _pickFromGallery();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
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
      if (_createNewAuctionFormKey.currentState?.validate() ?? false) {
        if (_selectedProductImages.isNotEmpty) {
          _handleAddProduct(
            productImages: _selectedProductImages
                .map((xfile) => File(xfile.path))
                .toList(),
            imageSubFolder: "product-images",
          );
        } else {
          _handleAddProduct();
        }
        // _handleAddProduct(
        //   productImages: _selectedProductImages
        //       .map((xfile) => File(xfile.path))
        //       .toList(),
        //   imageSubFolder: "product-images",
        // );
      }
      // SnackbarUtil.showSuccess(context, "Auction published (demo)!");
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryState = ref.watch(categoryViewModelProvider);
    final productConditionState = ref.watch(productConditionViewModelProvider);
    final productState = ref.watch(productViewModelProvider);
    final sellerState = ref.watch(sellerViewModelProvider);

    ref.listen<CategoryState>(categoryViewModelProvider, (previous, next) {
      if (next.categoryStatus == CategoryStatus.error) {
        SnackbarUtil.showError(
          context,
          next.errorMessage ?? "Error loading category!",
        );
      }
    });

    ref.listen<ProductConditionState>(productConditionViewModelProvider, (
      previous,
      next,
    ) {
      if (next.productConditionStatus == ProductConditionStatus.error) {
        SnackbarUtil.showError(
          context,
          next.errorMessage ?? "Error loading product condition!",
        );
      }
    });

    ref.listen<ProductState>(productViewModelProvider, (previous, next) {
      if (next.productStatus == ProductStatus.error) {
        SnackbarUtil.showError(
          context,
          next.errorMessage ?? "Error loading product details!",
        );
      } else if (next.productStatus == ProductStatus.created) {
        SnackbarUtil.showSuccess(
          context,
          "Product added successfully! Wait for it to be verified by admin.",
        );
        AppRoutes.pop(context);
      }
    });

    ref.listen<SellerState>(sellerViewModelProvider, (previous, next) {
      if (next.sellerStatus == SellerStatus.error) {
        SnackbarUtil.showError(
          context,
          next.errorMessage ?? "Error loading current user!",
        );
      } else if (next.seller == null) {
        SnackbarUtil.showError(
          context,
          next.errorMessage ?? "Error loading current user!",
        );
      }
    });

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
                              "Add New Product",
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
                      child: _buildStep1(
                        categoryState: categoryState,
                        productConditionState: productConditionState,
                        productState: productState,
                      ),
                    ),
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: _buildStep2(),
                    ),
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: _buildStep3(
                        categoryState: categoryState,
                        productConditionState: productConditionState,
                      ),
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

  Widget _buildStep1({
    // CategoryState? categoryState,
    // ProductConditionState? productConditionState,
    // ProductState? productState,
    required CategoryState categoryState,
    required ProductConditionState productConditionState,
    required ProductState productState,
  }) {
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

        // Add Image Button
        GestureDetector(
          onTap: () {
            _pickMedia();
          },
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

        // Preview selected images horizontally
        if (_selectedProductImages.isNotEmpty) ...[
          const SizedBox(height: 15),

          SizedBox(
            height: 125,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedProductImages.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final xfile = _selectedProductImages[index];
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(xfile.path),
                        width: 125,
                        height: 125,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 125,
                          height: 125,
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.broken_image,
                            size: 40,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedProductImages.removeAt(index);
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
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
            initialValue: _selectedCategoryId?.isNotEmpty == true
                ? _selectedCategoryId
                : null,
            decoration: InputDecoration(
              hintText: "Select category",
              hintStyle: TextStyle(color: AppColors.textTertiaryColor),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            items: categoryState.categories.map((category) {
              return DropdownMenuItem<String>(
                value: category.categoryId,
                child: Text(category.categoryName),
              );
            }).toList(),
            // _categories.map((String value) {
            //   return DropdownMenuItem<String>(value: value, child: Text(value));
            // }).toList(),
            onChanged: (newValue) {
              setState(() {
                _selectedCategoryId = newValue;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter categoty";
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
          children: productConditionState.productConditions.map((
            productCondition,
          ) {
            // _conditions.map((condition) {
            // final isSelected = _selectedCondition == condition;
            // return GestureDetector(
            //   onTap: () {
            //     setState(() {
            //       _selectedCondition = condition;
            //     });
            //   },

            final isSelected =
                _selectedConditionId == productCondition.productConditionId;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedConditionId = productCondition.productConditionId;
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
                  productCondition.productConditionName,
                  // condition,
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
          "Start Price",
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
            controller: _startPriceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              prefixText: "Rs. ",
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
        const SizedBox(height: 18),

        Text(
          "Bid Interval Price",
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
            controller: _bidIntervalPriceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              prefixText: "Rs. ",
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
        const SizedBox(height: 20),

        Text(
          "End Date",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: AppColors.softShadow,
                ),
                child: TextFormField(
                  controller: _endDateController,
                  readOnly: true,
                  onTap: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(Duration(days: 7)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                    );

                    if (pickedDate != null) {
                      setState(() {
                        _selectedEndDate = pickedDate;
                        _endDateController.text = _formatDate(pickedDate);

                        // If time was not yet selected, populate a sensible default
                        if (_selectedEndTime == null) {
                          _selectedEndTime = TimeOfDay.now();
                          _endTimeController.text = _selectedEndTime!.format(
                            context,
                          );
                        }
                      });
                    }
                    // final DateTime? pickedDate = await showDatePicker(
                    //   context: context,
                    //   initialDate: DateTime.now().add(Duration(days: 7)),
                    //   firstDate: DateTime.now(),
                    //   lastDate: DateTime.now().add(Duration(days: 365)),
                    // );

                    // if (pickedDate != null) {
                    //   setState(() {
                    //     _endDateController.text = pickedDate
                    //         .toIso8601String()
                    //         .split('T')
                    //         .first;
                    //   });
                    // }
                  },
                  decoration: const InputDecoration(
                    hintText: "YYYY-MM-DD",
                    hintStyle: TextStyle(color: AppColors.textTertiaryColor),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: AppColors.softShadow,
                ),
                child: TextFormField(
                  controller: _endTimeController,
                  readOnly: true,
                  onTap: () async {
                    final TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: _selectedEndTime ?? TimeOfDay.now(),
                    );

                    if (pickedTime != null) {
                      setState(() {
                        _selectedEndTime = pickedTime;
                        _endTimeController.text = pickedTime.format(context);

                        // If user hasn't picked a date before picking time, default to today
                        if (_selectedEndDate == null) {
                          final now = DateTime.now();
                          _selectedEndDate = now;
                          _endDateController.text = _formatDate(now);
                        }
                      });
                    }
                    // final TimeOfDay? pickedTime = await showTimePicker(
                    //   context: context,
                    //   initialTime: TimeOfDay.now(),
                    // );

                    // if (pickedTime != null) {
                    //   setState(() {
                    //     _endTimeController.text = pickedTime.format(context);
                    //   });
                    // }
                  },
                  decoration: const InputDecoration(
                    hintText: "HH:MM: AM/PM",
                    hintStyle: TextStyle(color: AppColors.textTertiaryColor),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Wrap(
        //   spacing: 10,
        //   runSpacing: 10,
        //   children: _durations.map((d) {
        //     final selected = _selectedDuration == d;
        //     return GestureDetector(
        //       onTap: () => setState(() => _selectedDuration = d),
        //       child: AnimatedContainer(
        //         duration: const Duration(milliseconds: 200),
        //         padding: const EdgeInsets.symmetric(
        //           horizontal: 18,
        //           vertical: 12,
        //         ),
        //         decoration: BoxDecoration(
        //           gradient: selected ? AppColors.auctionPrimaryGradient : null,
        //           color: selected ? null : Colors.white,
        //           borderRadius: BorderRadius.circular(12),
        //           boxShadow: AppColors.softShadow,
        //         ),
        //         child: Text(
        //           d,
        //           style: TextStyle(
        //             fontWeight: FontWeight.w600,
        //             color: selected
        //                 ? Colors.white
        //                 : AppColors.textSecondaryColor,
        //           ),
        //         ),
        //       ),
        //     );
        //   }).toList(),
        // ),
        // const SizedBox(height: 20),

        // Text(
        //   "Buy Now Price (Optional)",
        //   style: TextStyle(
        //     fontSize: 16,
        //     fontWeight: FontWeight.w600,
        //     color: AppColors.textPrimaryColor,
        //   ),
        // ),
        // const SizedBox(height: 8),

        // Container(
        //   decoration: BoxDecoration(
        //     color: Colors.white,
        //     borderRadius: BorderRadius.circular(12),
        //     boxShadow: AppColors.softShadow,
        //   ),
        //   child: TextFormField(
        //     controller: _buyNowController,
        //     keyboardType: TextInputType.number,
        //     decoration: const InputDecoration(
        //       prefixText: '\$ ',
        //       border: InputBorder.none,
        //       contentPadding: EdgeInsets.all(16),
        //     ),
        //   ),
        // ),
        // const SizedBox(height: 20),
        // Text(
        //   "Shipping Cost",
        //   style: TextStyle(
        //     fontSize: 16,
        //     fontWeight: FontWeight.w600,
        //     color: AppColors.textPrimaryColor,
        //   ),
        // ),
        // const SizedBox(height: 8),
        // Container(
        //   decoration: BoxDecoration(
        //     color: Colors.white,
        //     borderRadius: BorderRadius.circular(12),
        //     boxShadow: AppColors.softShadow,
        //   ),
        //   child: TextFormField(
        //     controller: _shippingController,
        //     keyboardType: TextInputType.number,
        //     decoration: const InputDecoration(
        //       prefixText: '\$ ',
        //       border: InputBorder.none,
        //       contentPadding: EdgeInsets.all(16),
        //     ),
        //   ),
        // ),
        // const SizedBox(height: 20),

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

  Widget _buildStep3({
    required CategoryState categoryState,
    required ProductConditionState productConditionState,
    // CategoryState? categoryState,
    // ProductConditionState? productConditionState,
  }) {
    final productName = _productNameController.text.isNotEmpty
        ? _productNameController.text
        : 'Not set';
    final category =
        _selectedCategoryId ==
            categoryState.categories
                .map((category) => category.categoryId)
                .firstWhere(
                  (categoryId) => categoryId == _selectedCategoryId,
                  orElse: () => null,
                )
        ? categoryState.categories
              .firstWhere(
                (category) => category.categoryId == _selectedCategoryId,
              )
              .categoryName
        : "Not set";
    final condition =
        _selectedConditionId ==
            productConditionState.productConditions
                .map((condition) => condition.productConditionId)
                .firstWhere(
                  (conditionId) => conditionId == _selectedConditionId,
                  orElse: () => null,
                )
        ? productConditionState.productConditions
              .firstWhere(
                (condition) =>
                    condition.productConditionId == _selectedConditionId,
              )
              .productConditionName
        : "Not set";
    final description = _descriptionController.text.isNotEmpty
        ? _descriptionController.text
        : 'Not set';
    final starting = _startPriceController.text.isNotEmpty
        ? 'Rs. ${_startPriceController.text}'
        : 'Rs. 0';
    final bidIntervalPrice = _bidIntervalPriceController.text.isNotEmpty
        ? 'Rs. ${_bidIntervalPriceController.text}'
        : 'Rs. 0';
    final buyNow = _buyNowController.text.isNotEmpty
        ? 'Rs. ${_buyNowController.text}'
        : 'Not set';
    final shipping = _shippingController.text.isNotEmpty
        ? 'Rs. ${_shippingController.text}'
        : 'Rs. 0';
    final endDate = _selectedEndDate != null && _selectedEndTime != null
        ? "${_selectedEndDate?.toIso8601String().split('T').first} ${_selectedEndTime?.format(context)}"
        : 'Not set';

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
                    child: _reviewRow(
                      'Bid Interval',
                      bidIntervalPrice,
                      isPrice: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _reviewRow('Buy Now Price', buyNow, isPrice: true),
                  ),
                  Expanded(child: _reviewRow('Shipping', shipping)),
                ],
              ),
              const SizedBox(height: 8),
              _reviewRow('End Date', endDate),
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
