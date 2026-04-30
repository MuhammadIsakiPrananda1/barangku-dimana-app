import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home_screen.dart';
import 'stats_screen.dart';
import 'history_screen.dart';
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
    const StatsScreen(),
    const HistoryScreen(),
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
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.05),
                  width: 1,
                ),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                if (_currentIndex != index) {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _currentIndex = index;
                  });
                }
              },
              backgroundColor: isDark ? AppTheme.midnightScaffold : Colors.white,
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              selectedItemColor: AppTheme.emerald,
              unselectedItemColor: isDark ? Colors.white54 : AppTheme.slate400,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 0.5),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 10, letterSpacing: 0.5),
              showUnselectedLabels: true,
              items: const [
                BottomNavigationBarItem(
                  icon: Padding(padding: EdgeInsets.only(bottom: 6), child: Icon(Icons.home_outlined)),
                  activeIcon: Padding(padding: EdgeInsets.only(bottom: 6), child: Icon(Icons.home_rounded)),
                  label: 'Beranda',
                ),
                BottomNavigationBarItem(
                  icon: Padding(padding: EdgeInsets.only(bottom: 6), child: Icon(Icons.bar_chart_rounded)),
                  activeIcon: Padding(padding: EdgeInsets.only(bottom: 6), child: Icon(Icons.bar_chart_rounded)),
                  label: 'Statistik',
                ),
                BottomNavigationBarItem(
                  icon: Padding(padding: EdgeInsets.only(bottom: 6), child: Icon(Icons.history_rounded)),
                  activeIcon: Padding(padding: EdgeInsets.only(bottom: 6), child: Icon(Icons.history_rounded)),
                  label: 'Riwayat',
                ),
                BottomNavigationBarItem(
                  icon: Padding(padding: EdgeInsets.only(bottom: 6), child: Icon(Icons.settings_outlined)),
                  activeIcon: Padding(padding: EdgeInsets.only(bottom: 6), child: Icon(Icons.settings_rounded)),
                  label: 'Pengaturan',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

