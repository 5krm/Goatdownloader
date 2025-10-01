import 'package:equatable/equatable.dart';

/// Base class for all search events
abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

/// Event to search for videos
class SearchVideosEvent extends SearchEvent {
  final String query;
  final String? platform;
  final int page;
  final int limit;

  const SearchVideosEvent({
    required this.query,
    this.platform,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [query, platform, page, limit];
}

/// Event to get trending videos
class GetTrendingVideosEvent extends SearchEvent {
  final String? platform;
  final String? category;
  final int page;
  final int limit;

  const GetTrendingVideosEvent({
    this.platform,
    this.category,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [platform, category, page, limit];
}

/// Event to load more search results
class LoadMoreSearchResultsEvent extends SearchEvent {
  const LoadMoreSearchResultsEvent();
}

/// Event to load more trending videos
class LoadMoreTrendingVideosEvent extends SearchEvent {
  const LoadMoreTrendingVideosEvent();
}

/// Event to clear search results
class ClearSearchResultsEvent extends SearchEvent {
  const ClearSearchResultsEvent();
}

/// Event to clear trending videos
class ClearTrendingVideosEvent extends SearchEvent {
  const ClearTrendingVideosEvent();
}

/// Event to update search query
class UpdateSearchQueryEvent extends SearchEvent {
  final String query;

  const UpdateSearchQueryEvent({required this.query});

  @override
  List<Object?> get props => [query];
}

/// Event to update search platform filter
class UpdateSearchPlatformEvent extends SearchEvent {
  final String? platform;

  const UpdateSearchPlatformEvent({this.platform});

  @override
  List<Object?> get props => [platform];
}

/// Event to update trending category filter
class UpdateTrendingCategoryEvent extends SearchEvent {
  final String? category;

  const UpdateTrendingCategoryEvent({this.category});

  @override
  List<Object?> get props => [category];
}

/// Event to refresh search results
class RefreshSearchResultsEvent extends SearchEvent {
  const RefreshSearchResultsEvent();
}

/// Event to refresh trending videos
class RefreshTrendingVideosEvent extends SearchEvent {
  const RefreshTrendingVideosEvent();
}

/// Event to add search query to history
class AddSearchToHistoryEvent extends SearchEvent {
  final String query;

  const AddSearchToHistoryEvent({required this.query});

  @override
  List<Object?> get props => [query];
}

/// Event to get search history
class GetSearchHistoryEvent extends SearchEvent {
  const GetSearchHistoryEvent();
}

/// Event to clear search history
class ClearSearchHistoryEvent extends SearchEvent {
  const ClearSearchHistoryEvent();
}

/// Event to remove search from history
class RemoveSearchFromHistoryEvent extends SearchEvent {
  final String query;

  const RemoveSearchFromHistoryEvent({required this.query});

  @override
  List<Object?> get props => [query];
}

/// Event to get search suggestions
class GetSearchSuggestionsEvent extends SearchEvent {
  final String query;

  const GetSearchSuggestionsEvent({required this.query});

  @override
  List<Object?> get props => [query];
}

/// Event to reset search state
class ResetSearchStateEvent extends SearchEvent {
  const ResetSearchStateEvent();
}