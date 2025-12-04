// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:leelame/widgets/custom_outlined_button.dart';
import 'package:leelame/widgets/custom_primary_button.dart';
import 'package:leelame/widgets/custom_auth_text_field.dart';
import 'package:leelame/widgets/or_divider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginFormKey = GlobalKey<FormState>();

  final TextEditingController identifierController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Form(
            key: _loginFormKey,
            child: Column(
              children: [
                // Logo
                Image.asset(
                  "assets/images/leelame_logo_cropped_png.png",
                  width: MediaQuery.of(context).size.width * 0.25,
                  height: MediaQuery.of(context).size.width * 0.25,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 40),

                // Username or Email Text Field
                CustomAuthTextField(
                  controller: identifierController,
                  hintText: "Username or Email",
                ),
                SizedBox(height: 20),

                // Password Text Field
                CustomAuthTextField(
                  controller: passwordController,
                  hintText: "Password",
                  isPassword: true,
                ),
                SizedBox(height: 20),

                // Forgot Password Text Button
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                CustomPrimaryButton(onPressed: () {}, text: "Login"),
                const SizedBox(height: 20),

                // OR Divider
                const OrDivider(),
                const SizedBox(height: 20),

                // Google Sign in
                CustomOutlinedButton(
                  onPressed: () {},
                  text: "Sign in with Google",
                  prefixIcon: Image.asset(
                    "assets/icons/google_icon.png", // Add this asset (SVG/PNG of Google logo)
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
                  style: TextStyle(color: Color(0xFF666666), fontSize: 18),
                ),
                const SizedBox(height: 15),

                // Create account
                CustomOutlinedButton(onPressed: () {}, text: "Create account"),
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
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
