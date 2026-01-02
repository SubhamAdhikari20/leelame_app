// lib/features/auth/presentation/pages/login_screen.dart
import 'package:flutter/material.dart';
import 'package:leelame/app/routes/app_routes.dart';
import 'package:leelame/features/auth/presentation/pages/forgot_password_screen.dart';
import 'package:leelame/features/auth/presentation/pages/buyer_sign_up_page.dart';
import 'package:leelame/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:leelame/core/widgets/custom_outlined_button.dart';
import 'package:leelame/core/widgets/custom_primary_button.dart';
import 'package:leelame/features/auth/presentation/widgets/custom_auth_text_field.dart';
import 'package:leelame/features/auth/presentation/widgets/or_divider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginFormKey = GlobalKey<FormState>();

  final TextEditingController identifierController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final bool _loading = false;

  @override
  Widget build(BuildContext context) {
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
                            ),
                            SizedBox(height: 20),

                            // Password Text Field
                            CustomAuthTextField(
                              controller: passwordController,
                              hintText: "Password",
                              labelText: "Password",
                              isPassword: true,
                            ),
                            SizedBox(height: 20),

                            // Forgot Password Text Button
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  AppRoutes.push(
                                    context,
                                    const ForgotPasswordScreen(),
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
                              onPressed: () {
                                if (_loginFormKey.currentState?.validate() ==
                                    true) {
                                  AppRoutes.pushReplacement(
                                    context,
                                    const DashboardPage(),
                                  );
                                }
                              },
                              text: "Login",
                              isLoading: _loading,
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
                        onPressed: () {},
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
