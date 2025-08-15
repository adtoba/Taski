import 'package:flutter/material.dart';

class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // Light Theme Colors
  static const Color _lightPrimaryColor = Color(0xFF6750A4);
  static const Color _lightOnPrimaryColor = Color(0xFFFFFFFF);
  static const Color _lightSecondaryColor = Color(0xFF625B71);
  static const Color _lightOnSecondaryColor = Color(0xFFFFFFFF);
  static const Color _lightTertiaryColor = Color(0xFF7D5260);
  static const Color _lightOnTertiaryColor = Color(0xFFFFFFFF);
  static const Color _lightErrorColor = Color(0xFFBA1A1A);
  static const Color _lightOnErrorColor = Color(0xFFFFFFFF);
  static const Color _lightBackgroundColor = Color(0xFFFFFBFE);
  static const Color _lightOnBackgroundColor = Color(0xFF1C1B1F);
  static const Color _lightSurfaceColor = Color(0xFFFFFBFE);
  static const Color _lightOnSurfaceColor = Color(0xFF1C1B1F);
  static const Color _lightSurfaceVariantColor = Color(0xFFE7E0EC);
  static const Color _lightOnSurfaceVariantColor = Color(0xFF49454F);
  static const Color _lightOutlineColor = Color(0xFF79747E);
  static const Color _lightOutlineVariantColor = Color(0xFFCAC4D0);

  // Dark Theme Colors
  static const Color _darkPrimaryColor = Color(0xFFD0BCFF);
  static const Color _darkOnPrimaryColor = Color(0xFF381E72);
  static const Color _darkSecondaryColor = Color(0xFFCCC2DC);
  static const Color _darkOnSecondaryColor = Color(0xFF332D41);
  static const Color _darkTertiaryColor = Color(0xFFEFB8C8);
  static const Color _darkOnTertiaryColor = Color(0xFF492532);
  static const Color _darkErrorColor = Color(0xFFFFB4AB);
  static const Color _darkOnErrorColor = Color(0xFF690005);
  static const Color _darkBackgroundColor = Color(0xFF1C1B1F);
  static const Color _darkOnBackgroundColor = Color(0xFFE6E1E5);
  static const Color _darkSurfaceColor = Color(0xFF1C1B1F);
  static const Color _darkOnSurfaceColor = Color(0xFFE6E1E5);
  static const Color _darkSurfaceVariantColor = Color(0xFF49454F);
  static const Color _darkOnSurfaceVariantColor = Color(0xFFCAC4D0);
  static const Color _darkOutlineColor = Color(0xFF938F99);
  static const Color _darkOutlineVariantColor = Color(0xFF49454F);

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: _lightPrimaryColor,
        onPrimary: _lightOnPrimaryColor,
        secondary: _lightSecondaryColor,
        onSecondary: _lightOnSecondaryColor,
        tertiary: _lightTertiaryColor,
        onTertiary: _lightOnTertiaryColor,
        error: _lightErrorColor,
        onError: _lightOnErrorColor,
        background: _lightBackgroundColor,
        onBackground: _lightOnBackgroundColor,
        surface: _lightSurfaceColor,
        onSurface: _lightOnSurfaceColor,
        surfaceVariant: _lightSurfaceVariantColor,
        onSurfaceVariant: _lightOnSurfaceVariantColor,
        outline: _lightOutlineColor,
        outlineVariant: _lightOutlineVariantColor,
      ),
      textTheme: _lightTextTheme,
      appBarTheme: _lightAppBarTheme,
      cardTheme: _lightCardTheme,
      elevatedButtonTheme: _lightElevatedButtonTheme,
      outlinedButtonTheme: _lightOutlinedButtonTheme,
      textButtonTheme: _lightTextButtonTheme,
      inputDecorationTheme: _lightInputDecorationTheme,
      floatingActionButtonTheme: _lightFloatingActionButtonTheme,
      bottomNavigationBarTheme: _lightBottomNavigationBarTheme,
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: _darkPrimaryColor,
        onPrimary: _darkOnPrimaryColor,
        secondary: _darkSecondaryColor,
        onSecondary: _darkOnSecondaryColor,
        tertiary: _darkTertiaryColor,
        onTertiary: _darkOnTertiaryColor,
        error: _darkErrorColor,
        onError: _darkOnErrorColor,
        background: _darkBackgroundColor,
        onBackground: _darkOnBackgroundColor,
        surface: _darkSurfaceColor,
        onSurface: _darkOnSurfaceColor,
        surfaceVariant: _darkSurfaceVariantColor,
        onSurfaceVariant: _darkOnSurfaceVariantColor,
        outline: _darkOutlineColor,
        outlineVariant: _darkOutlineVariantColor,
      ),
      textTheme: _darkTextTheme,
      appBarTheme: _darkAppBarTheme,
      cardTheme: _darkCardTheme,
      elevatedButtonTheme: _darkElevatedButtonTheme,
      outlinedButtonTheme: _darkOutlinedButtonTheme,
      textButtonTheme: _darkTextButtonTheme,
      inputDecorationTheme: _darkInputDecorationTheme,
      floatingActionButtonTheme: _darkFloatingActionButtonTheme,
      bottomNavigationBarTheme: _darkBottomNavigationBarTheme,
    );
  }

  // Light Text Theme
  static const TextTheme _lightTextTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 57,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25,
      color: Colors.black,
      fontFamily: 'Inter',
    ),
    displayMedium: TextStyle(
      fontSize: 45,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      color: Colors.black,
      fontFamily: 'Inter',
    ),
    displaySmall: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      color: Colors.black,
      fontFamily: 'Inter',
    ),
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      color: Colors.black,
      fontFamily: 'Inter',
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      color: Colors.black,
      fontFamily: 'Inter',
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      color: Colors.black,
      fontFamily: 'Inter',
    ),
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      color: Colors.black,
      fontFamily: 'Inter',
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      color: Colors.black,
      fontFamily: 'Inter',
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      color: Colors.black,
      fontFamily: 'Inter',
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      color: Colors.black,
      fontFamily: 'Inter',
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      color: Colors.black,
      fontFamily: 'Inter',
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      color: Colors.black,
      fontFamily: 'Inter',
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      color: Colors.black,
      fontFamily: 'Inter',
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: Colors.black,
      fontFamily: 'Inter',
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: Colors.black,
      fontFamily: 'Inter',
    ),
  );

  // Dark Text Theme
  static const TextTheme _darkTextTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 57,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25,
      color: Colors.white,
      fontFamily: 'Inter',
    ),
    displayMedium: TextStyle(
      fontSize: 45,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      color: Colors.white,
      fontFamily: 'Inter',
    ),
    displaySmall: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      color: Colors.white,
      fontFamily: 'Inter',
    ),
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      color: Colors.white,
      fontFamily: 'Inter',
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      color: Colors.white,
      fontFamily: 'Inter',
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      color: Colors.white,
      fontFamily: 'Inter',
    ),
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      color: Colors.white,
      fontFamily: 'Inter',
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      color: Colors.white,
      fontFamily: 'Inter',
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      color: Colors.white,
      fontFamily: 'Inter',
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      color: Colors.white,
      fontFamily: 'Inter',
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      color: Colors.white,
      fontFamily: 'Inter',
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      color: Colors.white,
      fontFamily: 'Inter',
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      color: Colors.white,
      fontFamily: 'Inter',
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: Colors.white,
      fontFamily: 'Inter',
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: Colors.white,
      fontFamily: 'Inter',
    ),
  );

  // Light AppBar Theme
  static const AppBarTheme _lightAppBarTheme = AppBarTheme(
    backgroundColor: _lightSurfaceColor,
    foregroundColor: _lightOnSurfaceColor,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w400,
      color: _lightOnSurfaceColor,
    ),
  );

  // Dark AppBar Theme
  static const AppBarTheme _darkAppBarTheme = AppBarTheme(
    backgroundColor: _darkSurfaceColor,
    foregroundColor: _darkOnSurfaceColor,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w400,
      color: _darkOnSurfaceColor,
    ),
  );

  // Light Card Theme
  static const CardTheme _lightCardTheme = CardTheme(
    color: _lightSurfaceColor,
    elevation: 1,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  );

  // Dark Card Theme
  static const CardTheme _darkCardTheme = CardTheme(
    color: Colors.black12,
    elevation: 1,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  );

  // Light Elevated Button Theme
  static final ElevatedButtonThemeData _lightElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _lightPrimaryColor,
      foregroundColor: _lightOnPrimaryColor,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ),
  );

  // Dark Elevated Button Theme
  static final ElevatedButtonThemeData _darkElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _darkPrimaryColor,
      foregroundColor: _darkOnPrimaryColor,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ),
  );

  // Light Outlined Button Theme
  static final OutlinedButtonThemeData _lightOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: _lightPrimaryColor,
      side: const BorderSide(color: _lightPrimaryColor),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ),
  );

  // Dark Outlined Button Theme
  static final OutlinedButtonThemeData _darkOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: _darkPrimaryColor,
      side: const BorderSide(color: _darkPrimaryColor),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ),
  );

  // Light Text Button Theme
  static final TextButtonThemeData _lightTextButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: _lightPrimaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
  );

  // Dark Text Button Theme
  static final TextButtonThemeData _darkTextButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: _darkPrimaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
  );

  // Light Input Decoration Theme
  static final InputDecorationTheme _lightInputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: _lightSurfaceVariantColor,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: _lightPrimaryColor, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: _lightErrorColor, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );

  // Dark Input Decoration Theme
  static final InputDecorationTheme _darkInputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: _darkSurfaceVariantColor,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: _darkPrimaryColor, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: _darkErrorColor, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );

  // Light Floating Action Button Theme
  static const FloatingActionButtonThemeData _lightFloatingActionButtonTheme = FloatingActionButtonThemeData(
    backgroundColor: _lightPrimaryColor,
    foregroundColor: _lightOnPrimaryColor,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  );

  // Dark Floating Action Button Theme
  static const FloatingActionButtonThemeData _darkFloatingActionButtonTheme = FloatingActionButtonThemeData(
    backgroundColor: _darkPrimaryColor,
    foregroundColor: _darkOnPrimaryColor,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  );

  // Light Bottom Navigation Bar Theme
  static const BottomNavigationBarThemeData _lightBottomNavigationBarTheme = BottomNavigationBarThemeData(
    backgroundColor: _lightSurfaceColor,
    selectedItemColor: _lightPrimaryColor,
    unselectedItemColor: _lightOnSurfaceVariantColor,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  );

  // Dark Bottom Navigation Bar Theme
  static const BottomNavigationBarThemeData _darkBottomNavigationBarTheme = BottomNavigationBarThemeData(
    backgroundColor: _darkSurfaceColor,
    selectedItemColor: _darkPrimaryColor,
    unselectedItemColor: _darkOnSurfaceVariantColor,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  );
}