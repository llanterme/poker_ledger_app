import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Bright funky colors
  static const Color primaryColor = Color(0xFF6A00FF); // Vibrant purple
  static const Color secondaryColor = Color(0xFF00E5FF); // Bright cyan
  static const Color accentColor = Color(0xFFFF3D00); // Vibrant orange
  static const Color successColor = Color(0xFF00E676); // Bright green
  static const Color errorColor = Color(0xFFFF1744); // Bright red
  static const Color warningColor = Color(0xFFFFD600); // Bright yellow
  static const Color backgroundColor = Color(0xFF121212); // Dark background
  static const Color surfaceColor = Color(0xFF1E1E1E); // Slightly lighter surface
  static const Color cardColor = Color(0xFF2C2C2C); // Card background
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6A00FF), Color(0xFF9D50BB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF00E5FF), Color(0xFF00B8D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFF3D00), Color(0xFFFF8A65)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Text styles
  static TextStyle get headlineLarge => GoogleFonts.montserrat(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  
  static TextStyle get headlineMedium => GoogleFonts.montserrat(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  
  static TextStyle get titleLarge => GoogleFonts.montserrat(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  
  static TextStyle get titleMedium => GoogleFonts.montserrat(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );
  
  static TextStyle get bodyLarge => GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: Colors.white,
  );
  
  static TextStyle get bodyMedium => GoogleFonts.roboto(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Colors.white,
  );
  
  static TextStyle get labelLarge => GoogleFonts.roboto(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  // ThemeData
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        background: backgroundColor,
        surface: surfaceColor,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onBackground: Colors.white,
        onSurface: Colors.white,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: secondaryColor,
          textStyle: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: secondaryColor, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: secondaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: GoogleFonts.roboto(
          fontSize: 16,
          color: Colors.white.withOpacity(0.6),
        ),
      ),
      cardTheme: CardTheme(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cardColor,
        contentTextStyle: GoogleFonts.roboto(
          fontSize: 16,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: const DividerThemeData(
        color: Colors.white24,
        thickness: 1,
        space: 32,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return Colors.white54;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return Colors.white70;
        }),
        trackColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor.withOpacity(0.5);
          }
          return Colors.white30;
        }),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: backgroundColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      tabBarTheme: const TabBarTheme(
        labelColor: primaryColor,
        unselectedLabelColor: Colors.white54,
        indicatorColor: primaryColor,
      ),
    );
  }
}
