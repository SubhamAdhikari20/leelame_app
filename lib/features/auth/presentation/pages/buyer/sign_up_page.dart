// lib/features/auth/presentation/pages/buyer/sign_up_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/app/routes/app_routes.dart';
import 'package:leelame/core/utils/snackbar_util.dart';
import 'package:leelame/features/auth/presentation/pages/buyer/verify_account_registration_page.dart';
import 'package:leelame/features/auth/presentation/pages/seller/login_sign_up_page.dart';
import 'package:leelame/features/auth/presentation/state/buyer_auth_state.dart';
import 'package:leelame/features/auth/presentation/view_model/buyer_auth_view_model.dart';
import 'package:leelame/features/auth/presentation/widgets/custom_auth_text_field.dart';
import 'package:leelame/core/widgets/custom_outlined_button.dart';
import 'package:leelame/core/widgets/custom_primary_button.dart';
import 'package:leelame/features/auth/presentation/widgets/or_divider.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _signUpFormKey = GlobalKey<FormState>();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumber = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _agreeToTerms = false;

  Future<void> _handleSignup() async {
    if (!_agreeToTerms) {
      SnackbarUtil.showError(context, 'Please agree to the Terms & Conditions');
      return;
    }

    if (_signUpFormKey.currentState!.validate()) {
      // Pass the sign up form data to view model
      await ref
          .read(buyerAuthViewModelProvider.notifier)
          .signUp(
            fullName: _fullNameController.text.trim(),
            username: _usernameController.text.trim(),
            email: _emailController.text.trim(),
            phoneNumber: _phoneNumber.text.trim(),
            password: _passwordController.text.trim(),
            termsAccepted: _agreeToTerms,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Buyer Auth State
    final buyerAuthState = ref.watch(buyerAuthViewModelProvider);

    // listen for buyer auth state changes
    ref.listen<BuyerAuthState>(buyerAuthViewModelProvider, (previous, next) {
      if (next.buyerAuthStatus == BuyerAuthStatus.error) {
        SnackbarUtil.showError(context, next.errorMessage ?? "Sign Up Failed!");
      } else if (next.buyerAuthStatus == BuyerAuthStatus.created) {
        // Sign Up Successful
        SnackbarUtil.showSuccess(
          context,
          "Sign Up Successful",
          // next.errorMessage ?? "Sign Up Successful",
        );
        final username =
            next.createdIdentifier?.value ?? _usernameController.text.trim();

        // Navigate to verification page
        AppRoutes.push(
          context,
          VerifyAccountRegistrationPage(username: username),
        );
      }
    });

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
                child: Container(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  // width: double.infinity,
                  // padding: const EdgeInsets.symmetric(
                  //   horizontal: 20,
                  //   vertical: 20,
                  // ),
                  child: Column(
                    children: [
                      // Logo
                      Image.asset(
                        "assets/images/leelame_logo_cropped_png.png",
                        width: MediaQuery.of(context).size.width * 0.15,
                        height: MediaQuery.of(context).size.width * 0.15,
                        // width: isDesktop
                        //     ? MediaQuery.of(context).size.width * 0.30
                        //     : MediaQuery.of(context).size.width * 0.15,
                        // height: isDesktop
                        //     ? MediaQuery.of(context).size.width * 0.30
                        //     : MediaQuery.of(context).size.width * 0.15,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 20),

                      // Sign up Form
                      Form(
                        key: _signUpFormKey,
                        child: Column(
                          children: [
                            // FullName Text Field
                            CustomAuthTextField(
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
                            CustomAuthTextField(
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
                            CustomAuthTextField(
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

                            // Contact Text Field
                            CustomAuthTextField(
                              controller: _phoneNumber,
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

                            // Password Text Field
                            CustomAuthTextField(
                              controller: _passwordController,
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
                            SizedBox(height: 20),

                            // Confirm Password Text Field
                            CustomAuthTextField(
                              controller: _confirmPasswordController,
                              hintText: "Confirm Password",
                              labelText: "Confirm Password",
                              isPassword: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm your password';
                                }
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 10),

                            // Terms and conditions Checkbox
                            Row(
                              children: [
                                Checkbox(
                                  value: _agreeToTerms,
                                  onChanged: (value) {
                                    setState(() {
                                      _agreeToTerms = value ?? false;
                                    });
                                  },
                                  activeColor: const Color(0xFF4CAF50),
                                  side: const BorderSide(
                                    color: Color(0xFF999999),
                                    width: 2,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    "I agree to all terms and conditions",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),

                            // Sign up Button
                            CustomPrimaryButton(
                              onPressed: _handleSignup,
                              text: "Sign up",
                              isLoading:
                                  buyerAuthState.buyerAuthStatus ==
                                  BuyerAuthStatus.loading,
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                      // OR Divider
                      const OrDivider(),
                      const SizedBox(height: 20),

                      // Google Sign in
                      CustomOutlinedButton(
                        onPressed: () {},
                        text: "Sign in with Google",
                        prefixIcon: Image.asset(
                          "assets/icons/google_icon.png",
                          height: 25,
                          width: 25,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Already have an account?
                      const Text(
                        "Already have an account?",
                        style: TextStyle(
                          color: Color(0xFF666666),
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Login
                      CustomOutlinedButton(
                        onPressed: () {
                          AppRoutes.pop(context);
                        },
                        text: "Login",
                      ),
                      const SizedBox(height: 20),

                      // Become a seller
                      TextButton(
                        onPressed: () {
                          AppRoutes.push(context, const LoginSignUpPage());
                        },
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          "Become a seller",
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
            );
          },
        ),
      ),
    );
  }
}
