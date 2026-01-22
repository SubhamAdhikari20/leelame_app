// lib/features/auth/presentation/pages/buyer/verify_account_registration_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/app/routes/app_routes.dart';
import 'package:leelame/core/utils/snackbar_util.dart';
import 'package:leelame/features/auth/presentation/pages/buyer/login_page.dart';
import 'package:leelame/core/widgets/custom_primary_button.dart';
import 'package:leelame/features/auth/presentation/state/buyer_auth_state.dart';
import 'package:leelame/features/auth/presentation/view_model/buyer_auth_view_model.dart';

class VerifyAccountRegistrationPage extends ConsumerStatefulWidget {
  final String username;
  const VerifyAccountRegistrationPage({super.key, required this.username});

  @override
  ConsumerState<VerifyAccountRegistrationPage> createState() =>
      _VerifyAccountRegistrationPageState();
}

class _VerifyAccountRegistrationPageState
    extends ConsumerState<VerifyAccountRegistrationPage> {
  final _verifyAccountRegistrationFormKey = GlobalKey<FormState>();
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _handleAccountVerification() async {
    if (_verifyAccountRegistrationFormKey.currentState!.validate()) {
      final otp = _controllers.map((c) => c.text).join();
      await ref
          .read(buyerAuthViewModelProvider.notifier)
          .verifyAccountRegistration(username: widget.username, otp: otp);
    }
  }

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 56,
      height: 56,
      child: TextFormField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        decoration: InputDecoration(
          counterText: "",
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF2ADA03), width: 2),
          ),
        ),
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        onChanged: (value) {
          if (value.length == 1 && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final buyerAuthState = ref.watch(buyerAuthViewModelProvider);

    ref.listen<BuyerAuthState>(buyerAuthViewModelProvider, (previous, next) {
      if (next.buyerAuthStatus == BuyerAuthStatus.error) {
        SnackbarUtil.showError(
          context,
          next.errorMessage ?? "Verification Failed!",
        );
      } else if (next.buyerAuthStatus == BuyerAuthStatus.verified) {
        SnackbarUtil.showSuccess(context, "Verification Successful");

        // Navigate to Login
        AppRoutes.pushReplacement(context, const LoginPage());
      }
    });

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
          onPressed: () => AppRoutes.pop(context),
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
                        "Account Registration Verification",
                        style: TextStyle(
                          fontSize: isDesktop ? 35 : (isTablet ? 30 : 20),
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.start,
                      ),
                      SizedBox(height: 5),

                      // Subtitle
                      Text(
                        "Enter verification code",
                        style: TextStyle(
                          fontSize: isDesktop ? 25 : (isTablet ? 20 : 16),
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.start,
                      ),
                      SizedBox(height: 30),

                      // 6 OTP Boxes
                      Form(
                        key: _verifyAccountRegistrationFormKey,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(6, _buildOtpBox),
                        ),
                      ),

                      SizedBox(height: 40),

                      // Verify Button
                      CustomPrimaryButton(
                        onPressed: _handleAccountVerification,
                        text: "Verify",
                        isLoading:
                            buyerAuthState.buyerAuthStatus ==
                            BuyerAuthStatus.loading,
                      ),

                      SizedBox(height: 30),

                      // Resend Code
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Didn't receive a code? ",
                            style: TextStyle(
                              fontSize: isTablet ? 17 : 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),

                          TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Code resent!")),
                              );
                            },
                            child: Text(
                              "Resend",
                              style: TextStyle(
                                color: const Color(0xFF4CAF50),
                                fontSize: isTablet ? 17 : 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
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
