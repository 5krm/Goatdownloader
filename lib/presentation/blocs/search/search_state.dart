import 'package:equatable/equatable.dart';

import '../../../domain/entities/video.dart';
import '../../../core/error/failures.dart';

/// Base class for all search states
abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class SearchInitial extends SearchState {
  const SearchInitial();
}

/// Loading state
class SearchLoading extends SearchState {
  const SearchLoading();
}

/// Loading more results state
class SearchLoadingMore extends SearchState {
  final List<Video> currentResults;

  const SearchLoadingMore({required this.currentResults});

  @override
  List<Object?> get props => [currentResults];
}

/// Search results loaded successfully
class SearchResultsLoaded extends SearchState {
  final List<Video> videos;
  final String query;
  final String? platform;
  final int currentPage;
  final bool hasMoreResults;
  final int totalResults;

  const SearchResultsLoaded({
    required this.videos,
    required this.query,
    this.platform,
    required this.currentPage,
    required this.hasMoreResults,
    required this.totalResults,
  });

  SearchResultsLoaded copyWith({
    List<Video>? videos,
    String? query,
    String? platform,
    int? currentPage,
    bool? hasMoreResults,
    int? totalResults,
  }) {
    return SearchResultsLoaded(
      videos: videos ?? this.videos,
      query: query ?? this.query,
      platform: platform ?? this.platform,
      currentPage: currentPage ?? this.currentPage,
      hasMoreResults: hasMoreResults ?? this.hasMoreResults,
      totalResults: totalResults ?? this.totalResults,
    );
  }

  @override
  List<Object?> get props => [
        videos,
        query,
        platform,
        currentPage,
        hasMoreResults,
        totalResults,
      ];
}

/// Trending videos loaded successfully
class TrendingVideosLoaded extends SearchState {
  final List<Video> videos;
  final String? platform;
  final String? category;
  final int currentPage;
  final bool hasMoreResults;

  const TrendingVideosLoaded({
    required this.videos,
    this.platform,
    this.category,
    required this.currentPage,
    required this.hasMoreResults,
  });

  TrendingVideosLoaded copyWith({
    List<Video>? videos,
    String? platform,
    String? category,
    int? currentPage,
    bool? hasMoreResults,
  }) {
    return TrendingVideosLoaded(
      videos: videos ?? this.videos,
      platform: platform ?? this.platform,
      category: category ?? this.category,
      currentPage: currentPage ?? this.currentPage,
      hasMoreResults: hasMoreResults ?? this.hasMoreResults,
    );
  }

  @override
  List<Object?> get props => [
        videos,
        platform,
        category,
        currentPage,
        hasMoreResults,
      ];
}

/// Search history loaded
class SearchHistoryLoaded extends SearchState {
  final List<String> searchHistory;

  const SearchHistoryLoaded({required this.searchHistory});

  @override
  List<Object?> get props => [searchHistory];
}

/// Search suggestions loaded
class SearchSuggestionsLoaded extends SearchState {
  final List<String> suggestions;
  final String query;

  const SearchSuggestionsLoaded({
    required this.suggestions,
    required this.query,
  });

  @override
  List<Object?> get props => [suggestions, query];
}

/// Search results cleared
class SearchResultsCleared extends SearchState {
  const SearchResultsCleared();
}

/// Trending videos cleared
class TrendingVideosCleared extends SearchState {
  const TrendingVideosCleared();
}

/// Search history cleared
class SearchHistoryCleared extends SearchState {
  const SearchHistoryCleared();
}

/// Search query updated
class SearchQueryUpdated extends SearchState {
  final String query;

  const SearchQueryUpdated({required this.query});

  @override
  List<Object?> get props => [query];
}

/// Search platform updated
class SearchPlatformUpdated extends SearchState {
  final String? platform;

  const SearchPlatformUpdated({this.platform});

  @override
  List<Object?> get props => [platform];
}

/// Trending category updated
class TrendingCategoryUpdated extends SearchState {
  final String? category;

  const TrendingCategoryUpdated({this.category});

  @override
  List<Object?> get props => [category];
}

/// Search added to history
class SearchAddedToHistory extends SearchState {
  final String query;

  const SearchAddedToHistory({required this.query});

  @override
  List<Object?> get props => [query];
}

/// Search removed from history
class SearchRemovedFromHistory extends SearchState {
  final String query;

  const SearchRemovedFromHistory({required this.query});

  @override
  List<Object?> get props => [query];
}

/// Error state
class SearchError extends SearchState {
  final Failure failure;
  final String message;

  const SearchError({
    required this.failure,
    required this.message,
  });

  @override
  List<Object?> get props => [failure, message];
}

/// Combined state for handling multiple operations
class SearchCombinedState extends SearchState {
  final List<Video>? searchResults;
  final List<Video>? trendingVideos;
  final List<String>? searchHistory;
  final List<String>? suggestions;
  final String? currentQuery;
  final String? currentPlatform;
  final String? currentCategory;
  final bool isSearching;
  final bool isLoadingTrending;
  final bool isLoadingMore;
  final bool hasMoreSearchResults;
  final bool hasMoreTrendingResults;
  final int searchCurrentPage;
  final int trendingCurrentPage;
  final int totalSearchResults;

  const SearchCombinedState({
    this.searchResults,
    this.trendingVideos,
    this.searchHistory,
    this.suggestions,
    this.currentQuery,
    this.currentPlatform,
    this.currentCategory,
    this.isSearching = false,
    this.isLoadingTrending = false,
    this.isLoadingMore = false,
    this.hasMoreSearchResults = false,
    this.hasMoreTrendingResults = false,
    this.searchCurrentPage = 1,
    this.trendingCurrentPage = 1,
    this.totalSearchResults = 0,
  });

  SearchCombinedState copyWith({
    List<Video>? searchResults,
    List<Video>? trendingVideos,
    List<String>? searchHistory,
    List<String>? suggestions,
    String? currentQuery,
    String? currentPlatform,
    String? currentCategory,
    bool? isSearching,
    bool? isLoadingTrending,
    bool? isLoadingMore,
    bool? hasMoreSearchResults,
    bool? hasMoreTrendingResults,
    int? searchCurrentPage,
    int? trendingCurrentPage,
    int? totalSearchResults,
  }) {
    return SearchCombinedState(
      searchResults: searchResults ?? this.searchResults,
      trendingVideos: trendingVideos ?? this.trendingVideos,
      searchHistory: searchHistory ?? this.searchHistory,
      suggestions: suggestions ?? this.suggestions,
      currentQuery: currentQuery ?? this.currentQuery,
      currentPlatform: currentPlatform ?? this.currentPlatform,
      currentCategory: currentCategory ?? this.currentCategory,
      isSearching: isSearching ?? this.isSearching,
      isLoadingTrending: isLoadingTrending ?? this.isLoadingTrending,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMoreSearchResults: hasMoreSearchResults ?? this.hasMoreSearchResults,
      hasMoreTrendingResults: hasMoreTrendingResults ?? this.hasMoreTrendingResults,
      searchCurrentPage: searchCurrentPage ?? this.searchCurrentPage,
      trendingCurrentPage: trendingCurrentPage ?? this.trendingCurrentPage,
      totalSearchResults: totalSearchResults ?? this.totalSearchResults,
    );
  }

  @override
  List<Object?> get props => [
        searchResults,
        trendingVideos,
        searchHistory,
        suggestions,
        currentQuery,
        currentPlatform,
        currentCategory,
        isSearching,
        isLoadingTrending,
        isLoadingMore,
        hasMoreSearchResults,
        hasMoreTrendingResults,
        searchCurrentPage,
        trendingCurrentPage,
        totalSearchResults,
      ];
}