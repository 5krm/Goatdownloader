import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dynamic_color/dynamic_color.dart';

// Core
import 'core/di/injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'core/storage/hive_helper.dart';

// Presentation - BLoCs
import 'presentation/blocs/search/search_bloc.dart';
import 'presentation/blocs/download/download_bloc.dart';
import 'presentation/blocs/settings/settings_bloc.dart';
import 'presentation/blocs/settings/settings_event.dart';
import 'presentation/blocs/theme/theme_bloc.dart';
import 'presentation/blocs/theme/theme_event.dart';
import 'presentation/blocs/theme/theme_state.dart';

// Presentation - Screens
import 'presentation/screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  await HiveHelper().init();
  
  // Initialize dependency injection
  await di.init();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(const GoatDownloaderApp());
}

class GoatDownloaderApp extends StatelessWidget {
  const GoatDownloaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>(
          create: (context) => di.sl<ThemeBloc>()..add(const LoadThemeEvent()),
        ),
        BlocProvider<SettingsBloc>(
          create: (context) => di.sl<SettingsBloc>()..add(const LoadSettingsEvent()),
        ),
        BlocProvider<SearchBloc>(
          create: (context) => di.sl<SearchBloc>(),
        ),
        BlocProvider<DownloadBloc>(
          create: (context) => di.sl<DownloadBloc>(),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return DynamicColorBuilder(
            builder: (lightDynamic, darkDynamic) {
              ColorScheme? lightColorScheme;
              ColorScheme? darkColorScheme;
              
              if (themeState is ThemeLoaded && themeState.isDynamicColorsEnabled) {
                lightColorScheme = lightDynamic?.harmonized();
                darkColorScheme = darkDynamic?.harmonized();
              }
              
              return MaterialApp(
                title: 'Goat Downloader',
                debugShowCheckedModeBanner: false,
                
                // Theme configuration
                theme: _buildLightTheme(context, themeState, lightColorScheme),
                darkTheme: _buildDarkTheme(context, themeState, darkColorScheme),
                themeMode: _getThemeMode(themeState),
                
                // Localization
                supportedLocales: const [
                  Locale('en', 'US'), // English
                  Locale('ar', 'SA'), // Arabic
                ],
                
                // Navigation
                home: const SplashScreen(),
                
                // Global error handling
                builder: (context, child) {
                  return _GlobalErrorHandler(child: child);
                },
              );
            },
          );
        },
      ),
    );
  }

  ThemeData _buildLightTheme(
    BuildContext context,
    ThemeState themeState,
    ColorScheme? dynamicColorScheme,
  ) {
    if (themeState is ThemeLoaded) {
      return AppTheme.lightTheme.copyWith(
        colorScheme: dynamicColorScheme ?? AppTheme.lightTheme.colorScheme,
        textTheme: _getTextTheme(themeState, AppTheme.lightTheme.textTheme),
      );
    }
    return AppTheme.lightTheme.copyWith(
      colorScheme: dynamicColorScheme ?? AppTheme.lightTheme.colorScheme,
    );
  }

  ThemeData _buildDarkTheme(
    BuildContext context,
    ThemeState themeState,
    ColorScheme? dynamicColorScheme,
  ) {
    if (themeState is ThemeLoaded) {
      return AppTheme.darkTheme.copyWith(
        colorScheme: dynamicColorScheme ?? AppTheme.darkTheme.colorScheme,
        textTheme: _getTextTheme(themeState, AppTheme.darkTheme.textTheme),
      );
    }
    return AppTheme.darkTheme.copyWith(
      colorScheme: dynamicColorScheme ?? AppTheme.darkTheme.colorScheme,
    );
  }

  TextTheme _getTextTheme(ThemeState themeState, TextTheme baseTextTheme) {
    if (themeState is ThemeLoaded) {
      final themeData = AppTheme.buildFontTheme(
        baseTheme: ThemeData(textTheme: baseTextTheme),
        fontFamily: themeState.fontFamily,
        fontSize: themeState.fontSize,
        fontWeight: themeState.fontWeight,
      );
      return themeData.textTheme;
    }
    return baseTextTheme;
  }

  ThemeMode _getThemeMode(ThemeState themeState) {
    if (themeState is ThemeLoaded) {
      return themeState.themeMode;
    }
    return ThemeMode.system;
  }
}

class _GlobalErrorHandler extends StatelessWidget {
  final Widget? child;

  const _GlobalErrorHandler({this.child});

  @override
  Widget build(BuildContext context) {
    return child ?? const SizedBox.shrink();
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));
    
    _startAnimation();
  }

  void _startAnimation() async {
    await _animationController.forward();
    
    // Wait for a moment to show the splash screen
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Navigate to home screen
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withOpacity(0.8),
              theme.colorScheme.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.download,
                          size: 60,
                          color: Color(0xFF2196F3),
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 32),
              
              // App Name
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Text(
                          'Goat Downloader',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Download videos from anywhere',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 64),
              
              // Loading Indicator
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 16),
              
              // Loading Text
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'Loading...',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                        letterSpacing: 0.5,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Global error widget for handling uncaught exceptions
class GlobalErrorWidget extends StatelessWidget {
  final FlutterErrorDetails errorDetails;

  const GlobalErrorWidget({
    super.key,
    required this.errorDetails,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.errorContainer,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                'Oops! Something went wrong',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'We\'re sorry for the inconvenience. Please restart the app.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // Restart the app
                  SystemNavigator.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text('Restart App'),
              ),
              const SizedBox(height: 16),
              if (errorDetails.exception.toString().isNotEmpty)
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        errorDetails.exception.toString(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Set global error widget
void setGlobalErrorWidget() {
  ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
    return GlobalErrorWidget(errorDetails: errorDetails);
  };
}
