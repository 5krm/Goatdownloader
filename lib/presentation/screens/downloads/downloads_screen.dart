import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/download/download_bloc.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/download/download_card.dart';
import '../../../domain/entities/download.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({Key? key}) : super(key: key);

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  
  String _selectedFilter = 'All';
  String _selectedPlatform = 'All';
  String _selectedSort = 'Date Added';
  bool _isGridView = false;

  final List<String> _filterOptions = [
    'All',
    'Downloading',
    'Completed',
    'Paused',
    'Failed',
    'Queued',
  ];

  final List<String> _platformOptions = [
    'All',
    'YouTube',
    'Instagram',
    'TikTok',
    'Twitter',
    'Facebook',
    'Vimeo',
  ];

  final List<String> _sortOptions = [
    'Date Added',
    'Name',
    'Size',
    'Progress',
    'Platform',
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Load downloads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DownloadBloc>().add(const GetAllDownloadsEvent());
      context.read<DownloadBloc>().add(const GetDownloadStatisticsEvent());
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context),
          _buildTabBar(context),
          _buildFiltersBar(context),
          Expanded(child: _buildContent(context)),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Downloads',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                BlocBuilder<DownloadBloc, DownloadState>(
                  builder: (context, state) {
                    if (state is DownloadStatisticsLoaded) {
                      return Text(
                        '${state.statistics.totalDownloads} downloads • '
                        '${state.statistics.activeDownloads} active',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
          
          // View toggle
          IconButton(
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
            icon: Icon(
              _isGridView ? Icons.list : Icons.grid_view,
            ),
            tooltip: _isGridView ? 'List view' : 'Grid view',
          ),
          
          // More options
          PopupMenuButton<String>(
            onSelected: _onMenuSelected,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'pause_all',
                child: ListTile(
                  leading: Icon(Icons.pause),
                  title: Text('Pause All'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'resume_all',
                child: ListTile(
                  leading: Icon(Icons.play_arrow),
                  title: Text('Resume All'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'clear_completed',
                child: ListTile(
                  leading: Icon(Icons.clear_all),
                  title: Text('Clear Completed'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Download Settings'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: Colors.white,
        unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.7),
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Active'),
          Tab(text: 'Completed'),
          Tab(text: 'Failed'),
        ],
      ),
    );
  }

  Widget _buildFiltersBar(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: 60,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Platform filter
          Expanded(
            child: _buildFilterDropdown(
              context,
              'Platform',
              _selectedPlatform,
              _platformOptions,
              (value) {
                setState(() {
                  _selectedPlatform = value!;
                });
                _applyFilters();
              },
            ),
          ),
          const SizedBox(width: 8),
          
          // Sort filter
          Expanded(
            child: _buildFilterDropdown(
              context,
              'Sort by',
              _selectedSort,
              _sortOptions,
              (value) {
                setState(() {
                  _selectedSort = value!;
                });
                _applyFilters();
              },
            ),
          ),
          const SizedBox(width: 8),
          
          // Search button
          IconButton(
            onPressed: _showSearchDialog,
            icon: const Icon(Icons.search),
            tooltip: 'Search downloads',
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              foregroundColor: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(
    BuildContext context,
    String label,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          onChanged: onChanged,
          isExpanded: true,
          isDense: true,
          hint: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          style: theme.textTheme.bodyMedium,
          items: options.map((option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(
                option,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildDownloadsList(context, null),
        _buildDownloadsList(context, DownloadStatus.downloading),
        _buildDownloadsList(context, DownloadStatus.completed),
        _buildDownloadsList(context, DownloadStatus.failed),
      ],
    );
  }

  Widget _buildDownloadsList(BuildContext context, DownloadStatus? status) {
    return BlocBuilder<DownloadBloc, DownloadState>(
      builder: (context, state) {
        if (state is DownloadLoading) {
          return const Center(
            child: LoadingWidget(
              message: 'Loading downloads...',
            ),
          );
        }
        
        if (state is DownloadError) {
          return Center(
            child: CustomErrorWidget(
              message: state.message,
              type: ErrorType.generic,
              onRetry: () {
                if (status != null) {
                  context.read<DownloadBloc>().add(
                    GetDownloadsByStatusEvent(status: status),
                  );
                } else {
                  context.read<DownloadBloc>().add(const GetAllDownloadsEvent());
                }
              },
            ),
          );
        }
        
        if (state is DownloadsLoaded) {
          final downloads = _filterDownloads(state.downloads, status);
          
          if (downloads.isEmpty) {
            return _buildEmptyState(context, status);
          }
          
          return RefreshIndicator(
            onRefresh: () async {
              context.read<DownloadBloc>().add(const RefreshDownloadsEvent());
            },
            child: _isGridView 
                ? _buildGridView(context, downloads)
                : _buildListView(context, downloads),
          );
        }
        
        return _buildEmptyState(context, status);
      },
    );
  }

  Widget _buildListView(BuildContext context, List<Download> downloads) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: downloads.length,
      itemBuilder: (context, index) {
        final download = downloads[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DownloadCard(
            download: download,
            type: DownloadCardType.list,
            onTap: () => _onDownloadTap(download),
            onPause: () => _onDownloadPause(download),
            onResume: () => _onDownloadResume(download),
            onCancel: () => _onDownloadCancel(download),
            onRetry: () => _onDownloadRetry(download),
            onDelete: () => _onDownloadDelete(download),
            onOpenFile: () => _onDownloadOpenFile(download),
            onOpenFolder: () => _onDownloadOpenFolder(download),
            onShare: () => _onDownloadShare(download),
          ),
        );
      },
    );
  }

  Widget _buildGridView(BuildContext context, List<Download> downloads) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: downloads.length,
      itemBuilder: (context, index) {
        final download = downloads[index];
        return DownloadCard(
          download: download,
          type: DownloadCardType.compact,
          onTap: () => _onDownloadTap(download),
          onPause: () => _onDownloadPause(download),
          onResume: () => _onDownloadResume(download),
          onCancel: () => _onDownloadCancel(download),
          onRetry: () => _onDownloadRetry(download),
          onDelete: () => _onDownloadDelete(download),
          onOpenFile: () => _onDownloadOpenFile(download),
          onOpenFolder: () => _onDownloadOpenFolder(download),
          onShare: () => _onDownloadShare(download),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, DownloadStatus? status) {
    final theme = Theme.of(context);
    
    String title;
    String subtitle;
    IconData icon;
    
    switch (status) {
      case DownloadStatus.downloading:
        title = 'No Active Downloads';
        subtitle = 'Downloads will appear here when they start.';
        icon = Icons.download;
        break;
      case DownloadStatus.completed:
        title = 'No Completed Downloads';
        subtitle = 'Completed downloads will appear here.';
        icon = Icons.check_circle;
        break;
      case DownloadStatus.failed:
        title = 'No Failed Downloads';
        subtitle = 'Failed downloads will appear here.';
        icon = Icons.error;
        break;
      default:
        title = 'No Downloads Yet';
        subtitle = 'Start downloading videos to see them here.';
        icon = Icons.download;
        break;
    }
    
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
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: _showAddDownloadDialog,
      icon: const Icon(Icons.add),
      label: const Text('Add Download'),
    );
  }

  List<Download> _filterDownloads(List<Download> downloads, DownloadStatus? status) {
    var filtered = downloads;
    
    // Filter by status
    if (status != null) {
      filtered = filtered.where((d) => d.status == status).toList();
    }
    
    // Filter by platform
    if (_selectedPlatform != 'All') {
      filtered = filtered.where((d) => d.platform == _selectedPlatform).toList();
    }
    
    // Sort downloads
    switch (_selectedSort) {
      case 'Name':
        filtered.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'Size':
        filtered.sort((a, b) => b.totalSize.compareTo(a.totalSize));
        break;
      case 'Progress':
        filtered.sort((a, b) {
          final progressA = a.totalSize > 0 ? a.downloadedSize / a.totalSize : 0;
          final progressB = b.totalSize > 0 ? b.downloadedSize / b.totalSize : 0;
          return progressB.compareTo(progressA);
        });
        break;
      case 'Platform':
        filtered.sort((a, b) => a.platform.compareTo(b.platform));
        break;
      case 'Date Added':
      default:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }
    
    return filtered;
  }

  void _applyFilters() {
    // Trigger rebuild with new filters
    setState(() {});
  }

  void _onMenuSelected(String value) {
    switch (value) {
      case 'pause_all':
        _showConfirmDialog(
          'Pause All Downloads',
          'Are you sure you want to pause all active downloads?',
          () {
            // TODO: Implement pause all
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('All downloads paused')),
            );
          },
        );
        break;
      case 'resume_all':
        // TODO: Implement resume all
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All downloads resumed')),
        );
        break;
      case 'clear_completed':
        _showConfirmDialog(
          'Clear Completed Downloads',
          'Are you sure you want to remove all completed downloads from the list?',
          () {
            context.read<DownloadBloc>().add(const ClearDownloadsEvent());
          },
        );
        break;
      case 'settings':
        // TODO: Navigate to download settings
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Opening download settings')),
        );
        break;
    }
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => _buildSearchDialog(),
    );
  }

  Widget _buildSearchDialog() {
    final theme = Theme.of(context);
    final controller = TextEditingController();
    
    return AlertDialog(
      title: const Text('Search Downloads'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          hintText: 'Enter search term...',
          prefixIcon: Icon(Icons.search),
        ),
        autofocus: true,
        onSubmitted: (query) {
          Navigator.pop(context);
          if (query.trim().isNotEmpty) {
            context.read<DownloadBloc>().add(
              SearchDownloadsEvent(query: query.trim()),
            );
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final query = controller.text.trim();
            Navigator.pop(context);
            if (query.isNotEmpty) {
              context.read<DownloadBloc>().add(
                SearchDownloadsEvent(query: query),
              );
            }
          },
          child: const Text('Search'),
        ),
      ],
    );
  }

  void _showAddDownloadDialog() {
    showDialog(
      context: context,
      builder: (context) => _buildAddDownloadDialog(),
    );
  }

  Widget _buildAddDownloadDialog() {
    final controller = TextEditingController();
    
    return AlertDialog(
      title: const Text('Add Download'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Paste video URL here...',
              prefixIcon: Icon(Icons.link),
            ),
            autofocus: true,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          const Text(
            'Supported platforms: YouTube, Instagram, TikTok, Twitter, Facebook, Vimeo',
            style: TextStyle(fontSize: 12),
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
            final url = controller.text.trim();
            Navigator.pop(context);
            if (url.isNotEmpty) {
              context.read<DownloadBloc>().add(
                StartDownloadEvent(url: url),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Download started')),
              );
            }
          },
          child: const Text('Download'),
        ),
      ],
    );
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

  // Download action handlers
  void _onDownloadTap(Download download) {
    // TODO: Show download details
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing ${download.title}')),
    );
  }

  void _onDownloadPause(Download download) {
    context.read<DownloadBloc>().add(PauseDownloadEvent(id: download.id));
  }

  void _onDownloadResume(Download download) {
    context.read<DownloadBloc>().add(ResumeDownloadEvent(id: download.id));
  }

  void _onDownloadCancel(Download download) {
    _showConfirmDialog(
      'Cancel Download',
      'Are you sure you want to cancel this download?',
      () {
        context.read<DownloadBloc>().add(CancelDownloadEvent(id: download.id));
      },
    );
  }

  void _onDownloadRetry(Download download) {
    context.read<DownloadBloc>().add(RetryDownloadEvent(id: download.id));
  }

  void _onDownloadDelete(Download download) {
    _showConfirmDialog(
      'Delete Download',
      'Are you sure you want to delete this download? This will also delete the downloaded file.',
      () {
        context.read<DownloadBloc>().add(DeleteDownloadEvent(id: download.id));
      },
    );
  }

  void _onDownloadOpenFile(Download download) {
    // TODO: Open file with system default app
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening ${download.fileName}')),
    );
  }

  void _onDownloadOpenFolder(Download download) {
    // TODO: Open file location in file manager
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening folder: ${download.filePath}')),
    );
  }

  void _onDownloadShare(Download download) {
    // TODO: Share file
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sharing ${download.fileName}')),
    );
  }
}