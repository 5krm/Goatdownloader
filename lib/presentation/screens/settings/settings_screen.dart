import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goatdownloder/presentation/blocs/settings/settings_event.dart';
import 'package:goatdownloder/presentation/blocs/settings/settings_state.dart';
import '../../blocs/settings/settings_bloc.dart';
import '../../blocs/theme/theme_bloc.dart';
import '../../blocs/theme/theme_event.dart';
import '../../blocs/theme/theme_state.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Load settings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsBloc>().add(const LoadSettingsEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          if (state is SettingsLoading) {
            return const Center(
              child: LoadingWidget(
                message: 'Loading settings...',
              ),
            );
          }
          
          if (state is SettingsError) {
            return Center(
              child: CustomErrorWidget(
                message: state.message,
                type: ErrorType.generic,
                onRetry: () {
                  context.read<SettingsBloc>().add(const LoadSettingsEvent());
                },
              ),
            );
          }
          
          if (state is SettingsLoaded) {
            return _buildSettingsContent(context, state);
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSettingsContent(BuildContext context, SettingsLoaded state) {
    final theme = Theme.of(context);
    
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: const Text('Settings'),
          floating: true,
          snap: true,
          actions: [
            PopupMenuButton<String>(
              onSelected: _onMenuSelected,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'export',
                  child: ListTile(
                    leading: Icon(Icons.upload),
                    title: Text('Export Settings'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'import',
                  child: ListTile(
                    leading: Icon(Icons.download),
                    title: Text('Import Settings'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'reset',
                  child: ListTile(
                    leading: Icon(Icons.restore),
                    title: Text('Reset to Default'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
        
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildDownloadSettings(context, state.downloadSettings),
              const SizedBox(height: 16),
              _buildVideoPlayerSettings(context, state.videoPlayerSettings),
              const SizedBox(height: 16),
              _buildAppSettings(context, state.appSettings),
              const SizedBox(height: 16),
              _buildPrivacySettings(context, state.privacySettings),
              const SizedBox(height: 16),
              _buildNetworkSettings(context, state.networkSettings),
              const SizedBox(height: 16),
              _buildSecuritySettings(context, state.securitySettings),
              const SizedBox(height: 16),
              _buildSystemSection(context),
              const SizedBox(height: 16),
              _buildAboutSection(context),
              const SizedBox(height: 32),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadSettings(BuildContext context, Map<String, dynamic> settings) {
    return _buildSettingsSection(
      context,
      'Download Settings',
      Icons.download,
      [
        _buildSwitchTile(
          context,
          'Auto-start downloads',
          'Start downloads automatically when added',
          settings['autoStartDownloads'] ?? false,
          (value) {
            context.read<SettingsBloc>().add(
              UpdateDownloadSettingsEvent(
                // Use individual parameters instead of settings object
              ),
            );
          },
        ),
        
        _buildSwitchTile(
          context,
          'Parallel downloads',
          'Download multiple files simultaneously',
          settings['parallelDownloads'] ?? false,
          (value) {
            context.read<SettingsBloc>().add(
              UpdateDownloadSettingsEvent(
                // Use individual parameters instead of settings object
              ),
            );
          },
        ),
        
        _buildSliderTile(
          context,
          'Max concurrent downloads',
          'Maximum number of simultaneous downloads',
          (settings['maxConcurrentDownloads'] ?? 3).toDouble(),
          1,
          10,
          (value) {
            context.read<SettingsBloc>().add(
              UpdateDownloadSettingsEvent(
                maxConcurrentDownloads: value.round(),
              ),
            );
          },
        ),
        
        _buildListTile(
          context,
          'Default download location',
          settings['downloadPath'] ?? '/storage/emulated/0/Download',
          Icons.folder,
          () => _showDownloadLocationDialog(context, settings),
        ),
        
        _buildDropdownTile(
          context,
          'Default video quality',
          settings['defaultVideoQuality'] ?? 'Best',
          ['Best', 'High', 'Medium', 'Low'],
          (value) {
            context.read<SettingsBloc>().add(
              UpdateDownloadSettingsEvent(
                defaultQuality: value!,
              ),
            );
          },
        ),
        
        _buildDropdownTile(
          context,
          'Default audio quality',
          settings['defaultAudioQuality'] ?? 'Best',
          ['Best', 'High', 'Medium', 'Low'],
          (value) {
            context.read<SettingsBloc>().add(
              UpdateDownloadSettingsEvent(
                defaultQuality: value!,
              ),
            );
          },
        ),
        
        _buildSwitchTile(
          context,
          'Auto-retry failed downloads',
          'Automatically retry failed downloads',
          settings['autoRetryFailedDownloads'] ?? true,
          (value) {
            context.read<SettingsBloc>().add(
              UpdateDownloadSettingsEvent(
                autoRetryFailedDownloads: value,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildVideoPlayerSettings(BuildContext context, Map<String, dynamic> settings) {
    return _buildSettingsSection(
      context,
      'Video Player',
      Icons.play_circle,
      [
        _buildSwitchTile(
          context,
          'Auto-play videos',
          'Start playing videos automatically',
          settings['autoPlay'] ?? false,
          (value) {
            context.read<SettingsBloc>().add(
              UpdateVideoPlayerSettingsEvent(
                autoPlay: value,
              ),
            );
          },
        ),
        
        _buildSwitchTile(
          context,
          'Loop videos',
          'Repeat videos when they finish',
          settings['loopVideos'] ?? false,
          (value) {
            context.read<SettingsBloc>().add(
              UpdateVideoPlayerSettingsEvent(
                loopVideos: value,
              ),
            );
          },
        ),
        
        _buildSliderTile(
          context,
          'Default volume',
          'Default volume level for video playback',
          settings['defaultVolume'] ?? 0.8,
          0,
          1,
          (value) {
            context.read<SettingsBloc>().add(
              UpdateVideoPlayerSettingsEvent(
                // Note: defaultVolume is not in the event parameters
              ),
            );
          },
        ),
        
        _buildSliderTile(
          context,
          'Playback speed',
          'Default playback speed',
          settings['playbackSpeed'] ?? 1.0,
          0.25,
          2.0,
          (value) {
            context.read<SettingsBloc>().add(
              UpdateVideoPlayerSettingsEvent(
                playbackSpeed: value,
              ),
            );
          },
        ),
        
        _buildSwitchTile(
          context,
          'Show subtitles',
          'Display subtitles when available',
          settings['showSubtitles'] ?? false,
          (value) {
            context.read<SettingsBloc>().add(
              UpdateVideoPlayerSettingsEvent(
                showSubtitles: value,
              ),
            );
          },
        ),
        
        _buildDropdownTile(
          context,
          'Subtitle language',
          settings['subtitleLanguage'] ?? 'Auto',
          ['Auto', 'English', 'Arabic', 'Spanish', 'French', 'German'],
          (value) {
            context.read<SettingsBloc>().add(
              UpdateVideoPlayerSettingsEvent(
                subtitleLanguage: value!,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAppSettings(BuildContext context, Map<String, dynamic> settings) {
    return _buildSettingsSection(
      context,
      'App Settings',
      Icons.settings,
      [
        _buildDropdownTile(
          context,
          'Language',
          settings['language'] ?? 'English',
          ['English', 'Arabic'],
          (value) {
            context.read<SettingsBloc>().add(
              UpdateAppSettingsEvent(
                language: value!,
                autoUpdate: settings['autoUpdate'] ?? false,
                sendCrashReports: settings['sendCrashReports'] ?? false,
                sendUsageAnalytics: settings['sendUsageAnalytics'] ?? false,
              ),
            );
          },
        ),
        
        _buildListTile(
          context,
          'Theme',
          _getThemeDisplayName(context),
          Icons.palette,
          () => _showThemeDialog(context),
        ),
        
        _buildSwitchTile(
          context,
          'Dark mode',
          'Use dark theme',
          _isDarkMode(context),
          (value) {
            context.read<ThemeBloc>().add(
              value ? ChangeThemeEvent(themeMode: ThemeMode.dark) : ChangeThemeEvent(themeMode: ThemeMode.light),
            );
          },
        ),
        
        _buildSwitchTile(
          context,
          'Auto-update',
          'Automatically check for app updates',
          settings['autoUpdate'] ?? false,
          (value) {
            context.read<SettingsBloc>().add(
              UpdateAppSettingsEvent(
                language: settings['language'] ?? 'English',
                autoUpdate: value,
                sendCrashReports: settings['sendCrashReports'] ?? false,
                sendUsageAnalytics: settings['sendUsageAnalytics'] ?? false,
              ),
            );
          },
        ),
        
        _buildSwitchTile(
          context,
          'Send crash reports',
          'Help improve the app by sending crash reports',
          settings['sendCrashReports'] ?? false,
          (value) {
            context.read<SettingsBloc>().add(
              UpdateAppSettingsEvent(
                language: settings['language'] ?? 'English',
                autoUpdate: settings['autoUpdate'] ?? false,
                sendCrashReports: value,
                sendUsageAnalytics: settings['sendUsageAnalytics'] ?? false,
              ),
            );
          },
        ),
        
        _buildSwitchTile(
          context,
          'Send usage analytics',
          'Help improve the app by sending anonymous usage data',
          settings['sendUsageAnalytics'] ?? false,
          (value) {
            context.read<SettingsBloc>().add(
              UpdateAppSettingsEvent(
                language: settings['language'] ?? 'English',
                autoUpdate: settings['autoUpdate'] ?? false,
                sendCrashReports: settings['sendCrashReports'] ?? false,
                sendUsageAnalytics: value,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPrivacySettings(BuildContext context, Map<String, dynamic> settings) {
    return _buildSettingsSection(
      context,
      'Privacy',
      Icons.privacy_tip,
      [
        _buildSwitchTile(
          context,
          'Save download history',
          'Keep a record of downloaded videos',
          settings['saveDownloadHistory'] ?? true,
          (value) {
            context.read<SettingsBloc>().add(
              UpdatePrivacySettingsEvent(
                saveDownloadHistory: value,
                saveSearchHistory: settings['saveSearchHistory'] ?? true,
                incognitoMode: settings['incognitoMode'] ?? false,
              ),
            );
          },
        ),
        
        _buildSwitchTile(
          context,
          'Save search history',
          'Keep a record of your searches',
          settings['saveSearchHistory'] ?? true,
          (value) {
            context.read<SettingsBloc>().add(
              UpdatePrivacySettingsEvent(
                saveDownloadHistory: settings['saveDownloadHistory'] ?? true,
                saveSearchHistory: value,
                incognitoMode: settings['incognitoMode'] ?? false,
              ),
            );
          },
        ),
        
        _buildSwitchTile(
          context,
          'Incognito mode',
          'Don\'t save any history or data',
          settings['incognitoMode'] ?? false,
          (value) {
            context.read<SettingsBloc>().add(
              UpdatePrivacySettingsEvent(
                saveDownloadHistory: settings['saveDownloadHistory'] ?? true,
                saveSearchHistory: settings['saveSearchHistory'] ?? true,
                incognitoMode: value,
              ),
            );
          },
        ),
        
        _buildListTile(
          context,
          'Clear download history',
          'Remove all download history',
          Icons.delete_sweep,
          () => _showClearHistoryDialog(context, 'download'),
        ),
        
        _buildListTile(
          context,
          'Clear search history',
          'Remove all search history',
          Icons.delete_sweep,
          () => _showClearHistoryDialog(context, 'search'),
        ),
        
        _buildListTile(
          context,
          'Clear cache',
          'Free up storage space',
          Icons.cleaning_services,
          () => _showClearCacheDialog(context),
        ),
      ],
    );
  }

  Widget _buildNetworkSettings(BuildContext context, Map<String, dynamic> settings) {
    return _buildSettingsSection(
      context,
      'Network',
      Icons.network_check,
      [
        _buildSwitchTile(
          context,
          'Use proxy',
          'Route traffic through a proxy server',
          settings['useProxy'] ?? false,
          (value) {
            context.read<SettingsBloc>().add(
              UpdateNetworkSettingsEvent(
                useProxy: value,
                proxyHost: settings['proxyHost'],
                proxyPort: settings['proxyPort'],
                proxyUsername: settings['proxyUsername'],
                proxyPassword: settings['proxyPassword'],
                connectionTimeout: settings['connectionTimeout'],
                readTimeout: settings['readTimeout'],
                maxRetries: settings['maxRetries'],
                enableIPv6: settings['enableIPv6'],
                userAgent: settings['userAgent'],
              ),
            );
          },
        ),
        
        if (settings['useProxy'] ?? false) ...[
          _buildTextFieldTile(
            context,
            'Proxy host',
            settings['proxyHost'] ?? '',
            'Enter proxy host',
            (value) {
              context.read<SettingsBloc>().add(
                UpdateNetworkSettingsEvent(
                  useProxy: settings['useProxy'],
                  proxyHost: value,
                  proxyPort: settings['proxyPort'],
                  proxyUsername: settings['proxyUsername'],
                  proxyPassword: settings['proxyPassword'],
                  connectionTimeout: settings['connectionTimeout'],
                  readTimeout: settings['readTimeout'],
                  maxRetries: settings['maxRetries'],
                  enableIPv6: settings['enableIPv6'],
                  userAgent: settings['userAgent'],
                ),
              );
            },
          ),
          
          _buildTextFieldTile(
            context,
            'Proxy port',
            (settings['proxyPort'] ?? 8080).toString(),
            'Enter proxy port',
            (value) {
              final port = int.tryParse(value) ?? 8080;
              context.read<SettingsBloc>().add(
                UpdateNetworkSettingsEvent(
                  useProxy: settings['useProxy'],
                  proxyHost: settings['proxyHost'],
                  proxyPort: port,
                  proxyUsername: settings['proxyUsername'],
                  proxyPassword: settings['proxyPassword'],
                  connectionTimeout: settings['connectionTimeout'],
                  readTimeout: settings['readTimeout'],
                  maxRetries: settings['maxRetries'],
                  enableIPv6: settings['enableIPv6'],
                  userAgent: settings['userAgent'],
                ),
              );
            },
          ),
        ],
        
        _buildSliderTile(
          context,
          'Connection timeout (seconds)',
          'Maximum time to wait for connection',
          (settings['connectionTimeout'] ?? 30).toDouble(),
          5,
          60,
          (value) {
            context.read<SettingsBloc>().add(
              UpdateNetworkSettingsEvent(
                useProxy: settings['useProxy'],
                proxyHost: settings['proxyHost'],
                proxyPort: settings['proxyPort'],
                proxyUsername: settings['proxyUsername'],
                proxyPassword: settings['proxyPassword'],
                connectionTimeout: value.round(),
                readTimeout: settings['readTimeout'],
                maxRetries: settings['maxRetries'],
                enableIPv6: settings['enableIPv6'],
                userAgent: settings['userAgent'],
              ),
            );
          },
        ),
        
        _buildSliderTile(
          context,
          'Read timeout (seconds)',
          'Maximum time to wait for data',
          (settings['readTimeout'] ?? 60).toDouble(),
          10,
          120,
          (value) {
            context.read<SettingsBloc>().add(
              UpdateNetworkSettingsEvent(
                useProxy: settings['useProxy'],
                proxyHost: settings['proxyHost'],
                proxyPort: settings['proxyPort'],
                proxyUsername: settings['proxyUsername'],
                proxyPassword: settings['proxyPassword'],
                connectionTimeout: settings['connectionTimeout'],
                readTimeout: value.round(),
                maxRetries: settings['maxRetries'],
                enableIPv6: settings['enableIPv6'],
                userAgent: settings['userAgent'],
              ),
            );
          },
        ),
        
        _buildSliderTile(
          context,
          'Max retry attempts',
          'Maximum number of retry attempts',
          (settings['maxRetries'] ?? 3).toDouble(),
          1,
          10,
          (value) {
            context.read<SettingsBloc>().add(
              UpdateNetworkSettingsEvent(
                useProxy: settings['useProxy'],
                proxyHost: settings['proxyHost'],
                proxyPort: settings['proxyPort'],
                proxyUsername: settings['proxyUsername'],
                proxyPassword: settings['proxyPassword'],
                connectionTimeout: settings['connectionTimeout'],
                readTimeout: settings['readTimeout'],
                maxRetries: value.round(),
                enableIPv6: settings['enableIPv6'],
                userAgent: settings['userAgent'],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSecuritySettings(BuildContext context, Map<String, dynamic> settings) {
    return _buildSettingsSection(
      context,
      'Security',
      Icons.security,
      [
        _buildSwitchTile(
          context,
          'Require authentication',
          'Require biometric or PIN to access app',
          settings['requireAuthentication'] ?? false,
          (value) {
            context.read<SettingsBloc>().add(
              UpdateSecuritySettingsEvent(
                requireAuthentication: value,
                authenticationMethod: settings['authenticationMethod'] ?? 'Biometric',
                autoLockTimeout: settings['autoLockTimeout'] ?? 5,
                hideInRecentApps: settings['hideInRecentApps'] ?? false,
                blockScreenshots: settings['blockScreenshots'] ?? false,
              ),
            );
          },
        ),
        
        if (settings['requireAuthentication'] ?? false) ...[
          _buildDropdownTile(
            context,
            'Authentication method',
            settings['authenticationMethod'] ?? 'Biometric',
            ['Biometric', 'PIN', 'Password'],
            (value) {
              context.read<SettingsBloc>().add(
                UpdateSecuritySettingsEvent(
                  requireAuthentication: settings['requireAuthentication'] ?? false,
                  authenticationMethod: value!,
                  autoLockTimeout: settings['autoLockTimeout'] ?? 5,
                  hideInRecentApps: settings['hideInRecentApps'] ?? false,
                  blockScreenshots: settings['blockScreenshots'] ?? false,
                ),
              );
            },
          ),
          
          _buildSliderTile(
            context,
            'Auto-lock timeout (minutes)',
            'Lock app after inactivity',
            (settings['autoLockTimeout'] ?? 5).toDouble(),
            1,
            60,
            (value) {
              context.read<SettingsBloc>().add(
                UpdateSecuritySettingsEvent(
                  requireAuthentication: settings['requireAuthentication'] ?? false,
                  authenticationMethod: settings['authenticationMethod'] ?? 'Biometric',
                  autoLockTimeout: value.round(),
                  hideInRecentApps: settings['hideInRecentApps'] ?? false,
                  blockScreenshots: settings['blockScreenshots'] ?? false,
                ),
              );
            },
          ),
        ],
        
        _buildSwitchTile(
          context,
          'Hide app in recent apps',
          'Hide app content in recent apps screen',
          settings['hideInRecentApps'] ?? false,
          (value) {
            context.read<SettingsBloc>().add(
              UpdateSecuritySettingsEvent(
                requireAuthentication: settings['requireAuthentication'] ?? false,
                authenticationMethod: settings['authenticationMethod'] ?? 'Biometric',
                autoLockTimeout: settings['autoLockTimeout'] ?? 5,
                hideInRecentApps: value,
                blockScreenshots: settings['blockScreenshots'] ?? false,
              ),
            );
          },
        ),
        
        _buildSwitchTile(
          context,
          'Block screenshots',
          'Prevent screenshots and screen recording',
          settings['blockScreenshots'] ?? false,
          (value) {
            context.read<SettingsBloc>().add(
              UpdateSecuritySettingsEvent(
                requireAuthentication: settings['requireAuthentication'] ?? false,
                authenticationMethod: settings['authenticationMethod'] ?? 'Biometric',
                autoLockTimeout: settings['autoLockTimeout'] ?? 5,
                hideInRecentApps: settings['hideInRecentApps'] ?? false,
                blockScreenshots: value,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSystemSection(BuildContext context) {
    return _buildSettingsSection(
      context,
      'System',
      Icons.info,
      [
        _buildListTile(
          context,
          'App information',
          'Version, build info, and more',
          Icons.info_outline,
          () => _showAppInfoDialog(context),
        ),
        
        _buildListTile(
          context,
          'Storage usage',
          'View app storage usage',
          Icons.storage,
          () => _showStorageInfoDialog(context),
        ),
        
        _buildListTile(
          context,
          'System information',
          'Device and system details',
          Icons.phone_android,
          () => _showSystemInfoDialog(context),
        ),
        
        _buildListTile(
          context,
          'Check for updates',
          'Check for app updates',
          Icons.system_update,
          () => _checkForUpdates(context),
        ),
        
        _buildListTile(
          context,
          'Run diagnostics',
          'Check app health and performance',
          Icons.health_and_safety,
          () => _runDiagnostics(context),
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return _buildSettingsSection(
      context,
      'About',
      Icons.help,
      [
        _buildListTile(
          context,
          'Help & Support',
          'Get help and contact support',
          Icons.help_outline,
          () => _showHelpDialog(context),
        ),
        
        _buildListTile(
          context,
          'Send feedback',
          'Share your thoughts and suggestions',
          Icons.feedback,
          () => _showFeedbackDialog(context),
        ),
        
        _buildListTile(
          context,
          'Report a bug',
          'Report issues and bugs',
          Icons.bug_report,
          () => _showBugReportDialog(context),
        ),
        
        _buildListTile(
          context,
          'Privacy policy',
          'Read our privacy policy',
          Icons.policy,
          () => _showPrivacyPolicy(context),
        ),
        
        _buildListTile(
          context,
          'Terms of service',
          'Read our terms of service',
          Icons.description,
          () => _showTermsOfService(context),
        ),
        
        _buildListTile(
          context,
          'Open source licenses',
          'View third-party licenses',
          Icons.code,
          () => _showLicenses(context),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    final theme = Theme.of(context);
    
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildSliderTile(
    BuildContext context,
    String title,
    String subtitle,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return ListTile(
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subtitle),
          const SizedBox(height: 8),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: (max - min).round(),
            label: value.toStringAsFixed(value % 1 == 0 ? 0 : 1),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile(
    BuildContext context,
    String title,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return ListTile(
      title: Text(title),
      trailing: DropdownButton<String>(
        value: value,
        onChanged: onChanged,
        items: options.map((option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildTextFieldTile(
    BuildContext context,
    String title,
    String value,
    String hint,
    ValueChanged<String> onChanged,
  ) {
    final controller = TextEditingController(text: value);
    
    return ListTile(
      title: Text(title),
      subtitle: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        onSubmitted: onChanged,
      ),
    );
  }

  String _getThemeDisplayName(BuildContext context) {
    final themeState = context.read<ThemeBloc>().state;
    if (themeState is ThemeLoaded) {
      switch (themeState.themeMode) {
        case ThemeMode.light:
          return 'Light';
        case ThemeMode.dark:
          return 'Dark';
        case ThemeMode.system:
          return 'System';
      }
    }
    return 'System';
  }

  bool _isDarkMode(BuildContext context) {
    final themeState = context.read<ThemeBloc>().state;
    if (themeState is ThemeLoaded) {
      return themeState.isDarkMode(context);
    }
    return false;
  }

  void _onMenuSelected(String value) {
    switch (value) {
      case 'export':
        context.read<SettingsBloc>().add(const ExportSettingsEvent(exportPath: '/storage/emulated/0/Download/settings_export.json'));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings exported')),
        );
        break;
      case 'import':
        context.read<SettingsBloc>().add(const ImportSettingsEvent(importPath: '/storage/emulated/0/Download/settings_export.json'));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings imported')),
        );
        break;
      case 'reset':
        _showConfirmDialog(
          'Reset Settings',
          'Are you sure you want to reset all settings to default values?',
          () {
            context.read<SettingsBloc>().add(const ResetSettingsEvent(category: 'all'));
          },
        );
        break;
    }
  }

  void _showDownloadLocationDialog(BuildContext context, Map<String, dynamic> settings) {
    // TODO: Show folder picker dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening folder picker')),
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Light'),
              value: ThemeMode.light,
              groupValue: _getCurrentThemeMode(context),
              onChanged: (value) {
                Navigator.pop(context);
                context.read<ThemeBloc>().add(const ChangeThemeEvent(themeMode: ThemeMode.light));
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark'),
              value: ThemeMode.dark,
              groupValue: _getCurrentThemeMode(context),
              onChanged: (value) {
                Navigator.pop(context);
                context.read<ThemeBloc>().add(const ChangeThemeEvent(themeMode: ThemeMode.dark));
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('System'),
              value: ThemeMode.system,
              groupValue: _getCurrentThemeMode(context),
              onChanged: (value) {
                Navigator.pop(context);
                context.read<ThemeBloc>().add(const ChangeThemeEvent(themeMode: ThemeMode.system));
              },
            ),
          ],
        ),
      ),
    );
  }

  ThemeMode _getCurrentThemeMode(BuildContext context) {
    final themeState = context.read<ThemeBloc>().state;
    if (themeState is ThemeLoaded) {
      return themeState.themeMode;
    }
    return ThemeMode.system;
  }

  void _showClearHistoryDialog(BuildContext context, String type) {
    _showConfirmDialog(
      'Clear ${type.capitalize()} History',
      'Are you sure you want to clear all ${type} history? This action cannot be undone.',
      () {
        if (type == 'download') {
          context.read<SettingsBloc>().add(const ClearHistoryEvent());
        } else {
          context.read<SettingsBloc>().add(const ClearHistoryEvent());
        }
      },
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    _showConfirmDialog(
      'Clear Cache',
      'Are you sure you want to clear the app cache? This will free up storage space.',
      () {
        context.read<SettingsBloc>().add(const ClearCacheEvent());
      },
    );
  }

  void _showAppInfoDialog(BuildContext context) {
    context.read<SettingsBloc>().add(const GetAppInfoEvent());
    // TODO: Show app info dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Loading app information')),
    );
  }

  void _showStorageInfoDialog(BuildContext context) {
    context.read<SettingsBloc>().add(const GetStorageInfoEvent());
    // TODO: Show storage info dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Loading storage information')),
    );
  }

  void _showSystemInfoDialog(BuildContext context) {
    context.read<SettingsBloc>().add(const GetSystemInfoEvent());
    // TODO: Show system info dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Loading system information')),
    );
  }

  void _checkForUpdates(BuildContext context) {
    context.read<SettingsBloc>().add(const CheckForUpdatesEvent());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Checking for updates...')),
    );
  }

  void _runDiagnostics(BuildContext context) {
    context.read<SettingsBloc>().add(const RunDiagnosticsEvent());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Running diagnostics...')),
    );
  }

  void _showHelpDialog(BuildContext context) {
    // TODO: Show help dialog or navigate to help screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening help & support')),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _buildFeedbackDialog(),
    );
  }

  Widget _buildFeedbackDialog() {
    final controller = TextEditingController();
    
    return AlertDialog(
      title: const Text('Send Feedback'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('We\'d love to hear your thoughts and suggestions!'),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter your feedback here...',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
            autofocus: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final feedback = controller.text.trim();
            Navigator.pop(context);
            if (feedback.isNotEmpty) {
              context.read<SettingsBloc>().add(
                SendFeedbackEvent(feedback: feedback),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Feedback sent successfully')),
              );
            }
          },
          child: const Text('Send'),
        ),
      ],
    );
  }

  void _showBugReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _buildBugReportDialog(),
    );
  }

  Widget _buildBugReportDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    
    return AlertDialog(
      title: const Text('Report a Bug'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'Bug title',
              hintText: 'Brief description of the issue',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Detailed description of the bug',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final title = titleController.text.trim();
            final description = descriptionController.text.trim();
            Navigator.pop(context);
            if (title.isNotEmpty && description.isNotEmpty) {
              context.read<SettingsBloc>().add(
                ReportBugEvent(
                  title: title,
                  description: description,
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bug report sent successfully')),
              );
            }
          },
          child: const Text('Send Report'),
        ),
      ],
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    // TODO: Show privacy policy
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening privacy policy')),
    );
  }

  void _showTermsOfService(BuildContext context) {
    // TODO: Show terms of service
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening terms of service')),
    );
  }

  void _showLicenses(BuildContext context) {
    showLicensePage(context: context);
  }

  void _showConfirmDialog(String title, String content, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}