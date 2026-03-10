// lib/features/product/presentation/pages/update_product_details_page.dart
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
import 'package:leelame/features/product/presentation/models/product_ui_model.dart';
import 'package:leelame/features/product/presentation/states/product_state.dart';
import 'package:leelame/features/product/presentation/viewmodels/product_view_model.dart';
import 'package:leelame/features/product_condition/presentation/states/product_condition_state.dart';
import 'package:leelame/features/product_condition/presentation/view_models/product_condition_view_model.dart';
import 'package:leelame/features/seller/presentation/states/seller_state.dart';
import 'package:leelame/features/seller/presentation/view_models/seller_view_model.dart';
import 'package:permission_handler/permission_handler.dart';

class UpdateProductPage extends ConsumerStatefulWidget {
  const UpdateProductPage({
    super.key,
    required this.productId,
    required this.sellerId,
    required this.categoryId,
    required this.productConditionId,
  });

  final String categoryId;
  final String productConditionId;
  final String productId;
  final String sellerId;

  @override
  ConsumerState<UpdateProductPage> createState() => _UpdateProductPageState();
}

class _UpdateProductPageState extends ConsumerState<UpdateProductPage> {
  final _updateProductFormKey = GlobalKey<FormState>();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _startPriceController = TextEditingController();
  final TextEditingController _bidIntervalController = TextEditingController();
  final TextEditingController _buyNowPriceController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();
  final List<XFile> _newImages = [];
  List<String> _existingImageUrls = [];
  final List<String> _removedExistingImageUrls = [];
  bool _didInitializeForm = false;

  String? _selectedCategoryId;
  String? _selectedConditionId;
  DateTime? _selectedEndDate;
  TimeOfDay? _selectedEndTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoryViewModelProvider.notifier).getAllCategories();
      ref
          .read(productConditionViewModelProvider.notifier)
          .getAllProductConditions();
      ref
          .read(sellerViewModelProvider.notifier)
          .getCurrentUser(sellerId: widget.sellerId);
      ref
          .read(sellerViewModelProvider.notifier)
          .getSellerIdById(widget.sellerId);
      ref
          .read(productViewModelProvider.notifier)
          .getProductById(widget.productId);
    });
  }

  void _loadUpdateDetails(ProductUiModel product) {
    if (_didInitializeForm) return;

    _productNameController.text = product.productName;
    _descriptionController.text = product.description ?? '';
    _startPriceController.text = product.startPrice.toString();
    _bidIntervalController.text = product.bidIntervalPrice.toString();
    _buyNowPriceController.text = product.buyNowPrice != null
        ? product.buyNowPrice.toString()
        : '';
    _selectedCategoryId = product.categoryId;
    _selectedConditionId = product.conditionId;
    _existingImageUrls = List<String>.from(product.productImageUrls);
    _removedExistingImageUrls.clear();

    _selectedEndDate = product.endDate;
    _endDateController.text = _formatDate(_selectedEndDate!);
    final tod = TimeOfDay.fromDateTime(product.endDate);
    _selectedEndTime = tod;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _endTimeController.text = tod.format(context);
    });

    _didInitializeForm = true;
  }

  void _removeExistingImageAt(int index) {
    if (index < 0 || index >= _existingImageUrls.length) return;
    final imageUrl = _existingImageUrls[index];
    setState(() {
      _existingImageUrls.removeAt(index);
      if (!_removedExistingImageUrls.contains(imageUrl)) {
        _removedExistingImageUrls.add(imageUrl);
      }
    });
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _descriptionController.dispose();
    _startPriceController.dispose();
    _bidIntervalController.dispose();
    _buyNowPriceController.dispose();
    _endDateController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<bool> _requestPermission(Permission permission) async {
    final status = await permission.status;
    if (status.isGranted) return true;
    if (status.isDenied) {
      final result = await permission.request();
      return result.isGranted;
    }
    if (status.isPermanentlyDenied) {
      _showPermissionDialog();
      return false;
    }
    return true;
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'This feature requires permission to access your camera or gallery. Please enable it in settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => AppRoutes.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              AppRoutes.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFromCamera() async {
    final granted = await _requestPermission(Permission.camera);
    if (!granted) return;
    final image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() => _newImages.add(image));
    }
  }

  Future<void> _pickFromGallery() async {
    final granted = await _requestPermission(Permission.photos);
    if (!granted) {
      final fallback = await _requestPermission(Permission.storage);
      if (!fallback) return;
    }
    final images = await _imagePicker.pickMultiImage(imageQuality: 80);
    if (images.isNotEmpty) {
      setState(() => _newImages.addAll(images));
    }
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Open Camera'),
                onTap: () {
                  AppRoutes.pop(context);
                  _pickFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Open Gallery'),
                onTap: () {
                  AppRoutes.pop(context);
                  _pickFromGallery();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleUpdateProduct(ProductUiModel product) async {
    if (!(_updateProductFormKey.currentState?.validate() ?? false)) return;

    DateTime finalEndDate;
    if (_selectedEndDate != null) {
      final tod = _selectedEndTime ?? const TimeOfDay(hour: 23, minute: 59);
      finalEndDate = DateTime(
        _selectedEndDate!.year,
        _selectedEndDate!.month,
        _selectedEndDate!.day,
        tod.hour,
        tod.minute,
      );
    } else {
      finalEndDate = product.endDate;
    }

    await ref
        .read(productViewModelProvider.notifier)
        .updateProduct(
          productId: widget.productId,
          productName: _productNameController.text.trim(),
          description: _descriptionController.text.trim(),
          categoryId: _selectedCategoryId,
          conditionId: _selectedConditionId,
          startPrice: double.tryParse(_startPriceController.text.trim()) ?? 0,
          bidIntervalPrice:
              double.tryParse(_bidIntervalController.text.trim()) ?? 0,
          buyNowPrice: _buyNowPriceController.text.trim().isNotEmpty
              ? double.tryParse(_buyNowPriceController.text.trim())
              : null,
          endDate: finalEndDate,
          productImages: _newImages.isNotEmpty
              ? _newImages.map((x) => File(x.path)).toList()
              : null,
          removedExistingProductImageUrls: _removedExistingImageUrls.isNotEmpty
              ? List<String>.from(_removedExistingImageUrls)
              : null,
          imageSubFolder: 'product-images',
        );
  }

  @override
  Widget build(BuildContext context) {
    final categoryState = ref.watch(categoryViewModelProvider);
    final productConditionState = ref.watch(productConditionViewModelProvider);
    final productState = ref.watch(productViewModelProvider);

    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final horizontalPadding = isTablet ? screenWidth * 0.08 : 20.0;
    final titleSize = isTablet ? 24.0 : 20.0;
    final labelSize = isTablet ? 16.0 : 14.0;
    final inputFontSize = isTablet ? 16.0 : 14.0;

    ref.listen<CategoryState>(categoryViewModelProvider, (_, next) {
      if (next.categoryStatus == CategoryStatus.error) {
        SnackbarUtil.showError(
          context,
          next.errorMessage ?? 'Error loading categories.',
        );
      }
    });

    ref.listen<ProductConditionState>(productConditionViewModelProvider, (
      _,
      next,
    ) {
      if (next.productConditionStatus == ProductConditionStatus.error) {
        SnackbarUtil.showError(
          context,
          next.errorMessage ?? 'Error loading conditions.',
        );
      }
    });

    ref.listen<ProductState>(productViewModelProvider, (_, next) {
      if (next.productStatus == ProductStatus.error) {
        SnackbarUtil.showError(
          context,
          next.errorMessage ?? 'Failed to update product.',
        );
      } else if (next.productStatus == ProductStatus.updated) {
        SnackbarUtil.showSuccess(context, 'Product updated successfully!');
        AppRoutes.pop(context);
      } else if (next.selectedProduct != null) {
        _loadUpdateDetails(ProductUiModel.fromEntity(next.selectedProduct!));
      }
    });

    ref.listen<SellerState>(sellerViewModelProvider, (previous, next) {
      if (next.sellerStatus == SellerStatus.error) {
        SnackbarUtil.showError(
          context,
          next.errorMessage ?? "Error loading seller details!",
        );
      }
    });

    if (productState.selectedProduct == null) {
      return const Scaffold(
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _AppBar(
              title: 'Edit Product',
              titleSize: titleSize,
              onBack: () => AppRoutes.pop(context),
            ),
            Expanded(
              child: Form(
                key: _updateProductFormKey,
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 20,
                  ),
                  child: isTablet
                      ? _TabletLayout(
                          leftColumn: _buildImageSection(labelSize: labelSize),
                          rightColumn: _buildFormFields(
                            categoryState: categoryState,
                            productConditionState: productConditionState,
                            labelSize: labelSize,
                            inputFontSize: inputFontSize,
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildImageSection(labelSize: labelSize),
                            const SizedBox(height: 20),
                            _buildFormFields(
                              categoryState: categoryState,
                              productConditionState: productConditionState,
                              labelSize: labelSize,
                              inputFontSize: inputFontSize,
                            ),
                          ],
                        ),
                ),
              ),
            ),
            _BottomBar(
              isLoading: productState.productStatus == ProductStatus.loading,
              buttonLabel: 'Save Changes',
              onBack: () => AppRoutes.pop(context),
              onAction: () {
                _handleUpdateProduct(
                  ProductUiModel.fromEntity(productState.selectedProduct!),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection({required double labelSize}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(text: 'Product Images', fontSize: labelSize),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: Row(
            children: [
              _AddImageButton(onTap: _showImagePicker),
              const SizedBox(width: 12),
              Expanded(
                child: _existingImageUrls.isEmpty
                    ? Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: AppColors.softShadow,
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'No current images',
                          style: TextStyle(
                            color: AppColors.textTertiaryColor,
                            fontSize: 12,
                          ),
                        ),
                      )
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _existingImageUrls.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          return _ExistingImageTile(
                            imageUrl: _existingImageUrls[index],
                            onRemove: () => _removeExistingImageAt(index),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (_newImages.isNotEmpty) ...[
          const Text(
            'New Images',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 94,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _newImages.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final image = _newImages[index];
                return _NewImageTile(
                  file: File(image.path),
                  onRemove: () => setState(() => _newImages.removeAt(index)),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFormFields({
    required CategoryState categoryState,
    required ProductConditionState productConditionState,
    required double labelSize,
    required double inputFontSize,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(text: 'Product Name', fontSize: labelSize),
        const SizedBox(height: 10),
        _StyledTextFormField(
          controller: _productNameController,
          hintText: 'e.g., iPhone 17 Pro, Gucci Bag',
          fontSize: inputFontSize,
          validator: (v) =>
              (v == null || v.isEmpty) ? 'Please enter a product name' : null,
        ),
        const SizedBox(height: 20),
        _SectionLabel(text: 'Category', fontSize: labelSize),
        const SizedBox(height: 10),
        _StyledDropdown(
          hintText: 'Select category',
          value: _selectedCategoryId,
          items: categoryState.categories
              .map(
                (c) => DropdownMenuItem(
                  value: c.categoryId,
                  child: Text(c.categoryName),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _selectedCategoryId = v),
          validator: (v) =>
              (v == null || v.isEmpty) ? 'Please select a category' : null,
        ),
        const SizedBox(height: 20),
        _SectionLabel(text: 'Condition', fontSize: labelSize),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: productConditionState.productConditions.map((pc) {
            final selected = _selectedConditionId == pc.productConditionId;
            return GestureDetector(
              onTap: () =>
                  setState(() => _selectedConditionId = pc.productConditionId),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: selected ? AppColors.auctionPrimaryGradient : null,
                  color: selected ? null : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: AppColors.softShadow,
                ),
                child: Text(
                  pc.productConditionName,
                  style: TextStyle(
                    fontSize: 13,
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
        _SectionLabel(text: 'Description', fontSize: labelSize),
        const SizedBox(height: 10),
        _StyledTextFormField(
          controller: _descriptionController,
          hintText: 'Write additional details about the product...',
          fontSize: inputFontSize,
          maxLines: 4,
        ),
        const SizedBox(height: 20),
        _SectionLabel(text: 'Start Price', fontSize: labelSize),
        const SizedBox(height: 10),
        _StyledTextFormField(
          controller: _startPriceController,
          hintText: '0.00',
          fontSize: inputFontSize,
          prefixText: 'Rs. ',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 20),
        _SectionLabel(text: 'Bid Interval Price', fontSize: labelSize),
        const SizedBox(height: 10),
        _StyledTextFormField(
          controller: _bidIntervalController,
          hintText: '0.00',
          fontSize: inputFontSize,
          prefixText: 'Rs. ',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 20),
        _SectionLabel(text: 'Buy Now Price (Optional)', fontSize: labelSize),
        const SizedBox(height: 10),
        _StyledTextFormField(
          controller: _buyNowPriceController,
          hintText: 'Leave empty to disable Buy Now',
          fontSize: inputFontSize,
          prefixText: 'Rs. ',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 20),
        _SectionLabel(text: 'End Date & Time', fontSize: labelSize),
        const SizedBox(height: 10),

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
                        if (_selectedEndDate == null) {
                          final now = DateTime.now();
                          _selectedEndDate = now;
                          _endDateController.text = _formatDate(now);
                        }
                      });
                    }
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
      ],
    );
  }
}

class _TabletLayout extends StatelessWidget {
  const _TabletLayout({required this.leftColumn, required this.rightColumn});

  final Widget leftColumn;
  final Widget rightColumn;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: leftColumn),
        const SizedBox(width: 32),
        Expanded(flex: 2, child: rightColumn),
      ],
    );
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar({
    required this.title,
    required this.titleSize,
    required this.onBack,
  });

  final String title;
  final double titleSize;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 15),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFDDDDDD), width: 1)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: AppColors.arrowButtonPrimaryBackgroundColor,
                boxShadow: AppColors.softShadow,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_rounded),
            ),
          ),
          const SizedBox(width: 15),
          Text(
            title,
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.isLoading,
    required this.buttonLabel,
    required this.onBack,
    required this.onAction,
  });

  final bool isLoading;
  final String buttonLabel;
  final VoidCallback onBack;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFDDDDDD), width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(18),
                elevation: 0,
              ),
              onPressed: onBack,
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            flex: 2,
            child: GradientElevatedButton(
              style: GradientElevatedButton.styleFrom(
                backgroundGradient: AppColors.auctionPrimaryGradient,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(18),
                elevation: 2,
              ),
              onPressed: isLoading ? null : onAction,
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      buttonLabel,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text, required this.fontSize});

  final String text;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryColor,
      ),
    );
  }
}

class _StyledTextFormField extends StatelessWidget {
  const _StyledTextFormField({
    required this.controller,
    required this.hintText,
    required this.fontSize,
    this.prefixText,
    this.maxLines = 1,
    this.readOnly = false,
    this.keyboardType,
    this.onTap,
    this.validator,
  });

  final TextEditingController controller;
  final String hintText;
  final double fontSize;
  final String? prefixText;
  final int maxLines;
  final bool readOnly;
  final TextInputType? keyboardType;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppColors.softShadow,
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        readOnly: readOnly,
        keyboardType: keyboardType,
        onTap: onTap,
        style: TextStyle(fontSize: fontSize),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: AppColors.textTertiaryColor),
          prefixText: prefixText,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        validator: validator,
      ),
    );
  }
}

class _StyledDropdown extends StatelessWidget {
  const _StyledDropdown({
    required this.hintText,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  final String hintText;
  final String? value;
  final List<DropdownMenuItem<String>> items;
  final void Function(String?) onChanged;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppColors.softShadow,
      ),
      child: DropdownButtonFormField<String>(
        initialValue: value?.isNotEmpty == true ? value : null,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: AppColors.textTertiaryColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        items: items,
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }
}

class _AddImageButton extends StatelessWidget {
  const _AddImageButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderColor, width: 2),
          boxShadow: AppColors.softShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: AppColors.auctionPrimaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.add_a_photo_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Add',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExistingImageTile extends StatelessWidget {
  const _ExistingImageTile({required this.imageUrl, required this.onRemove});

  final String imageUrl;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.network(
            imageUrl,
            width: 90,
            height: 90,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              width: 90,
              height: 90,
              color: Colors.grey[200],
              child: Icon(Icons.broken_image, color: Colors.grey[400]),
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }
}

class _NewImageTile extends StatelessWidget {
  const _NewImageTile({required this.file, required this.onRemove});

  final File file;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.file(
            file,
            width: 90,
            height: 90,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              width: 90,
              height: 90,
              color: Colors.grey[200],
              child: Icon(Icons.broken_image, color: Colors.grey[400]),
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
        Positioned(
          bottom: 4,
          left: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'New',
              style: TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
        ),
      ],
    );
  }
}
