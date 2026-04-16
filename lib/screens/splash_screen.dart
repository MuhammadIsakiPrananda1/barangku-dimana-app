import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../theme/app_theme.dart';
import 'main_navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _version = "";

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
    _navigateToHome();
    _setSystemUI();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _version = info.version;
      });
    }
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
        pageBuilder: (_, __, ___) => const MainNavigationScreen(),
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
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTidyLogo(),
                ],
              ),
            ),
          ),

          // Loading & Footer
          _buildTidyFooter(),
        ],
      ),
    );
  }

  Widget _buildTidyLogo() {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(48), // Rounded corners for the shadow/clip
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 40,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(48),
        child: Image.asset(
          'assets/images/app_icon.png',
          fit: BoxFit.cover,
        ),
      ),
    )
    .animate()
    .fadeIn(duration: 1200.ms, curve: Curves.easeOut)
    .scale(begin: const Offset(0.8, 0.8), duration: 1000.ms, curve: Curves.easeOutBack)
    .shimmer(delay: 2000.ms, duration: 2000.ms, color: Colors.white.withValues(alpha: 0.4));
  }

  Widget _buildTidyFooter() {
    return Positioned(
      bottom: 50,
      left: 0,
      right: 0,
      child: Center(
        child: Column(
          children: [
            // Aesthetic Minimalist Loading
            SizedBox(
              width: 100,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  backgroundColor: AppTheme.emerald.withValues(alpha: 0.05),
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.emerald.withValues(alpha: 0.2)),
                  minHeight: 2,
                ),
              ),
            )
            .animate()
            .fadeIn(delay: 1500.ms, duration: 800.ms)
            .scaleX(begin: 0.5, curve: Curves.easeOut),
            
            const SizedBox(height: 32),
            
            Text(
              'NEVERLAND STUDIO',
              style: TextStyle(
                color: AppTheme.slate900.withValues(alpha: 0.2),
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
            if (_version.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'V $_version',
                style: TextStyle(
                  color: AppTheme.emerald.withValues(alpha: 0.3),
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ],
          ],
        ),
      ),
    )
    .animate(delay: 1000.ms)
    .fadeIn(duration: 1200.ms);
  }
}
