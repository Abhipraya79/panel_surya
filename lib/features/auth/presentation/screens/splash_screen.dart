import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radius.dart';
import 'login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../navigation/main_navigation.dart';
import '../../../../core/constants/app_config.dart';
import '../../../../core/services/network_error_handler.dart';
import '../../../settings/presentation/screens/connection_test_screen.dart';

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

  // Connection check state variables
  bool _isCheckingConnection = true;
  bool _connectionSuccess = false;
  String _statusText = 'Menghubungkan ke server...';
  String? _connectionError;
  bool _showDiagnosticsButton = false;

  @override
  void initState() {
    super.initState();

    // Force logout on startup (cold start / restart)
    FirebaseAuth.instance.signOut();

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

    _checkBackendConnection();
  }

  Future<void> _checkBackendConnection() async {
    if (!mounted) return;
    setState(() {
      _isCheckingConnection = true;
      _connectionSuccess = false;
      _statusText = 'Memverifikasi koneksi backend...';
      _connectionError = null;
      _showDiagnosticsButton = false;
    });

    _loadingController.reset();
    _loadingController.forward(from: 0.0);

    final client = http.Client();
    final uri = Uri.parse('${AppConfig.socketUrl}/health');

    try {
      debugPrint('[API REQUEST] GET $uri');
      final response = await client.get(uri).timeout(
            const Duration(seconds: 5),
          );

      debugPrint('[API RESPONSE] GET $uri - Code ${response.statusCode}');

      if (response.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          _isCheckingConnection = false;
          _connectionSuccess = true;
          _statusText = 'Backend Connected';
        });

        // Let the progress finish and then navigate
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) {
          _navigateToNextScreen();
        }
      } else {
        throw Exception('HTTP Status ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[API ERROR] GET $uri - Exception $e');
      if (!mounted) return;
      _loadingController.stop(); // Stop progress indicator
      setState(() {
        _isCheckingConnection = false;
        _connectionSuccess = false;
        _statusText = 'Koneksi Gagal ke Server';
        _connectionError = NetworkErrorHandler.getFriendlyMessage(e);
        _showDiagnosticsButton = true;
      });
    } finally {
      client.close();
    }
  }

  void _navigateToNextScreen() {
    if (!mounted) return;
    
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
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
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: _buildConnectionWidget(),
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

  Widget _buildConnectionWidget() {
    if (_connectionError != null) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.dangerLight.withOpacity(0.4),
          borderRadius: AppRadius.lg,
          border: Border.all(color: AppColors.danger.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(LucideIcons.wifiOff, color: AppColors.danger, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _statusText,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppColors.danger,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              _connectionError!,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: _checkBackendConnection,
                    icon: const Icon(LucideIcons.refreshCw, size: 14),
                    label: Text(
                      'Coba Lagi',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ConnectionTestScreen(),
                        ),
                      );
                    },
                    icon: const Icon(LucideIcons.network, size: 14),
                    label: Text(
                      'Uji Koneksi',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.danger,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.md),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        AnimatedBuilder(
          animation: _loadingProgress,
          builder: (_, __) => ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: _loadingProgress.value,
              minHeight: 4,
              backgroundColor: const Color(0xFFFCE4EC),
              valueColor: AlwaysStoppedAnimation<Color>(
                _connectionSuccess ? AppColors.success : AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          _statusText,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _connectionSuccess ? AppColors.success : const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}
