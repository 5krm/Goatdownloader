import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

class AppTheme {
  // Color constants
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color primaryColorDark = Color(0xFF1976D2);
  static const Color accentColor = Color(0xFF03DAC6);
  static const Color errorColor = Color(0xFFB00020);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color infoColor = Color(0xFF2196F3);

  // Light theme colors
  static const Color lightBackgroundColor = Color(0xFFFAFAFA);
  static const Color lightSurfaceColor = Color(0xFFFFFFFF);
  static const Color lightOnPrimaryColor = Color(0xFFFFFFFF);
  static const Color lightOnSecondaryColor = Color(0xFF000000);
  static const Color lightOnSurfaceColor = Color(0xFF000000);
  static const Color lightOnBackgroundColor = Color(0xFF000000);

  // Dark theme colors
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkSurfaceColor = Color(0xFF1E1E1E);
  static const Color darkOnPrimaryColor = Color(0xFF000000);
  static const Color darkOnSecondaryColor = Color(0xFFFFFFFF);
  static const Color darkOnSurfaceColor = Color(0xFFFFFFFF);
  static const Color darkOnBackgroundColor = Color(0xFFFFFFFF);

  // Text theme
  static const String fontFamily = 'Roboto';

  // Light theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        onPrimary: lightOnPrimaryColor,
        secondary: accentColor,
        onSecondary: lightOnSecondaryColor,
        error: errorColor,
        onError: lightOnPrimaryColor,
        background: lightBackgroundColor,
        onBackground: lightOnBackgroundColor,
        surface: lightSurfaceColor,
        onSurface: lightOnSurfaceColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: lightOnPrimaryColor,
        elevation: 4,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: lightOnPrimaryColor,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: lightOnPrimaryColor,
        elevation: 6,
      ),
      cardTheme: const CardThemeData(
        color: lightSurfaceColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: lightSurfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: lightSurfaceColor,
        elevation: 16,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: lightSurfaceColor,
        elevation: 24,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkSurfaceColor,
        contentTextStyle: const TextStyle(color: darkOnSurfaceColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return Colors.grey;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor.withOpacity(0.5);
          }
          return Colors.grey.withOpacity(0.3);
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(lightOnPrimaryColor),
      ),
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return Colors.grey;
        }),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: primaryColor,
        inactiveTrackColor: Colors.grey,
        thumbColor: primaryColor,
        overlayColor: Color(0x1F2196F3),
      ),
      textTheme: _buildTextTheme(lightOnSurfaceColor),
      fontFamily: fontFamily,
    );
  }

  // Dark theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        onPrimary: darkOnPrimaryColor,
        secondary: accentColor,
        onSecondary: darkOnSecondaryColor,
        error: errorColor,
        onError: darkOnPrimaryColor,
        background: darkBackgroundColor,
        onBackground: darkOnBackgroundColor,
        surface: darkSurfaceColor,
        onSurface: darkOnSurfaceColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurfaceColor,
        foregroundColor: darkOnSurfaceColor,
        elevation: 4,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: darkOnPrimaryColor,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: darkOnPrimaryColor,
        elevation: 6,
      ),
      cardTheme: const CardThemeData(
        color: darkSurfaceColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: darkSurfaceColor,
        elevation: 16,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: darkSurfaceColor,
        elevation: 24,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: lightSurfaceColor,
        contentTextStyle: const TextStyle(color: lightOnSurfaceColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return Colors.grey;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor.withOpacity(0.5);
          }
          return Colors.grey.withOpacity(0.3);
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(darkOnPrimaryColor),
      ),
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return Colors.grey;
        }),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: primaryColor,
        inactiveTrackColor: Colors.grey,
        thumbColor: primaryColor,
        overlayColor: Color(0x1F2196F3),
      ),
      textTheme: _buildTextTheme(darkOnSurfaceColor),
      fontFamily: fontFamily,
    );
  }

  // Build text theme
  static TextTheme _buildTextTheme(Color textColor) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        color: textColor,
        fontFamily: fontFamily,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        color: textColor,
        fontFamily: fontFamily,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: textColor,
        fontFamily: fontFamily,
      ),
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        color: textColor,
        fontFamily: fontFamily,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        color: textColor,
        fontFamily: fontFamily,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        color: textColor,
        fontFamily: fontFamily,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: textColor,
        fontFamily: fontFamily,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textColor,
        fontFamily: fontFamily,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
        fontFamily: fontFamily,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textColor,
        fontFamily: fontFamily,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textColor,
        fontFamily: fontFamily,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textColor,
        fontFamily: fontFamily,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
        fontFamily: fontFamily,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textColor,
        fontFamily: fontFamily,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: textColor,
        fontFamily: fontFamily,
      ),
    );
  }

  // Build dynamic theme from system colors
  static ThemeData buildDynamicLightTheme(CorePalette corePalette) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Color(corePalette.primary.get(40)),
      brightness: Brightness.light,
    );

    return lightTheme.copyWith(colorScheme: colorScheme);
  }

  static ThemeData buildDynamicDarkTheme(CorePalette corePalette) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Color(corePalette.primary.get(80)),
      brightness: Brightness.dark,
    );

    return darkTheme.copyWith(colorScheme: colorScheme);
  }

  // Build custom theme with custom colors
  static ThemeData buildCustomTheme({
    required ThemeData baseTheme,
    Color? primaryColor,
    Color? accentColor,
    Color? backgroundColor,
  }) {
    ColorScheme colorScheme = baseTheme.colorScheme;

    if (primaryColor != null) {
      colorScheme = colorScheme.copyWith(primary: primaryColor);
    }

    if (accentColor != null) {
      colorScheme = colorScheme.copyWith(secondary: accentColor);
    }

    if (backgroundColor != null) {
      colorScheme = colorScheme.copyWith(background: backgroundColor);
    }

    return baseTheme.copyWith(colorScheme: colorScheme);
  }

  // Build high contrast theme
  static ThemeData buildHighContrastTheme(ThemeData baseTheme) {
    final isLight = baseTheme.brightness == Brightness.light;
    
    final colorScheme = baseTheme.colorScheme.copyWith(
      primary: isLight ? Colors.black : Colors.white,
      onPrimary: isLight ? Colors.white : Colors.black,
      secondary: isLight ? Colors.black : Colors.white,
      onSecondary: isLight ? Colors.white : Colors.black,
      surface: isLight ? Colors.white : Colors.black,
      onSurface: isLight ? Colors.black : Colors.white,
      background: isLight ? Colors.white : Colors.black,
      onBackground: isLight ? Colors.black : Colors.white,
    );

    return baseTheme.copyWith(colorScheme: colorScheme);
  }

  // Build theme with custom font settings
  static ThemeData buildFontTheme({
    required ThemeData baseTheme,
    String? fontFamily,
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    TextTheme textTheme = baseTheme.textTheme;

    if (fontFamily != null || fontSize != null || fontWeight != null) {
      textTheme = textTheme.copyWith(
        displayLarge: textTheme.displayLarge?.copyWith(
          fontFamily: fontFamily,
          fontSize: fontSize != null ? fontSize * 4.07 : null,
          fontWeight: fontWeight,
        ),
        displayMedium: textTheme.displayMedium?.copyWith(
          fontFamily: fontFamily,
          fontSize: fontSize != null ? fontSize * 3.21 : null,
          fontWeight: fontWeight,
        ),
        displaySmall: textTheme.displaySmall?.copyWith(
          fontFamily: fontFamily,
          fontSize: fontSize != null ? fontSize * 2.57 : null,
          fontWeight: fontWeight,
        ),
        headlineLarge: textTheme.headlineLarge?.copyWith(
          fontFamily: fontFamily,
          fontSize: fontSize != null ? fontSize * 2.29 : null,
          fontWeight: fontWeight,
        ),
        headlineMedium: textTheme.headlineMedium?.copyWith(
          fontFamily: fontFamily,
          fontSize: fontSize != null ? fontSize * 2.0 : null,
          fontWeight: fontWeight,
        ),
        headlineSmall: textTheme.headlineSmall?.copyWith(
          fontFamily: fontFamily,
          fontSize: fontSize != null ? fontSize * 1.71 : null,
          fontWeight: fontWeight,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(
          fontFamily: fontFamily,
          fontSize: fontSize != null ? fontSize * 1.57 : null,
          fontWeight: fontWeight,
        ),
        titleMedium: textTheme.titleMedium?.copyWith(
          fontFamily: fontFamily,
          fontSize: fontSize != null ? fontSize * 1.14 : null,
          fontWeight: fontWeight,
        ),
        titleSmall: textTheme.titleSmall?.copyWith(
          fontFamily: fontFamily,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
        bodyLarge: textTheme.bodyLarge?.copyWith(
          fontFamily: fontFamily,
          fontSize: fontSize != null ? fontSize * 1.14 : null,
          fontWeight: fontWeight,
        ),
        bodyMedium: textTheme.bodyMedium?.copyWith(
          fontFamily: fontFamily,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
        bodySmall: textTheme.bodySmall?.copyWith(
          fontFamily: fontFamily,
          fontSize: fontSize != null ? fontSize * 0.86 : null,
          fontWeight: fontWeight,
        ),
        labelLarge: textTheme.labelLarge?.copyWith(
          fontFamily: fontFamily,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
        labelMedium: textTheme.labelMedium?.copyWith(
          fontFamily: fontFamily,
          fontSize: fontSize != null ? fontSize * 0.86 : null,
          fontWeight: fontWeight,
        ),
        labelSmall: textTheme.labelSmall?.copyWith(
          fontFamily: fontFamily,
          fontSize: fontSize != null ? fontSize * 0.79 : null,
          fontWeight: fontWeight,
        ),
      );
    }

    return baseTheme.copyWith(
      textTheme: textTheme,
    );
  }

  // Get status bar style based on theme
  static SystemUiOverlayStyle getSystemUiOverlayStyle(ThemeData theme) {
    return theme.brightness == Brightness.light
        ? SystemUiOverlayStyle.dark
        : SystemUiOverlayStyle.light;
  }

  // Get appropriate text color for background
  static Color getTextColorForBackground(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  // Generate color palette from primary color
  static Map<int, Color> generateColorSwatch(Color color) {
    final hsl = HSLColor.fromColor(color);
    return {
      50: hsl.withLightness(0.95).toColor(),
      100: hsl.withLightness(0.9).toColor(),
      200: hsl.withLightness(0.8).toColor(),
      300: hsl.withLightness(0.7).toColor(),
      400: hsl.withLightness(0.6).toColor(),
      500: color,
      600: hsl.withLightness(0.4).toColor(),
      700: hsl.withLightness(0.3).toColor(),
      800: hsl.withLightness(0.2).toColor(),
      900: hsl.withLightness(0.1).toColor(),
    };
  }
}