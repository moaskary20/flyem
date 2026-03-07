import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  static const Color primaryYellow = Color(0xFFFDB913);
  static const Color navBarBackground = Color(0xFF2C2C2E);
  static const Color navBarSelected = Color(0xFFFDB913);
  static const Color navBarUnselected = Color(0xFFFFFFFF);
  static const Color searchCardBg = Color(0xFFFDB913);
  static const Color buttonDark = Color(0xFF2C2C2E);
  static const Color rewardBarBg = Color(0xFF3A3A3C);
  static const Color cardBorder = Color(0xFFE5E5EA);
  static const Color scaffoldBg = Color(0xFFF2F2F7);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.tajawalTextTheme(),
        fontFamily: GoogleFonts.tajawal().fontFamily,
        colorScheme: ColorScheme.light(
          primary: AppColors.primaryYellow,
          surface: Colors.white,
          onPrimary: Colors.black,
          onSurface: Colors.black87,
        ),
        scaffoldBackgroundColor: AppColors.scaffoldBg,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.scaffoldBg,
          elevation: 0,
          centerTitle: true,
        ),
      );
}
