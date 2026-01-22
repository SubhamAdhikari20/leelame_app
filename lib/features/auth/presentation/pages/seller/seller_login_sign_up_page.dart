// lib/features/auth/presentation/pages/seller/seller_login_sign_up_page.dart
import 'package:flutter/material.dart';
import 'package:leelame/app/routes/app_routes.dart';
import 'package:leelame/core/widgets/custom_primary_button.dart';
import 'package:leelame/features/auth/presentation/pages/seller/seller_forgot_password_page.dart';
import 'package:leelame/features/auth/presentation/widgets/custom_auth_text_field.dart';

class SellerLoginSignUpPage extends StatefulWidget {
  const SellerLoginSignUpPage({super.key});

  @override
  State<SellerLoginSignUpPage> createState() => _SellerLoginSignUpPageState();
}

class _SellerLoginSignUpPageState extends State<SellerLoginSignUpPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Login form
  final GlobalKey<FormState> _sellerLoginFormKey = GlobalKey<FormState>();
  final TextEditingController _loginIdentifierController =
      TextEditingController();
  final TextEditingController _loginPasswordController =
      TextEditingController();

  // Sign up form
  final GlobalKey<FormState> _sellerSignUpFormKey = GlobalKey<FormState>();
  final TextEditingController _signFullNameController = TextEditingController();
  final TextEditingController _signEmailController = TextEditingController();
  final TextEditingController _signPhoneNumberController =
      TextEditingController();
  final TextEditingController _signPasswordController = TextEditingController();
  final TextEditingController _signConfirmPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();

    _loginIdentifierController.dispose();
    _loginPasswordController.dispose();

    _signFullNameController.dispose();
    _signEmailController.dispose();
    _signPhoneNumberController.dispose();
    _signPasswordController.dispose();
    _signConfirmPasswordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final bool isDesktop = MediaQuery.of(context).size.width > 600;
    // final double horizontalPadding = isDesktop ? 30 : 20;
    // final double maxWidth = isDesktop ? 550 : double.infinity;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isDesktop = constraints.maxWidth > 600;
            final double horizontalPadding = isDesktop ? 30 : 20;
            final double maxWidth = isDesktop ? 550 : double.infinity;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                vertical: 20,
                horizontal: horizontalPadding,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Column(
                    children: [
                      // Logo
                      Image.asset(
                        "assets/images/leelame_logo_cropped_png.png",
                        width: MediaQuery.of(context).size.width * 0.15,
                        height: MediaQuery.of(context).size.width * 0.15,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 20),

                      // Tab container
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.2),
                              blurRadius: 5,
                              spreadRadius: 1,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          indicator: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF9831E0), Color(0xFFCF2988)],
                            ),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.black,
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          tabs: const [
                            Tab(text: 'Login'),
                            Tab(text: 'Sign Up'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Tab views
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.62,
                        child: TabBarView(
                          controller: _tabController,
                          physics: const BouncingScrollPhysics(),
                          children: [
                            // Login view
                            SingleChildScrollView(
                              padding: EdgeInsetsGeometry.symmetric(
                                vertical: 5,
                              ),
                              child: Form(
                                key: _sellerLoginFormKey,
                                child: Column(
                                  children: [
                                    CustomAuthTextField(
                                      controller: _loginIdentifierController,
                                      hintText: "Email or Phone Number",
                                      labelText: "Email or Phone Number",
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter email or phone number';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    CustomAuthTextField(
                                      controller: _loginPasswordController,
                                      hintText: "Password",
                                      labelText: "Password",
                                      isPassword: true,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter a password';
                                        }
                                        if (value.length < 8) {
                                          return 'Password must be at least 8 characters';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 20),

                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: () {
                                          AppRoutes.push(
                                            context,
                                            const SellerForgotPasswordPage(),
                                          );
                                        },
                                        style: TextButton.styleFrom(
                                          minimumSize: Size.zero,
                                          padding: EdgeInsets.zero,
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: const Text(
                                          "Forgot password?",
                                          style: TextStyle(
                                            color: Color(0xFF155DFC),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),

                                    CustomPrimaryButton(
                                      onPressed: () {
                                        if (_sellerLoginFormKey.currentState!
                                            .validate()) {
                                          // Handle login logic
                                        }
                                      },
                                      text: "Login",
                                    ),
                                    const SizedBox(height: 20),

                                    // Return to buyer
                                    TextButton(
                                      onPressed: () {
                                        AppRoutes.pop(context);
                                      },
                                      style: TextButton.styleFrom(
                                        minimumSize: Size.zero,
                                        padding: EdgeInsets.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: const Text(
                                        "Return to buyer",
                                        style: TextStyle(
                                          color: Color(0xFF2ADA03),
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          decoration: TextDecoration.underline,
                                          decorationColor: Color(0xFF2ADA03),
                                          decorationThickness: 1.5,
                                          height: 1.2,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Sign Up VIEW
                            SingleChildScrollView(
                              padding: EdgeInsetsGeometry.symmetric(
                                vertical: 5,
                              ),
                              child: Form(
                                key: _sellerSignUpFormKey,
                                child: Column(
                                  children: [
                                    CustomAuthTextField(
                                      controller: _signFullNameController,
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
                                    const SizedBox(height: 20),
                                    CustomAuthTextField(
                                      controller: _signEmailController,
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
                                    const SizedBox(height: 20),
                                    CustomAuthTextField(
                                      controller: _signPhoneNumberController,
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
                                        if (!RegExp(
                                          r'^[0-9]+$',
                                        ).hasMatch(value)) {
                                          return 'Only numbers allowed';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    CustomAuthTextField(
                                      controller: _signPasswordController,
                                      hintText: "Password",
                                      labelText: "Password",
                                      isPassword: true,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter a password';
                                        }
                                        if (value.length < 8) {
                                          return 'Password must be at least 8 characters';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    CustomAuthTextField(
                                      controller:
                                          _signConfirmPasswordController,
                                      hintText: "Confirm Password",
                                      labelText: "Confirm Password",
                                      isPassword: true,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please confirm your password';
                                        }
                                        if (value !=
                                            _signPasswordController.text) {
                                          return 'Passwords do not match';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 20),

                                    CustomPrimaryButton(
                                      onPressed: () {
                                        if (_sellerSignUpFormKey.currentState!
                                            .validate()) {
                                          // Handle sign up logic
                                        }
                                      },
                                      text: "Sign up",
                                    ),
                                    const SizedBox(height: 10),

                                    const Text(
                                      "By continuing, you agree to our Terms & Privacy Policy",
                                      style: TextStyle(
                                        color: Color(0xFF9E9E9E),
                                        fontSize: 13,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 20),

                                    // Return to buyer
                                    TextButton(
                                      onPressed: () {
                                        AppRoutes.pop(context);
                                      },
                                      style: TextButton.styleFrom(
                                        minimumSize: Size.zero,
                                        padding: EdgeInsets.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: const Text(
                                        "Return to buyer",
                                        style: TextStyle(
                                          color: Color(0xFF2ADA03),
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          decoration: TextDecoration.underline,
                                          decorationColor: Color(0xFF2ADA03),
                                          decorationThickness: 1.5,
                                          height: 1.2,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
