// lib/features/buyer/presentation/pages/edit_profile_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gradient_elevated_button/gradient_elevated_button.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:leelame/app/routes/app_routes.dart';
import 'package:leelame/app/theme/app_colors.dart';
import 'package:leelame/core/utils/snackbar_util.dart';
import 'package:leelame/core/widgets/custom_text_area_field.dart';
import 'package:leelame/core/widgets/custom_text_field.dart';
import 'package:leelame/features/buyer/presentation/models/buyer_ui_model.dart';
import 'package:leelame/features/buyer/presentation/states/buyer_state.dart';
import 'package:leelame/features/buyer/presentation/view_models/buyer_view_model.dart';
import 'package:permission_handler/permission_handler.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  final BuyerUiModel? buyerUiModel;

  const EditProfilePage({super.key, this.buyerUiModel});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _editProfileFormKey = GlobalKey<FormState>();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();
  XFile? _profileImage;
  String? _selectedMediaType; // 'image' or 'video'
  String? _profilePictureUrl;

  @override
  void initState() {
    super.initState();
    final buyer = widget.buyerUiModel;

    _fullNameController.text = buyer?.fullName ?? "";
    _usernameController.text = buyer?.username ?? "";
    _emailController.text = buyer?.userUiModel?.email ?? "";
    _phoneNumberController.text = buyer?.phoneNumber ?? "";
    _bioController.text = buyer?.bio ?? "";
    _profilePictureUrl = buyer?.profilePictureUrl;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _bioController.dispose();

    super.dispose();
  }

  Future<void> _handleUpdateDetails() async {
    if (_editProfileFormKey.currentState!.validate()) {
      final buyerId = widget.buyerUiModel?.buyerId;
      if (buyerId != null) {
        await ref
            .read(buyerViewModelProvider.notifier)
            .updateBuyer(buyerId: buyerId);
      }
    }
  }

  Future<void> _handleUploadProfilePicture(File profilePicture) async {
    final buyerId = widget.buyerUiModel?.buyerId;
    if (buyerId != null) {
      await ref
          .read(buyerViewModelProvider.notifier)
          .uploadProfilePicture(
            buyerId: buyerId,
            profilePicture: profilePicture,
          );
    }
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

      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (photo != null) {
        final bool cropped = await _cropAndSetImage(photo.path);
        if (!cropped) {
          setState(() {
            _profileImage = photo;
            _selectedMediaType = "photo";
          });
        }

        if (mounted) {
          _showConfirmProfilePictureSheet();
        }
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
  Future<void> _pickFromGallery() async {
    try {
      final hasPermission = await _requestPermissionFromUser(Permission.photos);

      if (!hasPermission) {
        final permission = await _requestPermissionFromUser(Permission.storage);
        if (!permission) {
          return;
        }
      }
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        final bool cropped = await _cropAndSetImage(image.path);
        if (!cropped) {
          setState(() {
            _profileImage = image;
            _selectedMediaType = "photo";
          });
        }

        if (mounted) {
          _showConfirmProfilePictureSheet();
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

  Future<void> _showConfirmProfilePictureSheet() async {
    if (!mounted || _profileImage == null) {
      return;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // top grabber
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 15),

              // Title
              const Text(
                "Set profile photo",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 15),

              // Avatar preview
              Stack(
                children: [
                  CircleAvatar(
                    radius: 75,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: _profileImage != null
                        ? FileImage(File(_profileImage!.path)) as ImageProvider
                        : null,
                    child: _profileImage == null
                        ? const Icon(Icons.person, size: 75, color: Colors.grey)
                        : null,
                  ),

                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: IconButton(
                      iconSize: 25,
                      icon: const Icon(Icons.crop, color: Colors.blue),
                      onPressed: () async {
                        if (_profileImage != null) {
                          await _cropAndSetImage(_profileImage!.path);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // Filename
              Text(
                _profileImage != null
                    ? File(_profileImage!.path).uri.pathSegments.last
                    : 'Selected photo',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),

              // Action buttons - Remove / Save
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _profileImage = null;
                          _selectedMediaType = null;
                        });
                        AppRoutes.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Remove',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),

                  Expanded(
                    child: GradientElevatedButton(
                      style: GradientElevatedButton.styleFrom(
                        backgroundGradient: AppColors.auctionPrimaryGradient,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 2,
                      ),
                      onPressed: () {
                        AppRoutes.pop(context);
                        if (_profileImage != null) {
                          setState(() {
                            _selectedMediaType = "photo";
                          });
                          _handleUploadProfilePicture(
                            File(_profileImage!.path),
                          );
                        }
                      },
                      child: const Text(
                        "Save",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              GestureDetector(
                onTap: () {
                  AppRoutes.pop(context);
                  _pickMedia();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFFD7CACA),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: AppColors.softShadow,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        "Change photo",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.edit, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool> _cropAndSetImage(String path) async {
    try {
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: path,
        compressQuality: 100,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: "Crop photo",
            toolbarColor: AppColors.primaryColor,
            cropStyle: CropStyle.circle,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
              // CropAspectRatioPresetCustom(),
            ],
          ),
          IOSUiSettings(
            title: 'Crop photo',
            cropStyle: CropStyle.circle,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
              // CropAspectRatioPresetCustom(),
            ],
          ),
          WebUiSettings(
            context: context,
            presentStyle: WebPresentStyle.dialog,
            size: const CropperSize(width: 520, height: 520),
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _profileImage = XFile(croppedFile.path);
          _selectedMediaType = 'photo';
        });
        return true;
      }
    } catch (e) {
      debugPrint("Crop Error: $e");
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final buyerState = ref.watch(buyerViewModelProvider);

    ref.listen<BuyerState>(buyerViewModelProvider, (previous, next) {
      if ((next.buyerStatus == BuyerStatus.error)) {
        SnackbarUtil.showError(
          context,
          next.errorMessage ?? "Error loading current user!",
        );
      } else if (next.buyerStatus == BuyerStatus.updated) {
        SnackbarUtil.showSuccess(
          context,
          "User profile details updated successfully!",
        );
      } else if (next.buyerStatus == BuyerStatus.imageLoaded) {
        SnackbarUtil.showSuccess(
          context,
          "User profile picture uploaded successfully!",
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0xFFDDDDDD),
                    width: 1.0,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 4),
                  ),
                ],
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
                          ),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            color: AppColors.textPrimaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),

                      Expanded(
                        child: Text(
                          "Edit Profile",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.grey.shade200,
                                backgroundImage: _profileImage != null
                                    ? (_selectedMediaType == "photo"
                                          ? FileImage(File(_profileImage!.path))
                                                as ImageProvider
                                          : null)
                                    : (_profilePictureUrl != null &&
                                              _profilePictureUrl!.isNotEmpty
                                          ? NetworkImage(_profilePictureUrl!)
                                                as ImageProvider
                                          : null),
                                child:
                                    (_profileImage == null &&
                                        (_profilePictureUrl == null ||
                                            _profilePictureUrl!.isEmpty))
                                    ? const Icon(
                                        Icons.person,
                                        size: 60,
                                        color: Colors.grey,
                                      )
                                    : null,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Edit profile pic button
                          GestureDetector(
                            onTap: _pickMedia,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Color(0xFFD7CACA),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: AppColors.softShadow,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text(
                                    'Edit profile',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Icon(Icons.edit, size: 16),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 25),

                    // Sign up Form
                    Form(
                      key: _editProfileFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // FullName Text Field
                          const Text(
                            "Full Name",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),

                          CustomTextField(
                            controller: _fullNameController,
                            hintText: "Full Name",
                            labelText: "Full Name",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your name';
                              }
                              if (value.length < 3) {
                                return 'Name must be at least 3 characters';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20),

                          // Username Text Field
                          const Text(
                            "Username",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),

                          CustomTextField(
                            controller: _usernameController,
                            hintText: "Username",
                            labelText: "Username",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your username';
                              }
                              if (value.length < 3) {
                                return 'Username must be at least 3 characters';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20),

                          // Email Text Field
                          const Text(
                            "Email",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),

                          CustomTextField(
                            controller: _emailController,
                            hintText: "Email",
                            labelText: "Email",
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20),

                          // Phone Number Text Field
                          const Text(
                            "Phone Number",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),

                          CustomTextField(
                            controller: _phoneNumberController,
                            hintText: "Phone Number",
                            labelText: "Phone Number",
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter phone number';
                              }
                              if (value.length != 10) {
                                return 'Phone must be 10 digits';
                              }
                              if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                                return 'Only numbers allowed';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20),

                          // Bio Text Area Field
                          const Text(
                            "Bio",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),

                          CustomTextAreaField(
                            controller: _bioController,
                            hintText: "Bio",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter bio';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Fixed Confirm Button
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: const Color(0xFFDDDDDD), width: 1.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 5,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
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
                  onPressed: _handleUpdateDetails,
                  child: buyerState.buyerStatus == BuyerStatus.loading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.blueGrey,
                            ),
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          "Confirm changes",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
