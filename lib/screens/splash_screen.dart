import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
    _setSystemUI();
  }

  void _setSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 3000));
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionDuration: const Duration(milliseconds: 800),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Subtle clean background accents
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.emerald.withValues(alpha: 0.03),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTidyLogo(),
                  const SizedBox(height: 48),
                  _buildTidyText(),
                  const SizedBox(height: 100),
                  _buildTidyLoading(),
                ],
              ),
            ),
          ),

          // Studio Watermark
          _buildTidyWatermark(),
        ],
      ),
    );
  }

  Widget _buildTidyLogo() {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Image.asset(
            'assets/images/app_icon.png',
            fit: BoxFit.contain, // Ensures nothing is cut off
          ),
        ),
      ),
    )
    .animate()
    .fadeIn(duration: 800.ms)
    .scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutBack);
  }

  Widget _buildTidyText() {
    return Column(
      children: [
        Text(
          'Barangku Dimana?',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppTheme.slate900,
            letterSpacing: -0.5,
          ),
        )
        .animate()
        .fadeIn(delay: 400.ms)
        .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
        
        const SizedBox(height: 12),
        
        Container(
          width: 40,
          height: 3,
          decoration: BoxDecoration(
            color: AppTheme.emerald.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(2),
          ),
        )
        .animate()
        .scaleX(begin: 0, end: 1, delay: 800.ms, duration: 600.ms),
      ],
    );
  }

  Widget _buildTidyLoading() {
    return SizedBox(
      width: 120,
      child: LinearProgressIndicator(
        backgroundColor: Colors.black.withValues(alpha: 0.05),
        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.emerald.withValues(alpha: 0.3)),
        minHeight: 2,
      ),
    )
    .animate()
    .fadeIn(delay: 1000.ms);
  }

  Widget _buildTidyWatermark() {
    return Positioned(
      bottom: 60,
      left: 0,
      right: 0,
      child: Center(
        child: Column(
          children: [
            Text(
              'NEVERLAND STUDIO',
              style: TextStyle(
                color: AppTheme.slate900.withValues(alpha: 0.15),
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'CLEAN MINIMALIST EDITION',
              style: TextStyle(
                color: AppTheme.emerald.withValues(alpha: 0.25),
                fontSize: 8,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    )
    .animate(delay: 1200.ms)
    .fadeIn();
  }
}
