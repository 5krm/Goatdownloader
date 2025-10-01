import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SearchBarWidget extends StatefulWidget {
  final String? initialQuery;
  final String hintText;
  final List<String> suggestions;
  final List<String> searchHistory;
  final Function(String) onSearch;
  final Function(String)? onQueryChanged;
  final Function(String)? onSuggestionTap;
  final Function(String)? onHistoryTap;
  final Function(String)? onHistoryDelete;
  final VoidCallback? onClear;
  final VoidCallback? onClearHistory;
  final bool showSuggestions;
  final bool showHistory;
  final bool autofocus;
  final bool enabled;
  final Widget? leading;
  final List<Widget>? actions;
  final EdgeInsetsGeometry? contentPadding;

  const SearchBarWidget({
    Key? key,
    this.initialQuery,
    this.hintText = 'Search videos...',
    this.suggestions = const [],
    this.searchHistory = const [],
    required this.onSearch,
    this.onQueryChanged,
    this.onSuggestionTap,
    this.onHistoryTap,
    this.onHistoryDelete,
    this.onClear,
    this.onClearHistory,
    this.showSuggestions = true,
    this.showHistory = true,
    this.autofocus = false,
    this.enabled = true,
    this.leading,
    this.actions,
    this.contentPadding,
  }) : super(key: key);

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget>
    with TickerProviderStateMixin {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  bool _showSuggestions = false;
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _focusNode = FocusNode();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _currentQuery = widget.initialQuery ?? '';
    
    _focusNode.addListener(_onFocusChanged);
    _controller.addListener(_onTextChanged);
    
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus && (_currentQuery.isNotEmpty || widget.searchHistory.isNotEmpty)) {
      _showSuggestions = true;
      _animationController.forward();
    } else {
      _showSuggestions = false;
      _animationController.reverse();
    }
    setState(() {});
  }

  void _onTextChanged() {
    final newQuery = _controller.text;
    if (newQuery != _currentQuery) {
      _currentQuery = newQuery;
      widget.onQueryChanged?.call(newQuery);
      
      if (_focusNode.hasFocus) {
        if (newQuery.isNotEmpty || widget.searchHistory.isNotEmpty) {
          if (!_showSuggestions) {
            _showSuggestions = true;
            _animationController.forward();
          }
        } else {
          if (_showSuggestions) {
            _showSuggestions = false;
            _animationController.reverse();
          }
        }
        setState(() {});
      }
    }
  }

  void _onSearch() {
    if (_currentQuery.trim().isNotEmpty) {
      widget.onSearch(_currentQuery.trim());
      _focusNode.unfocus();
    }
  }

  void _onSuggestionSelected(String suggestion) {
    _controller.text = suggestion;
    _currentQuery = suggestion;
    widget.onSuggestionTap?.call(suggestion);
    widget.onSearch(suggestion);
    _focusNode.unfocus();
  }

  void _onHistorySelected(String historyItem) {
    _controller.text = historyItem;
    _currentQuery = historyItem;
    widget.onHistoryTap?.call(historyItem);
    widget.onSearch(historyItem);
    _focusNode.unfocus();
  }

  void _onClear() {
    _controller.clear();
    _currentQuery = '';
    widget.onClear?.call();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchField(context),
        if (_showSuggestions) _buildSuggestionsList(context),
      ],
    );
  }

  Widget _buildSearchField(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _focusNode.hasFocus
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withOpacity(0.3),
          width: _focusNode.hasFocus ? 2 : 1,
        ),
        boxShadow: _focusNode.hasFocus
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // Leading widget or search icon
          if (widget.leading != null)
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: widget.leading!,
            )
          else
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Icon(
                Icons.search,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                size: 24,
              ),
            ),
          
          // Text field
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              enabled: widget.enabled,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _onSearch(),
              style: theme.textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
                border: InputBorder.none,
                contentPadding: widget.contentPadding ??
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
            ),
          ),
          
          // Clear button
          if (_currentQuery.isNotEmpty)
            IconButton(
              onPressed: _onClear,
              icon: Icon(
                Icons.clear,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                size: 20,
              ),
              tooltip: 'Clear',
            ),
          
          // Actions
          if (widget.actions != null) ...widget.actions!,
          
          // Search button
          IconButton(
            onPressed: _currentQuery.trim().isNotEmpty ? _onSearch : null,
            icon: Icon(
              Icons.search,
              color: _currentQuery.trim().isNotEmpty
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.4),
              size: 24,
            ),
            tooltip: 'Search',
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsList(BuildContext context) {
    final theme = Theme.of(context);
    final filteredSuggestions = _getFilteredSuggestions();
    final showHistory = widget.showHistory && 
                       _currentQuery.isEmpty && 
                       widget.searchHistory.isNotEmpty;
    
    if (!showHistory && filteredSuggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.only(top: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        constraints: const BoxConstraints(maxHeight: 300),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            // Search history
            if (showHistory) ...[
              _buildSectionHeader(
                context,
                'Recent Searches',
                onClear: widget.onClearHistory,
              ),
              ...widget.searchHistory.take(5).map(
                (item) => _buildHistoryItem(context, item),
              ),
              if (filteredSuggestions.isNotEmpty) const Divider(),
            ],
            
            // Suggestions
            if (filteredSuggestions.isNotEmpty) ...[
              if (showHistory)
                _buildSectionHeader(context, 'Suggestions')
              else if (_currentQuery.isNotEmpty)
                _buildSectionHeader(context, 'Search Suggestions'),
              ...filteredSuggestions.take(8).map(
                (suggestion) => _buildSuggestionItem(context, suggestion),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title, {
    VoidCallback? onClear,
  }) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
          if (onClear != null)
            TextButton(
              onPressed: onClear,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Clear',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(BuildContext context, String suggestion) {
    final theme = Theme.of(context);
    final highlightedText = _buildHighlightedText(context, suggestion);
    
    return InkWell(
      onTap: () => _onSuggestionSelected(suggestion),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              Icons.search,
              size: 20,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(width: 12),
            Expanded(child: highlightedText),
            Icon(
              Icons.north_west,
              size: 16,
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, String historyItem) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: () => _onHistorySelected(historyItem),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              Icons.history,
              size: 20,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                historyItem,
                style: theme.textTheme.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              onPressed: () => widget.onHistoryDelete?.call(historyItem),
              icon: Icon(
                Icons.close,
                size: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
              tooltip: 'Remove from history',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightedText(BuildContext context, String text) {
    final theme = Theme.of(context);
    final query = _currentQuery.toLowerCase();
    
    if (query.isEmpty || !text.toLowerCase().contains(query)) {
      return Text(
        text,
        style: theme.textTheme.bodyMedium,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    final startIndex = text.toLowerCase().indexOf(query);
    final endIndex = startIndex + query.length;

    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: theme.textTheme.bodyMedium,
        children: [
          if (startIndex > 0)
            TextSpan(text: text.substring(0, startIndex)),
          TextSpan(
            text: text.substring(startIndex, endIndex),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          if (endIndex < text.length)
            TextSpan(text: text.substring(endIndex)),
        ],
      ),
    );
  }

  List<String> _getFilteredSuggestions() {
    if (!widget.showSuggestions || _currentQuery.isEmpty) {
      return [];
    }

    final query = _currentQuery.toLowerCase();
    return widget.suggestions
        .where((suggestion) => 
            suggestion.toLowerCase().contains(query) &&
            suggestion.toLowerCase() != query)
        .toList();
  }
}

class SearchBarDelegate extends SearchDelegate<String> {
  final List<String> suggestions;
  final List<String> searchHistory;
  final Function(String) onSearch;
  final Function(String)? onSuggestionTap;
  final Function(String)? onHistoryTap;

  SearchBarDelegate({
    required this.suggestions,
    required this.searchHistory,
    required this.onSearch,
    this.onSuggestionTap,
    this.onHistoryTap,
    String? searchFieldLabel,
  }) : super(
          searchFieldLabel: searchFieldLabel ?? 'Search videos...',
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
        );

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
          icon: const Icon(Icons.clear),
          tooltip: 'Clear',
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, ''),
      icon: const Icon(Icons.arrow_back),
      tooltip: 'Back',
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.trim().isNotEmpty) {
      onSearch(query.trim());
      close(context, query.trim());
    }
    return const SizedBox.shrink();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final theme = Theme.of(context);
    final filteredSuggestions = _getFilteredSuggestions();
    final showHistory = query.isEmpty && searchHistory.isNotEmpty;

    if (!showHistory && filteredSuggestions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Start typing to search',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      children: [
        // Search history
        if (showHistory) ...[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Recent Searches',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ...searchHistory.take(5).map(
            (item) => ListTile(
              leading: const Icon(Icons.history),
              title: Text(item),
              onTap: () {
                query = item;
                onHistoryTap?.call(item);
                onSearch(item);
                close(context, item);
              },
            ),
          ),
          if (filteredSuggestions.isNotEmpty) const Divider(),
        ],

        // Suggestions
        if (filteredSuggestions.isNotEmpty) ...[
          if (showHistory)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Suggestions',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ...filteredSuggestions.take(8).map(
            (suggestion) => ListTile(
              leading: const Icon(Icons.search),
              title: _buildHighlightedText(context, suggestion),
              trailing: const Icon(Icons.north_west),
              onTap: () {
                query = suggestion;
                onSuggestionTap?.call(suggestion);
                onSearch(suggestion);
                close(context, suggestion);
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHighlightedText(BuildContext context, String text) {
    final theme = Theme.of(context);
    final queryLower = query.toLowerCase();
    
    if (queryLower.isEmpty || !text.toLowerCase().contains(queryLower)) {
      return Text(text);
    }

    final startIndex = text.toLowerCase().indexOf(queryLower);
    final endIndex = startIndex + queryLower.length;

    return RichText(
      text: TextSpan(
        style: theme.textTheme.bodyLarge,
        children: [
          if (startIndex > 0)
            TextSpan(text: text.substring(0, startIndex)),
          TextSpan(
            text: text.substring(startIndex, endIndex),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          if (endIndex < text.length)
            TextSpan(text: text.substring(endIndex)),
        ],
      ),
    );
  }

  List<String> _getFilteredSuggestions() {
    if (query.isEmpty) return [];

    final queryLower = query.toLowerCase();
    return suggestions
        .where((suggestion) => 
            suggestion.toLowerCase().contains(queryLower) &&
            suggestion.toLowerCase() != queryLower)
        .toList();
  }
}