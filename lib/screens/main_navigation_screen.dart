import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home_screen.dart';
import 'categories_screen.dart';
import 'favorites_screen.dart';
import 'settings_screen.dart';
import '../theme/app_theme.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CategoriesScreen(),
    const FavoritesScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedTheme(
      data: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
      duration: const Duration(milliseconds: 500),
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          height: 75,
          decoration: BoxDecoration(
            color: isDark ? AppTheme.midnightScaffold : Colors.white,
            border: Border(
              top: BorderSide(
                color: (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.05),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                _buildNavItem(0, Icons.window_rounded, 'Beranda', isDark),
                _buildNavItem(1, Icons.hub_rounded, 'Kategori', isDark),
                _buildNavItem(2, Icons.bookmark_rounded, 'Favorit', isDark),
                _buildNavItem(3, Icons.tune_rounded, 'Pengaturan', isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, bool isDark) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          if (_currentIndex != index) {
            HapticFeedback.lightImpact();
            setState(() {
              _currentIndex = index;
            });
          }
        },
        splashColor: AppTheme.emerald.withValues(alpha: 0.05),
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 300),
              tween: Tween(begin: 1.0, end: isSelected ? 1.15 : 1.0),
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: GradientIcon(
                    icon: icon,
                    isSelected: isSelected,
                    isDark: isDark,
                  ),
                );
              },
            ),
            const SizedBox(height: 4),
            GradientText(
              text: label,
              isSelected: isSelected,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }
}

class GradientIcon extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final bool isDark;

  const GradientIcon({
    Key? key,
    required this.icon,
    required this.isSelected,
    required this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isSelected) {
      return Icon(icon, color: AppTheme.slate400, size: 24);
    }

    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (Rect bounds) {
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.emerald,
            Color(0xFF00E5FF),
          ],
        ).createShader(bounds);
      },
      child: Icon(icon, size: 24),
    );
  }
}

class GradientText extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isDark;

  const GradientText({
    Key? key,
    required this.text,
    required this.isSelected,
    required this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: 10,
      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
      letterSpacing: 0.5,
    );

    if (!isSelected) {
      return Text(text, style: style.copyWith(color: AppTheme.slate400));
    }

    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (Rect bounds) {
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.emerald,
            Color(0xFF00E5FF),
          ],
        ).createShader(bounds);
      },
      child: Text(text, style: style),
    );
  }
}
