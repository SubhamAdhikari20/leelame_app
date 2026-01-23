// lib/features/auth/presentation/pages/buyer/buyer_login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/app/routes/app_routes.dart';
import 'package:leelame/core/utils/snackbar_util.dart';
import 'package:leelame/features/auth/presentation/pages/buyer/buyer_forgot_password_page.dart';
import 'package:leelame/features/auth/presentation/pages/buyer/buyer_sign_up_page.dart';
import 'package:leelame/features/auth/presentation/pages/seller/seller_login_sign_up_page.dart';
import 'package:leelame/features/auth/presentation/states/buyer_auth_state.dart';
import 'package:leelame/features/auth/presentation/view_models/buyer_auth_view_model.dart';
import 'package:leelame/features/buyer/presentation/pages/dashboard_page.dart';
import 'package:leelame/core/widgets/custom_outlined_button.dart';
import 'package:leelame/core/widgets/custom_primary_button.dart';
import 'package:leelame/features/auth/presentation/widgets/custom_auth_text_field.dart';
import 'package:leelame/features/auth/presentation/widgets/or_divider.dart';

class BuyerLoginPage extends ConsumerStatefulWidget {
  const BuyerLoginPage({super.key});

  @override
  ConsumerState<BuyerLoginPage> createState() => _BuyerLoginPageState();
}

class _BuyerLoginPageState extends ConsumerState<BuyerLoginPage> {
  final _loginFormKey = GlobalKey<FormState>();

  final TextEditingController identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _handleLogin() async {
    if (_loginFormKey.currentState!.validate()) {
      // Pass the login form data to view model
      await ref
          .read(buyerAuthViewModelProvider.notifier)
          .login(
            identifier: identifierController.text.trim(),
            password: _passwordController.text.trim(),
            role: "buyer".trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Buyer Auth State
    final buyerAuthState = ref.watch(buyerAuthViewModelProvider);

    // listen for buyer auth state changes
    ref.listen<BuyerAuthState>(buyerAuthViewModelProvider, (previous, next) {
      if (next.buyerAuthStatus == BuyerAuthStatus.error &&
          next.errorMessage != null) {
        SnackbarUtil.showError(context, next.errorMessage ?? "Login Failed!");
      } else if (next.buyerAuthStatus == BuyerAuthStatus.authenticated) {
        // Login Successful
        SnackbarUtil.showSuccess(
          context,
          "Login Successful",
          // next.errorMessage ?? "Login Successful",
        );

        // Navigate to dashboard
        AppRoutes.pushReplacement(context, const DashboardPage());
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
                  // padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    children: [
                      // Logo
                      Image.asset(
                        "assets/images/leelame_logo_cropped_png.png",
                        width: MediaQuery.of(context).size.width * 0.25,
                        height: MediaQuery.of(context).size.width * 0.25,
                        // width: isDesktop
                        //     ? MediaQuery.of(context).size.width * 0.40
                        //     : MediaQuery.of(context).size.width * 0.25,
                        // height: isDesktop
                        //     ? MediaQuery.of(context).size.width * 0.40
                        //     : MediaQuery.of(context).size.width * 0.25,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 40),

                      // Login Form
                      Form(
                        key: _loginFormKey,
                        child: Column(
                          children: [
                            // Username or Email Text Field
                            CustomAuthTextField(
                              controller: identifierController,
                              hintText: "Username or Email",
                              labelText: "Username or Email",
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter username or email';
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

                            // Forgot Password Text Button
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  AppRoutes.push(
                                    context,
                                    const BuyerForgotPasswordPage(),
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
                            SizedBox(height: 20),

                            // Login Button
                            CustomPrimaryButton(
                              onPressed: _handleLogin,
                              text: "Login",
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
                        // If you don't have the asset yet, temporarily use:
                        // prefixIcon: const Text("G ", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
                      ),
                      const SizedBox(height: 50),

                      // Don't have an account?
                      const Text(
                        "Don't have an account?",
                        style: TextStyle(
                          color: Color(0xFF666666),
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Create account
                      CustomOutlinedButton(
                        onPressed: () {
                          AppRoutes.push(context, const BuyerSignUpPage());
                        },
                        text: "Create account",
                      ),
                      const SizedBox(height: 20),

                      // Become a seller
                      TextButton(
                        onPressed: () {
                          AppRoutes.push(
                            context,
                            const SellerLoginSignUpPage(),
                          );
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
