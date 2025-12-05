// lib/screens/reset_passsword_screen.dart
import 'package:flutter/material.dart';
import 'package:leelame/screens/login_screen.dart';
import 'package:leelame/widgets/custom_auth_text_field.dart';
import 'package:leelame/widgets/custom_primary_button.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _resetPasswordFormKey = GlobalKey<FormState>();

  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Image.asset(
          "assets/images/leelame_logo_cropped_png.png",
          height: isTablet ? 70 : 55,
          fit: BoxFit.contain,
        ),
      ),
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
                        "Enter new password",
                        style: TextStyle(
                          fontSize: isDesktop ? 35 : (isTablet ? 30 : 20),
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.start,
                      ),
                      SizedBox(height: 25),

                      // Forgot Password Form
                      Form(
                        key: _resetPasswordFormKey,
                        child: Column(
                          children: [
                            // New Password Text Field
                            CustomAuthTextField(
                              controller: newPasswordController,
                              hintText: "New Password",
                              labelText: "New Password",
                              keyboardType: TextInputType.emailAddress,
                            ),
                            SizedBox(height: 20),

                            // Confirm Password Text Field
                            CustomAuthTextField(
                              controller: confirmPasswordController,
                              hintText: "Confirm Password",
                              labelText: "Confirm Password",
                              keyboardType: TextInputType.emailAddress,
                            ),
                            SizedBox(height: 40),

                            // Reset Password Button
                            CustomPrimaryButton(
                              onPressed: () {
                                if (_resetPasswordFormKey.currentState
                                        ?.validate() ==
                                    true) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LoginScreen(),
                                    ),
                                  );
                                }
                              },
                              text: "Reset",
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
