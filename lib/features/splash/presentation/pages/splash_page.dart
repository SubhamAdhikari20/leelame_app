// lib/features/splash/presentation/pages/splash_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/app/routes/app_routes.dart';
import 'package:leelame/core/services/storage/user_session_service.dart';
import 'package:leelame/features/buyer/presentation/pages/dashboard_page.dart';
import 'package:leelame/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:leelame/features/seller/presentation/pages/seller_dashboard_page.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  Animation<double>? _scaleAnimation;
  Animation<double>? _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
    _navigateToNext();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1800),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Interval(0.3, 1.0)),
    );
  }

  void _startAnimations() async {
    _animationController.forward();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    // Check if user is already logged in
    final userSessionService = ref.read(userSessionServiceProvider);
    final isLoggedIn = userSessionService.isLoggedIn();
    final role = userSessionService.getUserRole();

    if (isLoggedIn && (role == "buyer")) {
      AppRoutes.pushReplacement(context, const DashboardPage());
    } else if (isLoggedIn && (role == "seller")) {
      AppRoutes.pushReplacement(context, const SellerDashboardPage());
    } else {
      AppRoutes.push(context, const OnboardingPage());
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final bool isPhone = MediaQuery.of(context).size.shortestSide < 600;
    if (isPhone) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _opacityAnimation ?? AlwaysStoppedAnimation(1.0),
          child: ScaleTransition(
            scale: _scaleAnimation ?? AlwaysStoppedAnimation(1.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/leelame_logo_cropped_png.png",
                  width: MediaQuery.of(context).size.width * 0.3,
                  height: MediaQuery.of(context).size.width * 0.3,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 60),
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blueGrey),
                  strokeWidth: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
