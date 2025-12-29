import 'package:flutter/material.dart';
import 'package:leelame/app/routes/app_routes.dart';
import 'package:leelame/features/auth/presentation/pages/login_screen.dart';
import 'package:leelame/widgets/custom_auth_text_field.dart';
import 'package:leelame/widgets/custom_outlined_button.dart';
import 'package:leelame/widgets/custom_primary_button.dart';
import 'package:leelame/widgets/or_divider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _signUpFormKey = GlobalKey<FormState>();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _agreeToTerms = false;
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
                              controller: fullNameController,
                              hintText: "Full Name",
                              labelText: "Full Name",
                            ),
                            SizedBox(height: 20),

                            // Username Text Field
                            CustomAuthTextField(
                              controller: usernameController,
                              hintText: "Username",
                              labelText: "Username",
                            ),
                            SizedBox(height: 20),

                            // Email Text Field
                            CustomAuthTextField(
                              controller: emailController,
                              hintText: "Email",
                              labelText: "Email",
                              keyboardType: TextInputType.emailAddress,
                            ),
                            SizedBox(height: 20),

                            // Contact Text Field
                            CustomAuthTextField(
                              controller: contactController,
                              hintText: "Phone Number",
                              labelText: "Phone Number",
                              keyboardType: TextInputType.phone,
                            ),
                            SizedBox(height: 20),

                            // Password Text Field
                            CustomAuthTextField(
                              controller: passwordController,
                              hintText: "Password",
                              labelText: "Password",
                              isPassword: true,
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
                              onPressed: () {
                                if (_signUpFormKey.currentState?.validate() ==
                                    true) {}
                              },
                              text: "Sign up",
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
                          AppRoutes.push(context, const LoginScreen());
                        },
                        text: "Login",
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
