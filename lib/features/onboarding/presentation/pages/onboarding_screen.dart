// lib/features/onboarding/presentation/pages/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:leelame/features/auth/presentation/pages/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      "title": "Welcome to Leelame",
      "subtitle":
          "Nepal's most trusted online auction platform. Bid as much as you like.",
      "image": "assets/images/bid_bg3.jpg",
    },
    {
      "title": "Discover Unique Items",
      "subtitle":
          "Browse thousands of auctions from trusted sellers worldwide. Find rare collectibles, electronics, fashion, and more.",
      "image": "assets/images/wide_range_items.jpg",
    },
    {
      "title": "Secure Payment",
      "subtitle": "Pay easily with Khalti or eSewa. 100% safe and fast",
      "image": "assets/images/secure_payment.jpg",
    },
  ];

  void _completeOnboarding() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final bool isTablet = MediaQuery.of(context).size.width > 600;
    final bool isDesktop = MediaQuery.of(context).size.width > 900;

    final double maxContentWidth = isDesktop
        ? 800
        : (isTablet ? 700 : double.infinity);
    final double horizontalPadding = isDesktop ? 60 : (isTablet ? 45 : 30);
    final double imageHeight = isLandscape
        ? MediaQuery.of(context).size.height * 0.48
        : MediaQuery.of(context).size.height *
              (isDesktop ? 0.5 : (isTablet ? 0.5 : 0.45));
    final double titleFontSize = isDesktop
        ? 40
        : (isTablet ? 35 : (isLandscape ? 25 : 30));

    final double subtitleFontSize = isDesktop
        ? 22
        : (isTablet ? 20 : (isLandscape ? 15 : 17));
    // final double buttonWidth = isDesktop ? 200 : (isTablet ? 150 : 160);
    final double dotActiveWidth = isDesktop ? 35 : 30;
    final double verticalSpacing = isLandscape ? 24 : 48;
    final double smallSpacing = isLandscape ? 16 : 24;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                // Skip Button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.only(top: 15, right: horizontalPadding),
                    child: TextButton(
                      onPressed: _completeOnboarding,
                      child: Text(
                        "Skip",
                        style: TextStyle(
                          color: Color(0xFF2ADA03),
                          fontSize: isTablet ? 20 : 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxContentWidth),
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() => _currentPage = index);
                        },
                        itemCount: _onboardingData.length,
                        itemBuilder: (context, index) {
                          return SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding,
                            ),
                            child: Column(
                              children: [
                                // const Spacer(flex: 2),
                                SizedBox(height: isLandscape ? 10 : 20),

                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    isTablet ? 30 : 20,
                                  ),
                                  child: Image.asset(
                                    _onboardingData[index]["image"]!,
                                    height: imageHeight,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Container(
                                      height: imageHeight,
                                      color: Colors.grey[200],
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        size: 80,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                                // SizedBox(height: 50),
                                SizedBox(height: verticalSpacing),

                                // Title
                                Text(
                                  _onboardingData[index]["title"]!,
                                  style: TextStyle(
                                    fontSize: titleFontSize,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    height: 1.2,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                // SizedBox(height: 20),
                                SizedBox(height: smallSpacing),

                                // Subtitle
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Text(
                                    _onboardingData[index]["subtitle"]!,
                                    style: TextStyle(
                                      fontSize: subtitleFontSize,
                                      color: Colors.black54,
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                // const Spacer(flex: 2),
                                SizedBox(height: isLandscape ? 20 : 40),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // Dots Indicator and Next Button
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 20,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Dots Indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _onboardingData.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            height: 10,
                            width: _currentPage == index ? dotActiveWidth : 10,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? const Color(0xFF2ADA03)
                                  : const Color(0xFFDDDDDD),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                      ),

                      // Next / Get Started Button
                      SizedBox(
                        height: 55,
                        // width: buttonWidth,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_currentPage == _onboardingData.length - 1) {
                              _completeOnboarding();
                            } else {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF2ADA03),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text(
                            _currentPage == _onboardingData.length - 1
                                ? "Get Started"
                                : "Next",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isTablet ? 20 : 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
