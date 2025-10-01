import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/search/search_bloc.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/video/video_card.dart';
import '../../widgets/search/search_bar_widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  String _currentQuery = '';
  String _selectedPlatform = 'All';
  String _selectedSortBy = 'Relevance';
  String _selectedDuration = 'Any';
  String _selectedUploadDate = 'Any';

  final List<String> _platforms = [
    'All',
    'YouTube',
    'Instagram',
    'TikTok',
    'Twitter',
    'Facebook',
    'Vimeo',
  ];

  final List<String> _sortOptions = [
    'Relevance',
    'Upload Date',
    'View Count',
    'Duration',
    'Rating',
  ];

  final List<String> _durationOptions = [
    'Any',
    'Under 4 minutes',
    '4-20 minutes',
    'Over 20 minutes',
  ];

  final List<String> _uploadDateOptions = [
    'Any',
    'Last hour',
    'Today',
    'This week',
    'This month',
    'This year',
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Load search history
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SearchBloc>().add(const GetSearchHistoryEvent());
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom && _currentQuery.isNotEmpty) {
      context.read<SearchBloc>().add(const LoadMoreSearchResultsEvent());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onSearch(String query) {
    if (query.trim().isEmpty) return;
    
    setState(() {
      _currentQuery = query.trim();
    });
    
    context.read<SearchBloc>().add(
      SearchVideosEvent(
        query: query.trim(),
        platform: _selectedPlatform == 'All' ? null : _selectedPlatform,
        sortBy: _selectedSortBy,
        duration: _selectedDuration == 'Any' ? null : _selectedDuration,
        uploadDate: _selectedUploadDate == 'Any' ? null : _selectedUploadDate,
      ),
    );
    
    // Add to search history
    context.read<SearchBloc>().add(
      AddSearchToHistoryEvent(query: query.trim()),
    );
  }

  void _onFilterChanged() {
    if (_currentQuery.isNotEmpty) {
      context.read<SearchBloc>().add(
        SearchVideosEvent(
          query: _currentQuery,
          platform: _selectedPlatform == 'All' ? null : _selectedPlatform,
          sortBy: _selectedSortBy,
          duration: _selectedDuration == 'Any' ? null : _selectedDuration,
          uploadDate: _selectedUploadDate == 'Any' ? null : _selectedUploadDate,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      body: Column(
        children: [
          _buildSearchSection(context),
          _buildFiltersSection(context),
          Expanded(child: _buildResultsSection(context)),
        ],
      ),
    );
  }

  Widget _buildSearchSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
            initialQuery: _currentQuery,
            hintText: 'Search videos across platforms...',
            suggestions: suggestions,
            searchHistory: history,
            onSearch: _onSearch,
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
            autofocus: false,
          );
        },
      ),
    );
  }

  Widget _buildFiltersSection(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Platform filter
          Expanded(
            child: _buildFilterDropdown(
              context,
              'Platform',
              _selectedPlatform,
              _platforms,
              (value) {
                setState(() {
                  _selectedPlatform = value!;
                });
                _onFilterChanged();
              },
            ),
          ),
          const SizedBox(width: 8),
          
          // Sort filter
          Expanded(
            child: _buildFilterDropdown(
              context,
              'Sort by',
              _selectedSortBy,
              _sortOptions,
              (value) {
                setState(() {
                  _selectedSortBy = value!;
                });
                _onFilterChanged();
              },
            ),
          ),
          const SizedBox(width: 8),
          
          // More filters button
          IconButton(
            onPressed: _showMoreFilters,
            icon: const Icon(Icons.tune),
            tooltip: 'More filters',
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

  Widget _buildResultsSection(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        if (state is SearchLoading && _currentQuery.isEmpty) {
          return _buildEmptyState(
            context,
            'Start Searching',
            'Enter a search term to find videos from multiple platforms.',
            Icons.search,
          );
        }
        
        if (state is SearchLoading) {
          return const Center(
            child: LoadingWidget(
              message: 'Searching videos...',
            ),
          );
        }
        
        if (state is SearchError) {
          return Center(
            child: CustomErrorWidget(
              message: state.message,
              type: ErrorType.network,
              onRetry: () {
                if (_currentQuery.isNotEmpty) {
                  _onSearch(_currentQuery);
                }
              },
            ),
          );
        }
        
        if (state is SearchResultsLoaded) {
          if (state.videos.isEmpty) {
            return _buildEmptyState(
              context,
              'No Results Found',
              'Try adjusting your search terms or filters.',
              Icons.search_off,
            );
          }
          
          return RefreshIndicator(
            onRefresh: () async {
              if (_currentQuery.isNotEmpty) {
                context.read<SearchBloc>().add(
                  RefreshSearchResultsEvent(query: _currentQuery),
                );
              }
            },
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: state.hasReachedMax 
                  ? state.videos.length 
                  : state.videos.length + 1,
              itemBuilder: (context, index) {
                if (index >= state.videos.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: LoadingWidget(
                        type: LoadingType.circular,
                        showMessage: false,
                      ),
                    ),
                  );
                }
                
                final video = state.videos[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: VideoCard(
                    video: video,
                    type: VideoCardType.list,
                    onTap: () => _onVideoTap(video),
                    onDownload: () => _onVideoDownload(video),
                    onShare: () => _onVideoShare(video),
                    onFavorite: () => _onVideoFavorite(video),
                  ),
                );
              },
            ),
          );
        }
        
        // Show search history when no search is active
        return BlocBuilder<SearchBloc, SearchState>(
          builder: (context, historyState) {
            if (historyState is SearchHistoryLoaded && 
                historyState.history.isNotEmpty) {
              return _buildSearchHistory(context, historyState.history);
            }
            
            return _buildEmptyState(
              context,
              'Start Searching',
              'Enter a search term to find videos from multiple platforms.',
              Icons.search,
            );
          },
        );
      },
    );
  }

  Widget _buildSearchHistory(BuildContext context, List<String> history) {
    final theme = Theme.of(context);
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Searches',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {
                context.read<SearchBloc>().add(const ClearSearchHistoryEvent());
              },
              child: const Text('Clear All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        ...history.map((query) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.history),
            title: Text(query),
            trailing: IconButton(
              onPressed: () {
                context.read<SearchBloc>().add(
                  RemoveSearchFromHistoryEvent(query: query),
                );
              },
              icon: const Icon(Icons.close),
            ),
            onTap: () => _onSearch(query),
          ),
        )),
      ],
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
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
          ],
        ),
      ),
    );
  }

  void _showMoreFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildMoreFiltersSheet(),
    );
  }

  Widget _buildMoreFiltersSheet() {
    final theme = Theme.of(context);
    
    return StatefulBuilder(
      builder: (context, setSheetState) {
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
                'Search Filters',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              
              // Duration filter
              Text(
                'Duration',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _durationOptions.map((duration) {
                  final isSelected = _selectedDuration == duration;
                  return FilterChip(
                    label: Text(duration),
                    selected: isSelected,
                    onSelected: (selected) {
                      setSheetState(() {
                        _selectedDuration = duration;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              
              // Upload date filter
              Text(
                'Upload Date',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _uploadDateOptions.map((date) {
                  final isSelected = _selectedUploadDate == date;
                  return FilterChip(
                    label: Text(date),
                    selected: isSelected,
                    onSelected: (selected) {
                      setSheetState(() {
                        _selectedUploadDate = date;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setSheetState(() {
                          _selectedDuration = 'Any';
                          _selectedUploadDate = 'Any';
                        });
                      },
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          // Update main state
                        });
                        Navigator.pop(context);
                        _onFilterChanged();
                      },
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Download ${video.title}'),
        duration: const Duration(seconds: 2),
      ),
    );
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
}