import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/search/search_bloc.dart';
import '../../blocs/download/download_bloc.dart';
import '../../blocs/theme/theme_bloc.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/video/video_card.dart';
import '../../widgets/search/search_bar_widget.dart';
import '../search/search_screen.dart';
import '../downloads/downloads_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;
  
  final List<String> _tabTitles = [
    'Trending',
    'Search',
    'Downloads',
    'Settings',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabTitles.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SearchBloc>().add(const GetTrendingVideosEvent());
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _currentIndex = _tabController.index;
      });
    }
  }

  void _onBottomNavTap(int index) {
    _tabController.animateTo(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTrendingTab(),
          const SearchScreen(),
          const DownloadsScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppBar(
      title: Text(
        'GoatDownloader',
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
      centerTitle: false,
      elevation: 0,
      backgroundColor: theme.colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      actions: [
        // Theme toggle
        BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, state) {
            final isDark = state is ThemeLoaded && state.isDarkMode();
            return IconButton(
              onPressed: () {
                context.read<ThemeBloc>().add(const ToggleThemeEvent());
              },
              icon: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                color: theme.colorScheme.onSurface,
              ),
              tooltip: isDark ? 'Light mode' : 'Dark mode',
            );
          },
        ),
        
        // More options
        PopupMenuButton<String>(
          onSelected: _onMenuSelected,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'refresh',
              child: ListTile(
                leading: Icon(Icons.refresh),
                title: Text('Refresh'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'about',
              child: ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('About'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
          icon: Icon(
            Icons.more_vert,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
      bottom: _currentIndex == 0 ? _buildSearchBar(context) : null,
    );
  }

  PreferredSizeWidget? _buildSearchBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: BlocBuilder<SearchBloc, SearchState>(
          builder: (context, state) {
            List<String> suggestions = [];
            List<String> history = [];
            
            if (state is SearchSuggestionsLoaded) {
              suggestions = state.suggestions;
            }
            if (state is SearchHistoryLoaded) {
              history = state.history;
            }
            
            return SearchBarWidget(
              hintText: 'Search for videos...',
              suggestions: suggestions,
              searchHistory: history,
              onSearch: (query) {
                context.read<SearchBloc>().add(SearchVideosEvent(query: query));
                _tabController.animateTo(1); // Switch to search tab
              },
              onQueryChanged: (query) {
                if (query.isNotEmpty) {
                  context.read<SearchBloc>().add(
                    GetSearchSuggestionsEvent(query: query),
                  );
                }
              },
              onHistoryDelete: (item) {
                context.read<SearchBloc>().add(
                  RemoveSearchFromHistoryEvent(query: item),
                );
              },
              onClearHistory: () {
                context.read<SearchBloc>().add(const ClearSearchHistoryEvent());
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildTrendingTab() {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        if (state is SearchLoading) {
          return const Center(
            child: LoadingWidget(
              message: 'Loading trending videos...',
            ),
          );
        }
        
        if (state is SearchError) {
          return Center(
            child: CustomErrorWidget(
              message: state.message,
              type: ErrorType.network,
              onRetry: () {
                context.read<SearchBloc>().add(const GetTrendingVideosEvent());
              },
            ),
          );
        }
        
        if (state is TrendingVideosLoaded) {
          if (state.videos.isEmpty) {
            return _buildEmptyState(
              context,
              'No trending videos',
              'Check your internet connection and try again.',
              Icons.trending_up,
              () {
                context.read<SearchBloc>().add(const GetTrendingVideosEvent());
              },
            );
          }
          
          return RefreshIndicator(
            onRefresh: () async {
              context.read<SearchBloc>().add(const RefreshTrendingVideosEvent());
            },
            child: CustomScrollView(
              slivers: [
                // Category selector
                SliverToBoxAdapter(
                  child: _buildCategorySelector(context),
                ),
                
                // Videos grid
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= state.videos.length) {
                          // Load more indicator
                          return const Center(
                            child: LoadingWidget(
                              type: LoadingType.circular,
                              showMessage: false,
                            ),
                          );
                        }
                        
                        final video = state.videos[index];
                        return VideoCard(
                          video: video,
                          type: VideoCardType.grid,
                          onTap: () => _onVideoTap(video),
                          onDownload: () => _onVideoDownload(video),
                          onShare: () => _onVideoShare(video),
                          onFavorite: () => _onVideoFavorite(video),
                        );
                      },
                      childCount: state.hasReachedMax 
                          ? state.videos.length 
                          : state.videos.length + 1,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        
        return _buildEmptyState(
          context,
          'Welcome to GoatDownloader',
          'Discover trending videos from various platforms.',
          Icons.video_library,
          () {
            context.read<SearchBloc>().add(const GetTrendingVideosEvent());
          },
        );
      },
    );
  }

  Widget _buildCategorySelector(BuildContext context) {
    final theme = Theme.of(context);
    final categories = [
      'All',
      'Music',
      'Gaming',
      'Sports',
      'News',
      'Entertainment',
      'Education',
      'Technology',
    ];
    
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = index == 0; // TODO: Get from state
          
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  context.read<SearchBloc>().add(
                    UpdateTrendingCategoryEvent(category: category),
                  );
                }
              },
              backgroundColor: theme.colorScheme.surface,
              selectedColor: theme.colorScheme.primary.withOpacity(0.2),
              checkmarkColor: theme.colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected 
                    ? theme.colorScheme.primary 
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onRetry,
  ) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    final theme = Theme.of(context);
    
    return NavigationBar(
      selectedIndex: _currentIndex,
      onDestinationSelected: _onBottomNavTap,
      backgroundColor: theme.colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: theme.colorScheme.primary.withOpacity(0.2),
      destinations: [
        NavigationDestination(
          icon: Icon(
            _currentIndex == 0 ? Icons.trending_up : Icons.trending_up_outlined,
          ),
          label: 'Trending',
        ),
        NavigationDestination(
          icon: Icon(
            _currentIndex == 1 ? Icons.search : Icons.search_outlined,
          ),
          label: 'Search',
        ),
        NavigationDestination(
          icon: Icon(
            _currentIndex == 2 ? Icons.download : Icons.download_outlined,
          ),
          label: 'Downloads',
        ),
        NavigationDestination(
          icon: Icon(
            _currentIndex == 3 ? Icons.settings : Icons.settings_outlined,
          ),
          label: 'Settings',
        ),
      ],
    );
  }

  void _onMenuSelected(String value) {
    switch (value) {
      case 'refresh':
        switch (_currentIndex) {
          case 0:
            context.read<SearchBloc>().add(const RefreshTrendingVideosEvent());
            break;
          case 2:
            context.read<DownloadBloc>().add(const RefreshDownloadsEvent());
            break;
        }
        break;
      case 'about':
        _showAboutDialog();
        break;
    }
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'GoatDownloader',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        Icons.video_library,
        size: 48,
      ),
      children: [
        const Text(
          'A powerful video downloader app that supports multiple platforms including YouTube, Instagram, TikTok, and more.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Features:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const Text('• Download videos from multiple platforms'),
        const Text('• Multiple quality options'),
        const Text('• Background downloads'),
        const Text('• Download history and management'),
        const Text('• Dark/Light theme support'),
      ],
    );
  }

  void _onVideoTap(dynamic video) {
    // TODO: Navigate to video details or play video
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening ${video.title}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onVideoDownload(dynamic video) {
    // TODO: Show download options dialog
    _showDownloadOptionsDialog(video);
  }

  void _onVideoShare(dynamic video) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing ${video.title}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onVideoFavorite(dynamic video) {
    // TODO: Implement favorite functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${video.title} to favorites'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showDownloadOptionsDialog(dynamic video) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildDownloadOptionsSheet(video),
    );
  }

  Widget _buildDownloadOptionsSheet(dynamic video) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Title
          Text(
            'Download Options',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Video info
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 80,
                  height: 60,
                  color: Colors.grey[300],
                  child: const Icon(Icons.video_library),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      video.channelName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Quality options
          Text(
            'Quality',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          ...['1080p', '720p', '480p', '360p'].map(
            (quality) => ListTile(
              leading: const Icon(Icons.video_file),
              title: Text(quality),
              subtitle: Text('MP4 • ~${_getEstimatedSize(quality)}'),
              trailing: const Icon(Icons.download),
              onTap: () {
                Navigator.pop(context);
                _startDownload(video, quality);
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Audio only option
          ListTile(
            leading: const Icon(Icons.audio_file),
            title: const Text('Audio Only'),
            subtitle: const Text('MP3 • ~5 MB'),
            trailing: const Icon(Icons.download),
            onTap: () {
              Navigator.pop(context);
              _startDownload(video, 'audio');
            },
          ),
          
          const SizedBox(height: 24),
          
          // Cancel button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ),
        ],
      ),
    );
  }

  String _getEstimatedSize(String quality) {
    switch (quality) {
      case '1080p':
        return '50 MB';
      case '720p':
        return '30 MB';
      case '480p':
        return '20 MB';
      case '360p':
        return '15 MB';
      default:
        return '25 MB';
    }
  }

  void _startDownload(dynamic video, String quality) {
    // TODO: Start actual download
    context.read<DownloadBloc>().add(
      StartDownloadEvent(
        url: video.url,
        quality: quality,
        format: quality == 'audio' ? 'mp3' : 'mp4',
      ),
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Download started: ${video.title} ($quality)'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            _tabController.animateTo(2); // Switch to downloads tab
          },
        ),
      ),
    );
  }
}