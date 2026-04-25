import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- Core Colors ---
  static const Color emerald = Color(0xFF10B981);
  static const Color deepEmerald = Color(0xFF059669);
  static const Color lightMint = Color(0xFFECFDF5);
  static const Color mintAccent = Color(0xFFA7F3D0);
  
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate50 = Color(0xFFF8FAFC);
  
  static const Color cyberBlue = Color(0xFF0EA5E9);
  static const Color neonPurple = Color(0xFFA855F7);
  
  static const Color midnightScaffold = Color(0xFF0B1222);
  static const Color pearlScaffold = Color(0xFFF8FAFC);

  // --- Gradients ---
  static LinearGradient get mintGradient => const LinearGradient(
        colors: [Color(0xFF10B981), Color(0xFF059669)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get pageGradient => const LinearGradient(
        colors: [Color(0xFFF0FDF4), Color(0xFFF8FAFC)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get darkPageGradient => const LinearGradient(
        colors: [Color(0xFF0F172A), Color(0xFF0B1222)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get cyberGradient => const LinearGradient(
        colors: [cyberBlue, neonPurple],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  // --- Card Surfaces ---
  static BoxDecoration surfaceCard({double radius = 24}) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: emerald.withValues(alpha: 0.12)),
      boxShadow: [
        BoxShadow(
          color: emerald.withValues(alpha: 0.04), // Reduced opacity
          blurRadius: 16, // Reduced blur
          offset: const Offset(0, 4), // Reduced offset
        ),
      ],
    );
  }

  static BoxDecoration darkSurfaceCard({double radius = 24}) {
    return BoxDecoration(
      color: slate800.withValues(alpha: 0.8),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2), // Reduced opacity
          blurRadius: 20, // Reduced blur
          offset: const Offset(0, 6), // Reduced offset
        ),
      ],
    );
  }

  // --- Theme Definitions ---
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: emerald,
      brightness: Brightness.light,
      primary: emerald,
      onPrimary: Colors.white,
      secondary: cyberBlue,
      surface: Colors.white,
      onSurface: slate900,
      error: const Color(0xFFEF4444),
    );

    final textTheme = GoogleFonts.comicNeueTextTheme(ThemeData.light().textTheme).apply(
      bodyColor: slate900,
      displayColor: slate900,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: pearlScaffold,
      fontFamily: GoogleFonts.comicNeue().fontFamily,
      textTheme: textTheme,
      
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: slate900,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: slate900,
          fontSize: 20,
          letterSpacing: -0.5,
        ),
      ),
      
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: emerald.withValues(alpha: 0.08)),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: emerald.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: emerald, width: 2),
        ),
        hintStyle: GoogleFonts.comicNeue(color: slate900.withValues(alpha: 0.35), fontWeight: FontWeight.w400),
        labelStyle: GoogleFonts.comicNeue(fontWeight: FontWeight.w600),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 4, // Reduced elevation
          shadowColor: emerald.withValues(alpha: 0.25), // Reduced shadow
          foregroundColor: Colors.white,
          backgroundColor: emerald,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: GoogleFonts.comicNeue(fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 0.3),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 28),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 6, // Reduced elevation
        backgroundColor: emerald,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        titleTextStyle: GoogleFonts.comicNeue(fontWeight: FontWeight.w900, fontSize: 22, color: slate900),
      ),
      
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: lightMint,
        selectedColor: emerald,
        side: BorderSide(color: emerald.withValues(alpha: 0.08)),
        labelStyle: GoogleFonts.comicNeue(fontWeight: FontWeight.w700, fontSize: 14, color: slate900),
        secondaryLabelStyle: const TextStyle(color: Colors.white),
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: emerald,
      brightness: Brightness.dark,
      primary: emerald,
      onPrimary: slate900,
      secondary: cyberBlue,
      surface: slate800,
      onSurface: Colors.white,
      error: const Color(0xFFF87171),
    );

    final textTheme = GoogleFonts.comicNeueTextTheme(ThemeData.dark().textTheme).apply(
      bodyColor: Colors.white.withValues(alpha: 0.9),
      displayColor: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: midnightScaffold,
      fontFamily: GoogleFonts.comicNeue().fontFamily,
      textTheme: textTheme,
      
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Colors.white,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          fontSize: 20,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
      ),
      
      cardTheme: CardThemeData(
        color: slate800.withValues(alpha: 0.6),
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: slate800.withValues(alpha: 0.4),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: emerald, width: 2),
        ),
        hintStyle: GoogleFonts.comicNeue(color: Colors.white.withValues(alpha: 0.3), fontWeight: FontWeight.w400),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 6, // Reduced elevation from 12
          shadowColor: Colors.black.withValues(alpha: 0.3), // Reduced shadow
          foregroundColor: slate900,
          backgroundColor: emerald,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: GoogleFonts.comicNeue(fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 0.3),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 28),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 8, // Reduced elevation from 12
        backgroundColor: emerald,
        foregroundColor: slate900,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: slate800,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        titleTextStyle: GoogleFonts.comicNeue(fontWeight: FontWeight.w900, fontSize: 22, color: Colors.white),
      ),
      
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: slate700,
        selectedColor: emerald,
        side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        labelStyle: GoogleFonts.comicNeue(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white),
      ),
      
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: slate700,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentTextStyle: GoogleFonts.comicNeue(color: Colors.white, fontWeight: FontWeight.w700),
      ),
    );
  }
}
