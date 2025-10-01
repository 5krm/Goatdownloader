import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Base class for all theme events
abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

/// Event to change the app theme
class ChangeThemeEvent extends ThemeEvent {
  final ThemeMode themeMode;

  const ChangeThemeEvent({required this.themeMode});

  @override
  List<Object?> get props => [themeMode];
}

/// Event to toggle between light and dark theme
class ToggleThemeEvent extends ThemeEvent {
  const ToggleThemeEvent();
}

/// Event to set theme based on system settings
class SetSystemThemeEvent extends ThemeEvent {
  const SetSystemThemeEvent();
}

/// Event to load saved theme from storage
class LoadThemeEvent extends ThemeEvent {
  const LoadThemeEvent();
}

/// Event to save current theme to storage
class SaveThemeEvent extends ThemeEvent {
  final ThemeMode themeMode;

  const SaveThemeEvent({required this.themeMode});

  @override
  List<Object?> get props => [themeMode];
}

/// Event to reset theme to default
class ResetThemeEvent extends ThemeEvent {
  const ResetThemeEvent();
}

/// Event to update theme colors
class UpdateThemeColorsEvent extends ThemeEvent {
  final Color? primaryColor;
  final Color? accentColor;
  final Color? backgroundColor;

  const UpdateThemeColorsEvent({
    this.primaryColor,
    this.accentColor,
    this.backgroundColor,
  });

  @override
  List<Object?> get props => [primaryColor, accentColor, backgroundColor];
}

/// Event to set custom theme
class SetCustomThemeEvent extends ThemeEvent {
  final ThemeData lightTheme;
  final ThemeData darkTheme;

  const SetCustomThemeEvent({
    required this.lightTheme,
    required this.darkTheme,
  });

  @override
  List<Object?> get props => [lightTheme, darkTheme];
}

/// Event to enable/disable dynamic colors (Material You)
class ToggleDynamicColorsEvent extends ThemeEvent {
  final bool enabled;

  const ToggleDynamicColorsEvent({required this.enabled});

  @override
  List<Object?> get props => [enabled];
}

/// Event to update font settings
class UpdateFontSettingsEvent extends ThemeEvent {
  final String? fontFamily;
  final double? fontSize;
  final FontWeight? fontWeight;

  const UpdateFontSettingsEvent({
    this.fontFamily,
    this.fontSize,
    this.fontWeight,
  });

  @override
  List<Object?> get props => [fontFamily, fontSize, fontWeight];
}

/// Event to set high contrast mode
class SetHighContrastEvent extends ThemeEvent {
  final bool enabled;

  const SetHighContrastEvent({required this.enabled});

  @override
  List<Object?> get props => [enabled];
}

/// Event to update theme based on time of day
class UpdateThemeByTimeEvent extends ThemeEvent {
  final DateTime currentTime;

  const UpdateThemeByTimeEvent({required this.currentTime});

  @override
  List<Object?> get props => [currentTime];
}

/// Event to set automatic theme switching
class SetAutoThemeSwitchEvent extends ThemeEvent {
  final bool enabled;
  final TimeOfDay? lightModeStart;
  final TimeOfDay? darkModeStart;

  const SetAutoThemeSwitchEvent({
    required this.enabled,
    this.lightModeStart,
    this.darkModeStart,
  });

  @override
  List<Object?> get props => [enabled, lightModeStart, darkModeStart];
}

/// Event to preview theme changes
class PreviewThemeEvent extends ThemeEvent {
  final ThemeData theme;
  final bool isDark;

  const PreviewThemeEvent({
    required this.theme,
    required this.isDark,
  });

  @override
  List<Object?> get props => [theme, isDark];
}

/// Event to apply previewed theme
class ApplyPreviewedThemeEvent extends ThemeEvent {
  const ApplyPreviewedThemeEvent();
}

/// Event to cancel theme preview
class CancelThemePreviewEvent extends ThemeEvent {
  const CancelThemePreviewEvent();
}

/// Event to import theme from file
class ImportThemeEvent extends ThemeEvent {
  final String filePath;

  const ImportThemeEvent({required this.filePath});

  @override
  List<Object?> get props => [filePath];
}

/// Event to export current theme to file
class ExportThemeEvent extends ThemeEvent {
  final String filePath;

  const ExportThemeEvent({required this.filePath});

  @override
  List<Object?> get props => [filePath];
}

/// Event to reset theme state
class ResetThemeStateEvent extends ThemeEvent {
  const ResetThemeStateEvent();
}