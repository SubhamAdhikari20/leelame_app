// lib/features/auth/presentation/pages/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:leelame/app/routes/app_routes.dart';
import 'package:leelame/features/auth/presentation/pages/buyer_verify_account_registration_page.dart';
import 'package:leelame/features/auth/presentation/widgets/custom_auth_text_field.dart';
import 'package:leelame/core/widgets/custom_primary_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _forgotPasswordFormKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.width > 600;
    // final bool isDesktop = MediaQuery.of(context).size.width > 900;
    // final double horizontalPadding = isDesktop ? 40 : (isTablet ? 30 : 20);
    // final double maxWidth = isDesktop
    //     ? 800
    //     : (isTablet ? 700 : double.infinity);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => AppRoutes.pop(context),
        ),
        centerTitle: true,
        title: Image.asset(
          "assets/images/leelame_logo_cropped_png.png",
          height: isTablet ? 70 : 55,
          fit: BoxFit.contain,
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth > 600;
            final bool isDesktop = constraints.maxWidth > 900;
            final double horizontalPadding = isTablet ? 30 : 20;
            final double maxWidth = isTablet ? 550 : double.infinity;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                vertical: 10,
                horizontal: horizontalPadding,
              ),
              child: Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Forgot Password",
                        style: TextStyle(
                          fontSize: isDesktop ? 35 : (isTablet ? 30 : 20),
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 5),

                      Text(
                        "Enter your email or phone number",
                        style: TextStyle(
                          fontSize: isDesktop ? 25 : (isTablet ? 20 : 16),
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 25),

                      // Forgot Password Form
                      Form(
                        key: _forgotPasswordFormKey,
                        child: Column(
                          children: [
                            // Email Text Field
                            CustomAuthTextField(
                              controller: emailController,
                              hintText: "Email",
                              labelText: "Email",
                              keyboardType: TextInputType.emailAddress,
                            ),
                            SizedBox(height: 40),

                            // Send Code Button
                            CustomPrimaryButton(
                              onPressed: () {
                                if (_forgotPasswordFormKey.currentState
                                        ?.validate() ==
                                    true) {
                                  AppRoutes.push(
                                    context,
                                    BuyerVerifyAccountRegistrationPage(
                                      username: "",
                                    ),
                                  );
                                }
                              },
                              text: "Send Code",
                              isLoading: _loading,
                            ),
                            const SizedBox(height: 20),
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
