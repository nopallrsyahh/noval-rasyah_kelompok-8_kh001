import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF245DA8);
  static const Color primarySoft = Color(0xFFE3EDF8);
  static const Color dark = Color(0xFF2B2D33);
  static const Color softBg = Color(0xFFF1F3F4);
  static const Color border = Color(0xFFE3E6E8);
  static const Color textMuted = Color(0xFF6B7075);
  static const Color danger = Color(0xFFD64545);

  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: primary, primary: primary),
    );

    OutlineInputBorder inputBorder([Color? color, double width = 0]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: color == null
            ? BorderSide.none
            : BorderSide(color: color, width: width),
      );
    }

    return base.copyWith(
      scaffoldBackgroundColor: Colors.white,
      textTheme: GoogleFonts.outfitTextTheme(base.textTheme)
          .apply(bodyColor: dark, displayColor: dark),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: dark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: dark,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: softBg,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: inputBorder(),
        enabledBorder: inputBorder(),
        focusedBorder: inputBorder(primary, 1.5),
      ),
    );
  }
}