import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Base class for all theme states
abstract class ThemeState extends Equatable {
  const ThemeState();

  @override
  List<Object?> get props => [];
}

/// Initial theme state
class ThemeInitial extends ThemeState {
  const ThemeInitial();
}

/// State when theme is loading
class ThemeLoading extends ThemeState {
  const ThemeLoading();
}

/// State when theme is loaded and active
class ThemeLoaded extends ThemeState {
  final ThemeMode themeMode;
  final ThemeData lightTheme;
  final ThemeData darkTheme;
  final bool isDynamicColorsEnabled;
  final bool isHighContrastEnabled;
  final bool isAutoSwitchEnabled;
  final TimeOfDay? lightModeStart;
  final TimeOfDay? darkModeStart;
  final String? fontFamily;
  final double fontSize;
  final FontWeight fontWeight;

  const ThemeLoaded({
    required this.themeMode,
    required this.lightTheme,
    required this.darkTheme,
    this.isDynamicColorsEnabled = false,
    this.isHighContrastEnabled = false,
    this.isAutoSwitchEnabled = false,
    this.lightModeStart,
    this.darkModeStart,
    this.fontFamily,
    this.fontSize = 14.0,
    this.fontWeight = FontWeight.normal,
  });

  @override
  List<Object?> get props => [
        themeMode,
        lightTheme,
        darkTheme,
        isDynamicColorsEnabled,
        isHighContrastEnabled,
        isAutoSwitchEnabled,
        lightModeStart,
        darkModeStart,
        fontFamily,
        fontSize,
        fontWeight,
      ];

  ThemeLoaded copyWith({
    ThemeMode? themeMode,
    ThemeData? lightTheme,
    ThemeData? darkTheme,
    bool? isDynamicColorsEnabled,
    bool? isHighContrastEnabled,
    bool? isAutoSwitchEnabled,
    TimeOfDay? lightModeStart,
    TimeOfDay? darkModeStart,
    String? fontFamily,
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    return ThemeLoaded(
      themeMode: themeMode ?? this.themeMode,
      lightTheme: lightTheme ?? this.lightTheme,
      darkTheme: darkTheme ?? this.darkTheme,
      isDynamicColorsEnabled: isDynamicColorsEnabled ?? this.isDynamicColorsEnabled,
      isHighContrastEnabled: isHighContrastEnabled ?? this.isHighContrastEnabled,
      isAutoSwitchEnabled: isAutoSwitchEnabled ?? this.isAutoSwitchEnabled,
      lightModeStart: lightModeStart ?? this.lightModeStart,
      darkModeStart: darkModeStart ?? this.darkModeStart,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
    );
  }

  /// Get the current theme based on theme mode and system brightness
  ThemeData getCurrentTheme(Brightness systemBrightness) {
    switch (themeMode) {
      case ThemeMode.light:
        return lightTheme;
      case ThemeMode.dark:
        return darkTheme;
      case ThemeMode.system:
        return systemBrightness == Brightness.dark ? darkTheme : lightTheme;
    }
  }

  /// Check if current theme is dark
  bool isDarkMode(Brightness systemBrightness) {
    switch (themeMode) {
      case ThemeMode.light:
        return false;
      case ThemeMode.dark:
        return true;
      case ThemeMode.system:
        return systemBrightness == Brightness.dark;
    }
  }
}

/// State when theme is changed
class ThemeChanged extends ThemeState {
  final ThemeMode themeMode;
  final ThemeData lightTheme;
  final ThemeData darkTheme;

  const ThemeChanged({
    required this.themeMode,
    required this.lightTheme,
    required this.darkTheme,
  });

  @override
  List<Object?> get props => [themeMode, lightTheme, darkTheme];
}

/// State when theme is saved
class ThemeSaved extends ThemeState {
  final ThemeMode themeMode;

  const ThemeSaved({required this.themeMode});

  @override
  List<Object?> get props => [themeMode];
}

/// State when theme is reset to default
class ThemeReset extends ThemeState {
  final ThemeData defaultLightTheme;
  final ThemeData defaultDarkTheme;

  const ThemeReset({
    required this.defaultLightTheme,
    required this.defaultDarkTheme,
  });

  @override
  List<Object?> get props => [defaultLightTheme, defaultDarkTheme];
}

/// State when theme colors are updated
class ThemeColorsUpdated extends ThemeState {
  final Color? primaryColor;
  final Color? accentColor;
  final Color? backgroundColor;
  final ThemeData updatedLightTheme;
  final ThemeData updatedDarkTheme;

  const ThemeColorsUpdated({
    this.primaryColor,
    this.accentColor,
    this.backgroundColor,
    required this.updatedLightTheme,
    required this.updatedDarkTheme,
  });

  @override
  List<Object?> get props => [
        primaryColor,
        accentColor,
        backgroundColor,
        updatedLightTheme,
        updatedDarkTheme,
      ];
}

/// State when custom theme is set
class CustomThemeSet extends ThemeState {
  final ThemeData lightTheme;
  final ThemeData darkTheme;

  const CustomThemeSet({
    required this.lightTheme,
    required this.darkTheme,
  });

  @override
  List<Object?> get props => [lightTheme, darkTheme];
}

/// State when dynamic colors are toggled
class DynamicColorsToggled extends ThemeState {
  final bool enabled;
  final ThemeData? updatedLightTheme;
  final ThemeData? updatedDarkTheme;

  const DynamicColorsToggled({
    required this.enabled,
    this.updatedLightTheme,
    this.updatedDarkTheme,
  });

  @override
  List<Object?> get props => [enabled, updatedLightTheme, updatedDarkTheme];
}

/// State when font settings are updated
class FontSettingsUpdated extends ThemeState {
  final String? fontFamily;
  final double fontSize;
  final FontWeight fontWeight;
  final ThemeData updatedLightTheme;
  final ThemeData updatedDarkTheme;

  const FontSettingsUpdated({
    this.fontFamily,
    required this.fontSize,
    required this.fontWeight,
    required this.updatedLightTheme,
    required this.updatedDarkTheme,
  });

  @override
  List<Object?> get props => [
        fontFamily,
        fontSize,
        fontWeight,
        updatedLightTheme,
        updatedDarkTheme,
      ];
}

/// State when high contrast mode is set
class HighContrastSet extends ThemeState {
  final bool enabled;
  final ThemeData updatedLightTheme;
  final ThemeData updatedDarkTheme;

  const HighContrastSet({
    required this.enabled,
    required this.updatedLightTheme,
    required this.updatedDarkTheme,
  });

  @override
  List<Object?> get props => [enabled, updatedLightTheme, updatedDarkTheme];
}

/// State when theme is updated by time
class ThemeUpdatedByTime extends ThemeState {
  final ThemeMode newThemeMode;
  final DateTime updateTime;

  const ThemeUpdatedByTime({
    required this.newThemeMode,
    required this.updateTime,
  });

  @override
  List<Object?> get props => [newThemeMode, updateTime];
}

/// State when auto theme switch is set
class AutoThemeSwitchSet extends ThemeState {
  final bool enabled;
  final TimeOfDay? lightModeStart;
  final TimeOfDay? darkModeStart;

  const AutoThemeSwitchSet({
    required this.enabled,
    this.lightModeStart,
    this.darkModeStart,
  });

  @override
  List<Object?> get props => [enabled, lightModeStart, darkModeStart];
}

/// State when theme is being previewed
class ThemePreviewing extends ThemeState {
  final ThemeData previewTheme;
  final bool isDark;
  final ThemeData originalLightTheme;
  final ThemeData originalDarkTheme;
  final ThemeMode originalThemeMode;

  const ThemePreviewing({
    required this.previewTheme,
    required this.isDark,
    required this.originalLightTheme,
    required this.originalDarkTheme,
    required this.originalThemeMode,
  });

  @override
  List<Object?> get props => [
        previewTheme,
        isDark,
        originalLightTheme,
        originalDarkTheme,
        originalThemeMode,
      ];
}

/// State when previewed theme is applied
class PreviewedThemeApplied extends ThemeState {
  final ThemeData appliedTheme;
  final bool isDark;

  const PreviewedThemeApplied({
    required this.appliedTheme,
    required this.isDark,
  });

  @override
  List<Object?> get props => [appliedTheme, isDark];
}

/// State when theme preview is cancelled
class ThemePreviewCancelled extends ThemeState {
  final ThemeData restoredLightTheme;
  final ThemeData restoredDarkTheme;
  final ThemeMode restoredThemeMode;

  const ThemePreviewCancelled({
    required this.restoredLightTheme,
    required this.restoredDarkTheme,
    required this.restoredThemeMode,
  });

  @override
  List<Object?> get props => [
        restoredLightTheme,
        restoredDarkTheme,
        restoredThemeMode,
      ];
}

/// State when theme is imported
class ThemeImported extends ThemeState {
  final String filePath;
  final ThemeData importedLightTheme;
  final ThemeData importedDarkTheme;

  const ThemeImported({
    required this.filePath,
    required this.importedLightTheme,
    required this.importedDarkTheme,
  });

  @override
  List<Object?> get props => [filePath, importedLightTheme, importedDarkTheme];
}

/// State when theme is exported
class ThemeExported extends ThemeState {
  final String filePath;

  const ThemeExported({required this.filePath});

  @override
  List<Object?> get props => [filePath];
}

/// State when theme operation fails
class ThemeError extends ThemeState {
  final String message;
  final String? errorCode;

  const ThemeError({
    required this.message,
    this.errorCode,
  });

  @override
  List<Object?> get props => [message, errorCode];
}