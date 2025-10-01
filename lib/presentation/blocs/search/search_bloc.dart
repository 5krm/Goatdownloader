import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/search_videos.dart';
import '../../../core/error/failures.dart';
import '../../../core/storage/hive_helper.dart';
import 'search_event.dart';
import 'search_state.dart';

/// BLoC for managing search-related operations
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchVideos _searchVideos;
  final GetTrendingVideos _getTrendingVideos;
  final HiveHelper _hiveHelper;

  // Current search parameters
  String? _currentQuery;
  String? _currentPlatform;
  String? _currentCategory;
  int _searchCurrentPage = 1;
  int _trendingCurrentPage = 1;

  SearchBloc({
    required SearchVideos searchVideos,
    required GetTrendingVideos getTrendingVideos,
    required HiveHelper hiveHelper,
  })  : _searchVideos = searchVideos,
        _getTrendingVideos = getTrendingVideos,
        _hiveHelper = hiveHelper,
        super(const SearchInitial()) {
    on<SearchVideosEvent>(_onSearchVideos);
    on<GetTrendingVideosEvent>(_onGetTrendingVideos);
    on<LoadMoreSearchResultsEvent>(_onLoadMoreSearchResults);
    on<LoadMoreTrendingVideosEvent>(_onLoadMoreTrendingVideos);
    on<ClearSearchResultsEvent>(_onClearSearchResults);
    on<ClearTrendingVideosEvent>(_onClearTrendingVideos);
    on<UpdateSearchQueryEvent>(_onUpdateSearchQuery);
    on<UpdateSearchPlatformEvent>(_onUpdateSearchPlatform);
    on<UpdateTrendingCategoryEvent>(_onUpdateTrendingCategory);
    on<RefreshSearchResultsEvent>(_onRefreshSearchResults);
    on<RefreshTrendingVideosEvent>(_onRefreshTrendingVideos);
    on<AddSearchToHistoryEvent>(_onAddSearchToHistory);
    on<GetSearchHistoryEvent>(_onGetSearchHistory);
    on<ClearSearchHistoryEvent>(_onClearSearchHistory);
    on<RemoveSearchFromHistoryEvent>(_onRemoveSearchFromHistory);
    on<GetSearchSuggestionsEvent>(_onGetSearchSuggestions);
    on<ResetSearchStateEvent>(_onResetSearchState);
  }

  /// Handles searching for videos
  Future<void> _onSearchVideos(
    SearchVideosEvent event,
    Emitter<SearchState> emit,
  ) async {
    emit(const SearchLoading());

    // Update current search parameters
    _currentQuery = event.query;
    _currentPlatform = event.platform;
    _searchCurrentPage = event.page;

    final result = await _searchVideos(SearchVideosParams(
      query: event.query,
      platforms: event.platform != null ? [event.platform!] : [],
      page: event.page,
      limit: event.limit,
    ));

    result.fold(
      (failure) => emit(SearchError(
        failure: failure,
        message: _mapFailureToMessage(failure),
      )),
      (videos) {
        // Add search to history
        add(AddSearchToHistoryEvent(query: event.query));

        emit(SearchResultsLoaded(
          videos: videos,
          query: event.query,
          platform: event.platform,
          currentPage: event.page,
          hasMoreResults: videos.length >= event.limit,
          totalResults: videos.length,
        ));
      },
    );
  }

  /// Handles getting trending videos
  Future<void> _onGetTrendingVideos(
    GetTrendingVideosEvent event,
    Emitter<SearchState> emit,
  ) async {
    emit(const SearchLoading());

    // Update current trending parameters
    _currentPlatform = event.platform;
    _currentCategory = event.category;
    _trendingCurrentPage = event.page;

    final result = await _getTrendingVideos(GetTrendingParams(
      platforms: event.platform != null ? [event.platform!] : [],
      category: event.category,
      page: event.page,
      limit: event.limit,
    ));

    result.fold(
      (failure) => emit(SearchError(
        failure: failure,
        message: _mapFailureToMessage(failure),
      )),
      (videos) => emit(TrendingVideosLoaded(
        videos: videos,
        platform: event.platform,
        category: event.category,
        currentPage: event.page,
        hasMoreResults: videos.length >= event.limit,
      )),
    );
  }

  /// Handles loading more search results
  Future<void> _onLoadMoreSearchResults(
    LoadMoreSearchResultsEvent event,
    Emitter<SearchState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SearchResultsLoaded || !currentState.hasMoreResults) {
      return;
    }

    emit(SearchLoadingMore(currentResults: currentState.videos));

    final nextPage = currentState.currentPage + 1;
    final result = await _searchVideos(SearchVideosParams(
      query: currentState.query,
      platforms: currentState.platform != null ? [currentState.platform!] : [],
      page: nextPage,
      limit: 20,
    ));

    result.fold(
      (failure) => emit(SearchError(
        failure: failure,
        message: _mapFailureToMessage(failure),
      )),
      (newVideos) {
        final allVideos = [...currentState.videos, ...newVideos];
        emit(currentState.copyWith(
          videos: allVideos,
          currentPage: nextPage,
          hasMoreResults: newVideos.length >= 20,
          totalResults: allVideos.length,
        ));
      },
    );
  }

  /// Handles loading more trending videos
  Future<void> _onLoadMoreTrendingVideos(
    LoadMoreTrendingVideosEvent event,
    Emitter<SearchState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TrendingVideosLoaded || !currentState.hasMoreResults) {
      return;
    }

    emit(SearchLoadingMore(currentResults: currentState.videos));

    final nextPage = currentState.currentPage + 1;
    final result = await _getTrendingVideos(GetTrendingParams(
      platforms: currentState.platform != null ? [currentState.platform!] : [],
      category: currentState.category,
      page: nextPage,
      limit: 20,
    ));

    result.fold(
      (failure) => emit(SearchError(
        failure: failure,
        message: _mapFailureToMessage(failure),
      )),
      (newVideos) {
        final allVideos = [...currentState.videos, ...newVideos];
        emit(currentState.copyWith(
          videos: allVideos,
          currentPage: nextPage,
          hasMoreResults: newVideos.length >= 20,
        ));
      },
    );
  }

  /// Handles clearing search results
  Future<void> _onClearSearchResults(
    ClearSearchResultsEvent event,
    Emitter<SearchState> emit,
  ) async {
    _currentQuery = null;
    _searchCurrentPage = 1;
    emit(const SearchResultsCleared());
  }

  /// Handles clearing trending videos
  Future<void> _onClearTrendingVideos(
    ClearTrendingVideosEvent event,
    Emitter<SearchState> emit,
  ) async {
    _currentCategory = null;
    _trendingCurrentPage = 1;
    emit(const TrendingVideosCleared());
  }

  /// Handles updating search query
  Future<void> _onUpdateSearchQuery(
    UpdateSearchQueryEvent event,
    Emitter<SearchState> emit,
  ) async {
    _currentQuery = event.query;
    emit(SearchQueryUpdated(query: event.query));
  }

  /// Handles updating search platform
  Future<void> _onUpdateSearchPlatform(
    UpdateSearchPlatformEvent event,
    Emitter<SearchState> emit,
  ) async {
    _currentPlatform = event.platform;
    emit(SearchPlatformUpdated(platform: event.platform));
  }

  /// Handles updating trending category
  Future<void> _onUpdateTrendingCategory(
    UpdateTrendingCategoryEvent event,
    Emitter<SearchState> emit,
  ) async {
    _currentCategory = event.category;
    emit(TrendingCategoryUpdated(category: event.category));
  }

  /// Handles refreshing search results
  Future<void> _onRefreshSearchResults(
    RefreshSearchResultsEvent event,
    Emitter<SearchState> emit,
  ) async {
    if (_currentQuery != null) {
      add(SearchVideosEvent(
        query: _currentQuery!,
        platform: _currentPlatform,
        page: 1,
      ));
    }
  }

  /// Handles refreshing trending videos
  Future<void> _onRefreshTrendingVideos(
    RefreshTrendingVideosEvent event,
    Emitter<SearchState> emit,
  ) async {
    add(GetTrendingVideosEvent(
      platform: _currentPlatform,
      category: _currentCategory,
      page: 1,
    ));
  }

  /// Handles adding search to history
  Future<void> _onAddSearchToHistory(
    AddSearchToHistoryEvent event,
    Emitter<SearchState> emit,
  ) async {
    try {
      await _hiveHelper.addSearchHistory(event.query);
      emit(SearchAddedToHistory(query: event.query));
    } catch (e) {
      // Silently fail for history operations
    }
  }

  /// Handles getting search history
  Future<void> _onGetSearchHistory(
    GetSearchHistoryEvent event,
    Emitter<SearchState> emit,
  ) async {
    try {
      final history = _hiveHelper.getSearchHistory();
      emit(SearchHistoryLoaded(searchHistory: history));
    } catch (e) {
      emit(const SearchHistoryLoaded(searchHistory: []));
    }
  }

  /// Handles clearing search history
  Future<void> _onClearSearchHistory(
    ClearSearchHistoryEvent event,
    Emitter<SearchState> emit,
  ) async {
    try {
      await _hiveHelper.clearSearchHistory();
      emit(const SearchHistoryCleared());
    } catch (e) {
      emit(SearchError(
        failure: StorageFailure(),
        message: 'Failed to clear search history',
      ));
    }
  }

  /// Handles removing search from history
  Future<void> _onRemoveSearchFromHistory(
    RemoveSearchFromHistoryEvent event,
    Emitter<SearchState> emit,
  ) async {
    try {
      // Get current history
      final history = _hiveHelper.getSearchHistory();
      history.remove(event.query);
      
      // Clear and re-add
      await _hiveHelper.clearSearchHistory();
      for (final query in history) {
        await _hiveHelper.addSearchHistory(query);
      }
      
      emit(SearchRemovedFromHistory(query: event.query));
    } catch (e) {
      emit(SearchError(
        failure: StorageFailure(),
        message: 'Failed to remove search from history',
      ));
    }
  }

  /// Handles getting search suggestions
  Future<void> _onGetSearchSuggestions(
    GetSearchSuggestionsEvent event,
    Emitter<SearchState> emit,
  ) async {
    try {
      // Get suggestions from search history
      final history = _hiveHelper.getSearchHistory();
      final suggestions = history
          .where((query) => query.toLowerCase().contains(event.query.toLowerCase()))
          .take(5)
          .toList();

      emit(SearchSuggestionsLoaded(
        suggestions: suggestions,
        query: event.query,
      ));
    } catch (e) {
      emit(const SearchSuggestionsLoaded(
        suggestions: [],
        query: '',
      ));
    }
  }

  /// Handles resetting search state
  Future<void> _onResetSearchState(
    ResetSearchStateEvent event,
    Emitter<SearchState> emit,
  ) async {
    _currentQuery = null;
    _currentPlatform = null;
    _currentCategory = null;
    _searchCurrentPage = 1;
    _trendingCurrentPage = 1;
    emit(const SearchInitial());
  }

  /// Maps failure to user-friendly message
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Server error occurred. Please try again later.';
      case CacheFailure:
        return 'Cache error occurred. Please clear cache and try again.';
      case NetworkFailure:
        return 'Network error. Please check your internet connection.';
      case ValidationFailure:
        return 'Invalid search query. Please check your input.';
      case NotFoundFailure:
        return 'No results found for your search.';
      case UnsupportedFormatFailure:
        return 'Unsupported platform or format.';
      case PermissionFailure:
        return 'Permission denied. Please check your access rights.';
      case StorageFailure:
        return 'Storage error occurred. Please check available space.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  @override
  Future<void> close() {
    return super.close();
  }
}