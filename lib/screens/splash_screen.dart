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
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 2600));
    if (!mounted) return;

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Force Light Mode for Splash Screen only
    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        backgroundColor: const Color(0xFFF0FDF7),
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                Brightness.dark, // Dark icons for light background
            systemNavigationBarColor: Color(0xFFF8FAFC),
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
          child: Stack(
            children: [
              // Light gradient background — fresh & bright
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFECFDF5), // very light emerald tint
                      Color(0xFFF8FAFC), // clean white-slate
                      Color(0xFFEFF6FF), // subtle blue hint at bottom
                    ],
                    stops: [0.0, 0.55, 1.0],
                  ),
                ),
              ),

              // Decorative top wave / blob
              Positioned(
                top: -size.height * 0.08,
                left: -size.width * 0.2,
                child: Container(
                  width: size.width * 1.4,
                  height: size.height * 0.45,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0, -0.6),
                      radius: 0.9,
                      colors: [
                        AppTheme.emerald.withValues(alpha: 0.12),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Subtle dot grid
              Positioned.fill(
                child: CustomPaint(painter: _LightDotGridPainter()),
              ),

              // Decorative circle top-right accent
              Positioned(
                top: 40,
                right: -40,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.emerald.withValues(alpha: 0.07),
                  ),
                ),
              ),

              // Decorative circle bottom-left accent
              Positioned(
                bottom: 60,
                left: -60,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.cyberBlue.withValues(alpha: 0.06),
                  ),
                ),
              ),

              // Main content
              SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildIconSection(),
                      const SizedBox(height: 36),
                      _buildAppName(),
                      const SizedBox(height: 10),
                      _buildTagline(),
                      const SizedBox(height: 72),
                      _buildLoader(),
                    ],
                  ),
                ),
              ),

              // Bottom version
              Positioned(
                bottom: 32,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Text(
                      'Neverland Studio',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.slate500,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'v1.2.0',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.slate400,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ).animate(delay: 1000.ms).fadeIn(duration: 600.ms),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconSection() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer soft glow
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppTheme.emerald.withValues(alpha: 0.12),
                Colors.transparent,
              ],
            ),
          ),
        )
            .animate()
            .scale(
                begin: const Offset(0.4, 0.4),
                duration: 900.ms,
                curve: Curves.easeOutCubic)
            .fadeIn(duration: 700.ms),

        // Simple pulsing ring - reduced complexity
        Container(
          width: 112,
          height: 112,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.emerald.withValues(alpha: 0.12),
              width: 1.2,
            ),
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(
              begin: const Offset(1.0, 1.0),
              end: const Offset(1.04, 1.04), // Subtle scale only
              duration: 2000.ms,
              curve: Curves.easeInOut,
            )
            .fadeIn(duration: 700.ms),

        // Icon card — light version
        Container(
          width: 92,
          height: 92,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: Colors.white,
            border: Border.all(
              color: AppTheme.emerald.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Image.asset(
              'assets/images/app_icon.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.emerald, const Color(0xFF059669)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(26),
                ),
                child: const Icon(Icons.inventory_2_rounded,
                    color: Colors.white, size: 44),
              ),
            ),
          ),
        )
            .animate()
            .scale(
                begin: const Offset(0.3, 0.3),
                duration: 750.ms,
                curve: Curves.easeOutBack)
            .fadeIn(duration: 500.ms),
      ],
    );
  }

  Widget _buildAppName() {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'Barangku ',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: AppTheme.slate900,
              letterSpacing: -0.8,
            ),
          ),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
              ).createShader(bounds),
              child: const Text(
                'Dimana?',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.8,
                ),
              ),
            ),
          ),
        ],
      ),
    )
        .animate(delay: 350.ms)
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.25, end: 0, curve: Curves.easeOutCubic);
  }

  Widget _buildTagline() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.emerald,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'Catat. Simpan. Temukan.',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.slate500,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.emerald,
          ),
        ),
      ],
    )
        .animate(delay: 550.ms)
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.15, end: 0);
  }

  Widget _buildLoader() {
    return Column(
      children: [
        SizedBox(
          width: 100,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              backgroundColor: AppTheme.slate200,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.emerald),
              minHeight: 3,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Memuat...',
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.slate400,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ).animate(delay: 750.ms).fadeIn(duration: 500.ms);
  }
}

// Subtle dot grid for light background
class _LightDotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF10B981).withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;

    const spacing = 48.0; // Increased spacing (less dots)
    const radius = 1.0; // Smaller radius

    for (double x = spacing / 2; x < size.width; x += spacing) {
      for (double y = spacing / 2; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
