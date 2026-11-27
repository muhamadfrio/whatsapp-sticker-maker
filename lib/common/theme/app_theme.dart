import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // iOS System Colors
  static const Color primary = CupertinoColors.activeBlue; // #007AFF
  static const Color systemGreen = CupertinoColors.systemGreen; // #34C759
  static const Color systemRed = CupertinoColors.systemRed; // #FF3B30
  static const Color systemOrange = CupertinoColors.systemOrange; // #FF9500
  static const Color systemIndigo = CupertinoColors.systemIndigo; // #5856D6

  // iOS Light Background Colors
  static const Color systemGroupedBackground = Color(0xFFF2F2F7);
  static const Color secondarySystemGroupedBackground = Color(0xFFFFFFFF);
  static const Color tertiarySystemGroupedBackground = Color(0xFFF2F2F7);

  // iOS Text Colors
  static const Color label = Color(0xFF000000);
  static const Color secondaryLabel = Color(0x993C3C43);
  static const Color tertiaryLabel = Color(0x4D3C3C43);

  // iOS Dark Colors
  static const Color darkSystemGroupedBackground = Color(0xFF000000);
  static const Color darkSecondarySystemGroupedBackground = Color(0xFF1C1C1E);
  static const Color darkLabel = Color(0xFFFFFFFF);
  static const Color darkSecondaryLabel = Color(0x99EBEBF5);

  /// iOS System Font Family Fallbacks
  static const String sfProFontFamily = '.SF Pro Text';
  static const List<String> sfProFontFallback = [
    '.SF Pro Text',
    'SF Pro Text',
    'SF Pro Display',
    'San Francisco',
    'Inter',
  ];

  /// Cupertino Theme Data for iOS widgets with iOS SF Pro Font
  static CupertinoThemeData get cupertinoTheme => CupertinoThemeData(
        primaryColor: primary,
        scaffoldBackgroundColor: systemGroupedBackground,
        barBackgroundColor: const Color(0xCCF9F9F9),
        textTheme: CupertinoTextThemeData(
          primaryColor: primary,
          textStyle: GoogleFonts.inter(
            color: label,
            fontSize: 16,
          ).copyWith(
            fontFamily: sfProFontFamily,
            fontFamilyFallback: sfProFontFallback,
          ),
          navTitleTextStyle: GoogleFonts.inter(
            color: label,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.41,
          ).copyWith(
            fontFamily: sfProFontFamily,
            fontFamilyFallback: sfProFontFallback,
          ),
          navLargeTitleTextStyle: GoogleFonts.inter(
            color: label,
            fontSize: 34,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.37,
          ).copyWith(
            fontFamily: sfProFontFamily,
            fontFamilyFallback: sfProFontFallback,
          ),
        ),
      );

  /// Light ThemeData with iOS styling & SF Pro/Inter typography
  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);
    final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: label,
      displayColor: label,
    );

    return base.copyWith(
      scaffoldBackgroundColor: systemGroupedBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: systemGreen,
        surface: secondarySystemGroupedBackground,
        error: systemRed,
      ),
      textTheme: textTheme,
      cupertinoOverrideTheme: cupertinoTheme,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xCCF9F9F9),
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        iconTheme: const IconThemeData(color: primary),
        titleTextStyle: GoogleFonts.inter(
          color: label,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.41,
        ).copyWith(
          fontFamily: sfProFontFamily,
          fontFamilyFallback: sfProFontFallback,
        ),
      ),
      cardTheme: CardThemeData(
        color: secondarySystemGroupedBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0x1F000000), width: 0.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.24,
          ).copyWith(
            fontFamily: sfProFontFamily,
            fontFamilyFallback: sfProFontFallback,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ).copyWith(
            fontFamily: sfProFontFamily,
            fontFamilyFallback: sfProFontFallback,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ).copyWith(
            fontFamily: sfProFontFamily,
            fontFamilyFallback: sfProFontFallback,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0x1F767680),
        selectedColor: primary,
        secondarySelectedColor: primary,
        labelStyle: GoogleFonts.inter(fontSize: 13, color: label),
        secondaryLabelStyle: GoogleFonts.inter(fontSize: 13, color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        side: BorderSide.none,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: secondarySystemGroupedBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        titleTextStyle: GoogleFonts.inter(
          color: label,
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ).copyWith(
          fontFamily: sfProFontFamily,
          fontFamilyFallback: sfProFontFallback,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0x1F767680),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(color: secondaryLabel, fontSize: 14),
      ),
    );
  }

  /// Dark ThemeData with iOS styling & SF Pro/Inter typography
  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: darkLabel,
      displayColor: darkLabel,
    );

    return base.copyWith(
      scaffoldBackgroundColor: darkSystemGroupedBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
        primary: primary,
        secondary: systemGreen,
        surface: darkSecondarySystemGroupedBackground,
        error: systemRed,
      ),
      textTheme: textTheme,
      cupertinoOverrideTheme: cupertinoTheme.copyWith(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: darkSystemGroupedBackground,
        barBackgroundColor: const Color(0xCC1C1C1E),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xCC1C1C1E),
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        iconTheme: const IconThemeData(color: primary),
        titleTextStyle: GoogleFonts.inter(
          color: darkLabel,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.41,
        ).copyWith(
          fontFamily: sfProFontFamily,
          fontFamilyFallback: sfProFontFallback,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkSecondarySystemGroupedBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0x38FFFFFF), width: 0.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ).copyWith(
            fontFamily: sfProFontFamily,
            fontFamilyFallback: sfProFontFallback,
          ),
        ),
      ),
    );
  }
}
