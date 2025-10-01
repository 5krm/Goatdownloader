import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dynamic_color/dynamic_color.dart';

import '../../../core/storage/hive_helper.dart';
import '../../../core/theme/app_theme.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final HiveHelper _hiveHelper;
  Timer? _autoSwitchTimer;

  ThemeBloc({
    required HiveHelper hiveHelper,
  })  : _hiveHelper = hiveHelper,
        super(const ThemeInitial()) {
    on<ChangeThemeEvent>(_onChangeTheme);
    on<ToggleThemeEvent>(_onToggleTheme);
    on<SetSystemThemeEvent>(_onSetSystemTheme);
    on<LoadThemeEvent>(_onLoadTheme);
    on<SaveThemeEvent>(_onSaveTheme);
    on<ResetThemeEvent>(_onResetTheme);
    on<UpdateThemeColorsEvent>(_onUpdateThemeColors);
    on<SetCustomThemeEvent>(_onSetCustomTheme);
    on<ToggleDynamicColorsEvent>(_onToggleDynamicColors);
    on<UpdateFontSettingsEvent>(_onUpdateFontSettings);
    on<SetHighContrastEvent>(_onSetHighContrast);
    on<UpdateThemeByTimeEvent>(_onUpdateThemeByTime);
    on<SetAutoThemeSwitchEvent>(_onSetAutoThemeSwitch);
    on<PreviewThemeEvent>(_onPreviewTheme);
    on<ApplyPreviewedThemeEvent>(_onApplyPreviewedTheme);
    on<CancelThemePreviewEvent>(_onCancelThemePreview);
    on<ImportThemeEvent>(_onImportTheme);
    on<ExportThemeEvent>(_onExportTheme);
    on<ResetThemeStateEvent>(_onResetThemeState);

    // Load theme on initialization
    add(const LoadThemeEvent());
  }

  @override
  Future<void> close() {
    _autoSwitchTimer?.cancel();
    return super.close();
  }

  Future<void> _onChangeTheme(
    ChangeThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      emit(const ThemeLoading());

      final currentState = state;
      ThemeData lightTheme = AppTheme.lightTheme;
      ThemeData darkTheme = AppTheme.darkTheme;

      if (currentState is ThemeLoaded) {
        lightTheme = currentState.lightTheme;
        darkTheme = currentState.darkTheme;
      }

      await _hiveHelper.saveSetting('theme_mode', event.themeMode.index);

      emit(ThemeLoaded(
        themeMode: event.themeMode,
        lightTheme: lightTheme,
        darkTheme: darkTheme,
        isDynamicColorsEnabled: currentState is ThemeLoaded ? currentState.isDynamicColorsEnabled : false,
        isHighContrastEnabled: currentState is ThemeLoaded ? currentState.isHighContrastEnabled : false,
        isAutoSwitchEnabled: currentState is ThemeLoaded ? currentState.isAutoSwitchEnabled : false,
        lightModeStart: currentState is ThemeLoaded ? currentState.lightModeStart : null,
        darkModeStart: currentState is ThemeLoaded ? currentState.darkModeStart : null,
        fontFamily: currentState is ThemeLoaded ? currentState.fontFamily : null,
        fontSize: currentState is ThemeLoaded ? currentState.fontSize : 14.0,
        fontWeight: currentState is ThemeLoaded ? currentState.fontWeight : FontWeight.normal,
      ));

      emit(ThemeChanged(
        themeMode: event.themeMode,
        lightTheme: lightTheme,
        darkTheme: darkTheme,
      ));
    } catch (e) {
      emit(ThemeError(message: 'Failed to change theme: ${e.toString()}'));
    }
  }

  Future<void> _onToggleTheme(
    ToggleThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    final currentState = state;
    if (currentState is ThemeLoaded) {
      final newThemeMode = currentState.themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
      add(ChangeThemeEvent(themeMode: newThemeMode));
    }
  }

  Future<void> _onSetSystemTheme(
    SetSystemThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    add(const ChangeThemeEvent(themeMode: ThemeMode.system));
  }

  Future<void> _onLoadTheme(
    LoadThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      emit(const ThemeLoading());

      // Load theme mode
      final themeModeIndex = await _hiveHelper.getSetting<int>('theme_mode') ?? 0;
      final themeMode = ThemeMode.values[themeModeIndex];

      // Load theme settings
      final isDynamicColorsEnabled = await _hiveHelper.getSetting<bool>('dynamic_colors_enabled') ?? false;
      final isHighContrastEnabled = await _hiveHelper.getSetting<bool>('high_contrast_enabled') ?? false;
      final isAutoSwitchEnabled = await _hiveHelper.getSetting<bool>('auto_switch_enabled') ?? false;
      
      // Load auto switch times
      TimeOfDay? lightModeStart;
      TimeOfDay? darkModeStart;
      
      final lightStartData = await _hiveHelper.getSetting<Map<String, dynamic>>('light_mode_start');
      if (lightStartData != null) {
        lightModeStart = TimeOfDay(
          hour: lightStartData['hour'],
          minute: lightStartData['minute'],
        );
      }
      
      final darkStartData = await _hiveHelper.getSetting<Map<String, dynamic>>('dark_mode_start');
      if (darkStartData != null) {
        darkModeStart = TimeOfDay(
          hour: darkStartData['hour'],
          minute: darkStartData['minute'],
        );
      }

      // Load font settings
      final fontFamily = await _hiveHelper.getSetting<String>('font_family');
      final fontSize = await _hiveHelper.getSetting<double>('font_size') ?? 14.0;
      final fontWeightIndex = await _hiveHelper.getSetting<int>('font_weight') ?? 3;
      final fontWeight = FontWeight.values[fontWeightIndex];

      // Load custom colors
      final primaryColorValue = await _hiveHelper.getSetting<int>('primary_color');
      final accentColorValue = await _hiveHelper.getSetting<int>('accent_color');
      final backgroundColorValue = await _hiveHelper.getSetting<int>('background_color');

      // Build themes
      ThemeData lightTheme = AppTheme.lightTheme;
      ThemeData darkTheme = AppTheme.darkTheme;

      // Apply dynamic colors if enabled
      if (isDynamicColorsEnabled) {
        try {
          final dynamicColorScheme = await DynamicColorPlugin.getCorePalette();
          if (dynamicColorScheme != null) {
            lightTheme = AppTheme.buildDynamicLightTheme(dynamicColorScheme);
            darkTheme = AppTheme.buildDynamicDarkTheme(dynamicColorScheme);
          }
        } catch (e) {
          // Dynamic colors not supported, use default themes
        }
      }

      // Apply custom colors
      if (primaryColorValue != null || accentColorValue != null || backgroundColorValue != null) {
        lightTheme = AppTheme.buildCustomTheme(
          baseTheme: lightTheme,
          primaryColor: primaryColorValue != null ? Color(primaryColorValue) : null,
          accentColor: accentColorValue != null ? Color(accentColorValue) : null,
          backgroundColor: backgroundColorValue != null ? Color(backgroundColorValue) : null,
        );
        
        darkTheme = AppTheme.buildCustomTheme(
          baseTheme: darkTheme,
          primaryColor: primaryColorValue != null ? Color(primaryColorValue) : null,
          accentColor: accentColorValue != null ? Color(accentColorValue) : null,
          backgroundColor: backgroundColorValue != null ? Color(backgroundColorValue) : null,
        );
      }

      // Apply high contrast
      if (isHighContrastEnabled) {
        lightTheme = AppTheme.buildHighContrastTheme(lightTheme);
        darkTheme = AppTheme.buildHighContrastTheme(darkTheme);
      }

      // Apply font settings
      if (fontFamily != null || fontSize != 14.0 || fontWeight != FontWeight.normal) {
        lightTheme = AppTheme.buildFontTheme(
          baseTheme: lightTheme,
          fontFamily: fontFamily,
          fontSize: fontSize,
          fontWeight: fontWeight,
        );
        
        darkTheme = AppTheme.buildFontTheme(
          baseTheme: darkTheme,
          fontFamily: fontFamily,
          fontSize: fontSize,
          fontWeight: fontWeight,
        );
      }

      emit(ThemeLoaded(
        themeMode: themeMode,
        lightTheme: lightTheme,
        darkTheme: darkTheme,
        isDynamicColorsEnabled: isDynamicColorsEnabled,
        isHighContrastEnabled: isHighContrastEnabled,
        isAutoSwitchEnabled: isAutoSwitchEnabled,
        lightModeStart: lightModeStart,
        darkModeStart: darkModeStart,
        fontFamily: fontFamily,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ));

      // Set up auto switch timer if enabled
      if (isAutoSwitchEnabled && lightModeStart != null && darkModeStart != null) {
        _setupAutoSwitchTimer(lightModeStart, darkModeStart);
      }
    } catch (e) {
      emit(ThemeError(message: 'Failed to load theme: ${e.toString()}'));
    }
  }

  Future<void> _onSaveTheme(
    SaveThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      await _hiveHelper.saveSetting('theme_mode', event.themeMode.index);
      emit(ThemeSaved(themeMode: event.themeMode));
    } catch (e) {
      emit(ThemeError(message: 'Failed to save theme: ${e.toString()}'));
    }
  }

  Future<void> _onResetTheme(
    ResetThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      emit(const ThemeLoading());

      // Clear all theme settings
      await _hiveHelper.removeSetting('theme_mode');
      await _hiveHelper.removeSetting('dynamic_colors_enabled');
      await _hiveHelper.removeSetting('high_contrast_enabled');
      await _hiveHelper.removeSetting('auto_switch_enabled');
      await _hiveHelper.removeSetting('light_mode_start');
      await _hiveHelper.removeSetting('dark_mode_start');
      await _hiveHelper.removeSetting('font_family');
      await _hiveHelper.removeSetting('font_size');
      await _hiveHelper.removeSetting('font_weight');
      await _hiveHelper.removeSetting('primary_color');
      await _hiveHelper.removeSetting('accent_color');
      await _hiveHelper.removeSetting('background_color');

      final defaultLightTheme = AppTheme.lightTheme;
      final defaultDarkTheme = AppTheme.darkTheme;

      emit(ThemeReset(
        defaultLightTheme: defaultLightTheme,
        defaultDarkTheme: defaultDarkTheme,
      ));

      // Reload theme
      add(const LoadThemeEvent());
    } catch (e) {
      emit(ThemeError(message: 'Failed to reset theme: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateThemeColors(
    UpdateThemeColorsEvent event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      emit(const ThemeLoading());

      // Save colors
      if (event.primaryColor != null) {
        await _hiveHelper.saveSetting('primary_color', event.primaryColor!.value);
      }
      if (event.accentColor != null) {
        await _hiveHelper.saveSetting('accent_color', event.accentColor!.value);
      }
      if (event.backgroundColor != null) {
        await _hiveHelper.saveSetting('background_color', event.backgroundColor!.value);
      }

      // Reload theme to apply changes
      add(const LoadThemeEvent());
    } catch (e) {
      emit(ThemeError(message: 'Failed to update theme colors: ${e.toString()}'));
    }
  }

  Future<void> _onSetCustomTheme(
    SetCustomThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      emit(const ThemeLoading());

      emit(CustomThemeSet(
        lightTheme: event.lightTheme,
        darkTheme: event.darkTheme,
      ));

      // Update current state
      final currentState = state;
      if (currentState is ThemeLoaded) {
        emit(currentState.copyWith(
          lightTheme: event.lightTheme,
          darkTheme: event.darkTheme,
        ));
      }
    } catch (e) {
      emit(ThemeError(message: 'Failed to set custom theme: ${e.toString()}'));
    }
  }

  Future<void> _onToggleDynamicColors(
    ToggleDynamicColorsEvent event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      emit(const ThemeLoading());

      await _hiveHelper.saveSetting('dynamic_colors_enabled', event.enabled);

      emit(DynamicColorsToggled(enabled: event.enabled));

      // Reload theme to apply changes
      add(const LoadThemeEvent());
    } catch (e) {
      emit(ThemeError(message: 'Failed to toggle dynamic colors: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateFontSettings(
    UpdateFontSettingsEvent event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      emit(const ThemeLoading());

      if (event.fontFamily != null) {
        await _hiveHelper.saveSetting('font_family', event.fontFamily);
      }
      if (event.fontSize != null) {
        await _hiveHelper.saveSetting('font_size', event.fontSize);
      }
      if (event.fontWeight != null) {
        await _hiveHelper.saveSetting('font_weight', event.fontWeight!.index);
      }

      // Reload theme to apply changes
      add(const LoadThemeEvent());
    } catch (e) {
      emit(ThemeError(message: 'Failed to update font settings: ${e.toString()}'));
    }
  }

  Future<void> _onSetHighContrast(
    SetHighContrastEvent event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      emit(const ThemeLoading());

      await _hiveHelper.saveSetting('high_contrast_enabled', event.enabled);

      // Reload theme to apply changes
      add(const LoadThemeEvent());
    } catch (e) {
      emit(ThemeError(message: 'Failed to set high contrast: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateThemeByTime(
    UpdateThemeByTimeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    final currentState = state;
    if (currentState is ThemeLoaded && currentState.isAutoSwitchEnabled) {
      final currentTime = TimeOfDay.fromDateTime(event.currentTime);
      final lightStart = currentState.lightModeStart;
      final darkStart = currentState.darkModeStart;

      if (lightStart != null && darkStart != null) {
        final shouldBeDark = _shouldUseDarkMode(currentTime, lightStart, darkStart);
        final newThemeMode = shouldBeDark ? ThemeMode.dark : ThemeMode.light;

        if (newThemeMode != currentState.themeMode) {
          emit(ThemeUpdatedByTime(
            newThemeMode: newThemeMode,
            updateTime: event.currentTime,
          ));
          add(ChangeThemeEvent(themeMode: newThemeMode));
        }
      }
    }
  }

  Future<void> _onSetAutoThemeSwitch(
    SetAutoThemeSwitchEvent event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      emit(const ThemeLoading());

      await _hiveHelper.saveSetting('auto_switch_enabled', event.enabled);

      if (event.lightModeStart != null) {
        await _hiveHelper.saveSetting('light_mode_start', {
          'hour': event.lightModeStart!.hour,
          'minute': event.lightModeStart!.minute,
        });
      }

      if (event.darkModeStart != null) {
        await _hiveHelper.saveSetting('dark_mode_start', {
          'hour': event.darkModeStart!.hour,
          'minute': event.darkModeStart!.minute,
        });
      }

      emit(AutoThemeSwitchSet(
        enabled: event.enabled,
        lightModeStart: event.lightModeStart,
        darkModeStart: event.darkModeStart,
      ));

      // Set up or cancel auto switch timer
      if (event.enabled && event.lightModeStart != null && event.darkModeStart != null) {
        _setupAutoSwitchTimer(event.lightModeStart!, event.darkModeStart!);
      } else {
        _autoSwitchTimer?.cancel();
      }

      // Reload theme
      add(const LoadThemeEvent());
    } catch (e) {
      emit(ThemeError(message: 'Failed to set auto theme switch: ${e.toString()}'));
    }
  }

  Future<void> _onPreviewTheme(
    PreviewThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    final currentState = state;
    if (currentState is ThemeLoaded) {
      emit(ThemePreviewing(
        previewTheme: event.theme,
        isDark: event.isDark,
        originalLightTheme: currentState.lightTheme,
        originalDarkTheme: currentState.darkTheme,
        originalThemeMode: currentState.themeMode,
      ));
    }
  }

  Future<void> _onApplyPreviewedTheme(
    ApplyPreviewedThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    final currentState = state;
    if (currentState is ThemePreviewing) {
      emit(PreviewedThemeApplied(
        appliedTheme: currentState.previewTheme,
        isDark: currentState.isDark,
      ));

      // Apply the theme permanently
      if (currentState.isDark) {
        add(SetCustomThemeEvent(
          lightTheme: currentState.originalLightTheme,
          darkTheme: currentState.previewTheme,
        ));
      } else {
        add(SetCustomThemeEvent(
          lightTheme: currentState.previewTheme,
          darkTheme: currentState.originalDarkTheme,
        ));
      }
    }
  }

  Future<void> _onCancelThemePreview(
    CancelThemePreviewEvent event,
    Emitter<ThemeState> emit,
  ) async {
    final currentState = state;
    if (currentState is ThemePreviewing) {
      emit(ThemePreviewCancelled(
        restoredLightTheme: currentState.originalLightTheme,
        restoredDarkTheme: currentState.originalDarkTheme,
        restoredThemeMode: currentState.originalThemeMode,
      ));

      // Restore original theme
      add(SetCustomThemeEvent(
        lightTheme: currentState.originalLightTheme,
        darkTheme: currentState.originalDarkTheme,
      ));
    }
  }

  Future<void> _onImportTheme(
    ImportThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      emit(const ThemeLoading());

      final file = File(event.filePath);
      if (!await file.exists()) {
        throw Exception('Theme file not found');
      }

      final content = await file.readAsString();
      final themeData = jsonDecode(content);

      // TODO: Parse theme data and create ThemeData objects
      final importedLightTheme = AppTheme.lightTheme;
      final importedDarkTheme = AppTheme.darkTheme;

      emit(ThemeImported(
        filePath: event.filePath,
        importedLightTheme: importedLightTheme,
        importedDarkTheme: importedDarkTheme,
      ));

      add(SetCustomThemeEvent(
        lightTheme: importedLightTheme,
        darkTheme: importedDarkTheme,
      ));
    } catch (e) {
      emit(ThemeError(message: 'Failed to import theme: ${e.toString()}'));
    }
  }

  Future<void> _onExportTheme(
    ExportThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      emit(const ThemeLoading());

      final currentState = state;
      if (currentState is ThemeLoaded) {
        // TODO: Serialize theme data to JSON
        final themeData = {
          'light_theme': {},
          'dark_theme': {},
          'settings': {
            'theme_mode': currentState.themeMode.index,
            'dynamic_colors_enabled': currentState.isDynamicColorsEnabled,
            'high_contrast_enabled': currentState.isHighContrastEnabled,
            'font_family': currentState.fontFamily,
            'font_size': currentState.fontSize,
            'font_weight': currentState.fontWeight.index,
          },
        };

        final file = File(event.filePath);
        await file.writeAsString(jsonEncode(themeData));

        emit(ThemeExported(filePath: event.filePath));
      }
    } catch (e) {
      emit(ThemeError(message: 'Failed to export theme: ${e.toString()}'));
    }
  }

  Future<void> _onResetThemeState(
    ResetThemeStateEvent event,
    Emitter<ThemeState> emit,
  ) async {
    _autoSwitchTimer?.cancel();
    emit(const ThemeInitial());
  }

  // Helper methods
  void _setupAutoSwitchTimer(TimeOfDay lightStart, TimeOfDay darkStart) {
    _autoSwitchTimer?.cancel();
    
    _autoSwitchTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      add(UpdateThemeByTimeEvent(currentTime: DateTime.now()));
    });
  }

  bool _shouldUseDarkMode(TimeOfDay current, TimeOfDay lightStart, TimeOfDay darkStart) {
    final currentMinutes = current.hour * 60 + current.minute;
    final lightStartMinutes = lightStart.hour * 60 + lightStart.minute;
    final darkStartMinutes = darkStart.hour * 60 + darkStart.minute;

    if (lightStartMinutes < darkStartMinutes) {
      // Normal case: light mode during day, dark mode during night
      return currentMinutes >= darkStartMinutes || currentMinutes < lightStartMinutes;
    } else {
      // Edge case: dark mode during day, light mode during night
      return currentMinutes >= darkStartMinutes && currentMinutes < lightStartMinutes;
    }
  }
}