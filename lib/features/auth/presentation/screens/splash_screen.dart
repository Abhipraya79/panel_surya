import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radius.dart';
import 'login_screen.dart';
import '../../data/services/auth_service.dart';
import '../../../../navigation/main_navigation.dart';

/// Redesigned premium Splash Screen for SolarCare IoT.
/// Integrates assets/images/panel.jpeg seamlessly with a clean,
/// modern, and professional aesthetic.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _loadingController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _loadingProgress;

  @override
  void initState() {
    super.initState();

    // Fade animation (duration 400ms)
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    // Scale animation for hero image (duration 600ms)
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );

    // Loading progress animation (duration 2400ms)
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 2400),
      vsync: this,
    );
    _loadingProgress = CurvedAnimation(
      parent: _loadingController,
      curve: Curves.easeInOut,
    );

    // Trigger animations sequentially
    _fadeController.forward().then((_) => _scaleController.forward());
    
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _loadingController.forward();
    });

    // Navigate to next screen after progress finishes
    Future.delayed(const Duration(milliseconds: 2800), _navigateToNextScreen);
  }

  void _navigateToNextScreen() {
    if (!mounted) return;
    
    // Check if user session is already active
    final user = AuthService.currentUser;
    final targetScreen = user != null ? const MainNavigation() : const LoginScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => targetScreen,
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFFFF0F5), // Soft Light Pink
              Color(0xFFFFF8FB), // App Background Pink
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // ─── Center Hero Image Container ─────────────────────────
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Center(
                      child: Container(
                        width: isTablet ? size.width * 0.45 : size.width * 0.7,
                        height: isTablet ? size.width * 0.45 : size.width * 0.7,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: AppRadius.xxl,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.04),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                          border: Border.all(
                            color: const Color(0xFFFCE4EC).withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: ClipRRect(
                          borderRadius: AppRadius.xl,
                          child: Image.asset(
                            AppAssets.solarPanel,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // ─── Application Logo Title ──────────────────────────────
                  Text(
                    'SOLARCARE',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1F2937),
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // ─── Professional Subtitle ───────────────────────────────
                  Text(
                    'Solar Panel Cooling & Cleaning System',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ─── Short Description Bullets ────────────────────────────
                  Text(
                    'Real-time Monitoring • Smart Cooling • Automated Cleaning',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF6B7280),
                      height: 1.5,
                    ),
                  ),

                  const Spacer(flex: 3),

                  // ─── Bottom Loading and Progress Indicator ───────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: [
                        AnimatedBuilder(
                          animation: _loadingProgress,
                          builder: (_, __) => ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: LinearProgressIndicator(
                              value: _loadingProgress.value,
                              minHeight: 4,
                              backgroundColor: const Color(0xFFFCE4EC),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Loading system data...',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // ─── Version Indicator ───────────────────────────────────
                  Text(
                    'Version 1.0.0',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
