import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({super.key, this.size = 44});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final logoPath = 'assets/images/logo_barangku.svg';
    
    // Check if SVG exists, otherwise show fallback icon
    return FutureBuilder<bool>(
      future: _assetExists(logoPath),
      builder: (context, snapshot) {
        if (snapshot.data == true) {
          return SvgPicture.asset(
            logoPath,
            width: size,
            height: size,
          );
        }
        
        // Fallback icon with gradient
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF39BFA7), const Color(0xFF7DD3FC)]
                  : [const Color(0xFF006494), const Color(0xFF39BFA7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(size * 0.25),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF006494).withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.inventory_2_rounded,
            color: Colors.white,
            size: size * 0.6,
          ),
        );
      },
    );
  }

  Future<bool> _assetExists(String path) async {
    try {
      await Future.delayed(Duration.zero); // Placeholder - in real app, check asset
      return false; // Return false to use fallback for now
    } catch (e) {
      return false;
    }
  }
}
