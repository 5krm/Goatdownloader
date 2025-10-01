import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final double elevation;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool showSearch;
  final String? searchHint;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchSubmitted;
  final VoidCallback? onSearchClear;
  final bool automaticallyImplyLeading;
  final PreferredSizeWidget? bottom;
  final SystemUiOverlayStyle? systemOverlayStyle;
  final bool showThemeToggle;
  final VoidCallback? onThemeToggle;
  final bool isDarkMode;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.elevation = 4.0,
    this.backgroundColor,
    this.foregroundColor,
    this.showSearch = false,
    this.searchHint,
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.onSearchClear,
    this.automaticallyImplyLeading = true,
    this.bottom,
    this.systemOverlayStyle,
    this.showThemeToggle = false,
    this.onThemeToggle,
    this.isDarkMode = false,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
      );

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar>
    with SingleTickerProviderStateMixin {
  bool _isSearching = false;
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
    });

    if (_isSearching) {
      _animationController.forward();
      _searchFocusNode.requestFocus();
    } else {
      _animationController.reverse();
      _searchController.clear();
      _searchFocusNode.unfocus();
      widget.onSearchClear?.call();
    }
  }

  void _onSearchChanged(String value) {
    widget.onSearchChanged?.call(value);
  }

  void _onSearchSubmitted() {
    widget.onSearchSubmitted?.call();
    _searchFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppBar(
      title: _buildTitle(),
      leading: widget.leading,
      actions: _buildActions(),
      centerTitle: widget.centerTitle,
      elevation: widget.elevation,
      backgroundColor: widget.backgroundColor ?? theme.appBarTheme.backgroundColor,
      foregroundColor: widget.foregroundColor ?? theme.appBarTheme.foregroundColor,
      automaticallyImplyLeading: widget.automaticallyImplyLeading,
      bottom: widget.bottom,
      systemOverlayStyle: widget.systemOverlayStyle ?? theme.appBarTheme.systemOverlayStyle,
    );
  }

  Widget _buildTitle() {
    if (!widget.showSearch || !_isSearching) {
      return Text(
        widget.title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.3, 0),
              end: Offset.zero,
            ).animate(_animation),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: _onSearchChanged,
                onSubmitted: (_) => _onSearchSubmitted(),
                style: TextStyle(
                  color: Theme.of(context).appBarTheme.foregroundColor,
                ),
                decoration: InputDecoration(
                  hintText: widget.searchHint ?? 'Search...',
                  hintStyle: TextStyle(
                    color: Theme.of(context).appBarTheme.foregroundColor?.withOpacity(0.7),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            widget.onSearchClear?.call();
                          },
                          color: Theme.of(context).appBarTheme.foregroundColor,
                        )
                      : null,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildActions() {
    List<Widget> actions = [];

    // Search action
    if (widget.showSearch) {
      actions.add(
        IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              _isSearching ? Icons.close : Icons.search,
              key: ValueKey(_isSearching),
            ),
          ),
          onPressed: _toggleSearch,
          tooltip: _isSearching ? 'Close search' : 'Search',
        ),
      );
    }

    // Theme toggle action
    if (widget.showThemeToggle) {
      actions.add(
        IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Icon(
              widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              key: ValueKey(widget.isDarkMode),
            ),
          ),
          onPressed: widget.onThemeToggle,
          tooltip: widget.isDarkMode ? 'Switch to light mode' : 'Switch to dark mode',
        ),
      );
    }

    // Custom actions
    if (widget.actions != null) {
      actions.addAll(widget.actions!);
    }

    return actions;
  }
}

class SliverCustomAppBar extends StatefulWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final double expandedHeight;
  final double collapsedHeight;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Widget? background;
  final bool pinned;
  final bool floating;
  final bool snap;
  final bool showSearch;
  final String? searchHint;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchSubmitted;
  final VoidCallback? onSearchClear;
  final bool showThemeToggle;
  final VoidCallback? onThemeToggle;
  final bool isDarkMode;

  const SliverCustomAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.expandedHeight = 200.0,
    this.collapsedHeight = kToolbarHeight,
    this.backgroundColor,
    this.foregroundColor,
    this.background,
    this.pinned = true,
    this.floating = false,
    this.snap = false,
    this.showSearch = false,
    this.searchHint,
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.onSearchClear,
    this.showThemeToggle = false,
    this.onThemeToggle,
    this.isDarkMode = false,
  }) : super(key: key);

  @override
  State<SliverCustomAppBar> createState() => _SliverCustomAppBarState();
}

class _SliverCustomAppBarState extends State<SliverCustomAppBar> {
  bool _isSearching = false;
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
    });

    if (_isSearching) {
      _searchFocusNode.requestFocus();
    } else {
      _searchController.clear();
      _searchFocusNode.unfocus();
      widget.onSearchClear?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SliverAppBar(
      title: _buildTitle(),
      leading: widget.leading,
      actions: _buildActions(),
      centerTitle: widget.centerTitle,
      expandedHeight: widget.expandedHeight,
      collapsedHeight: widget.collapsedHeight,
      backgroundColor: widget.backgroundColor ?? theme.appBarTheme.backgroundColor,
      foregroundColor: widget.foregroundColor ?? theme.appBarTheme.foregroundColor,
      pinned: widget.pinned,
      floating: widget.floating,
      snap: widget.snap,
      flexibleSpace: widget.background != null
          ? FlexibleSpaceBar(
              background: widget.background,
              collapseMode: CollapseMode.parallax,
            )
          : null,
    );
  }

  Widget _buildTitle() {
    if (!widget.showSearch || !_isSearching) {
      return Text(
        widget.title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: widget.onSearchChanged,
        onSubmitted: (_) => widget.onSearchSubmitted?.call(),
        style: TextStyle(
          color: Theme.of(context).appBarTheme.foregroundColor,
        ),
        decoration: InputDecoration(
          hintText: widget.searchHint ?? 'Search...',
          hintStyle: TextStyle(
            color: Theme.of(context).appBarTheme.foregroundColor?.withOpacity(0.7),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    widget.onSearchClear?.call();
                  },
                  color: Theme.of(context).appBarTheme.foregroundColor,
                )
              : null,
        ),
      ),
    );
  }

  List<Widget> _buildActions() {
    List<Widget> actions = [];

    // Search action
    if (widget.showSearch) {
      actions.add(
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search),
          onPressed: _toggleSearch,
          tooltip: _isSearching ? 'Close search' : 'Search',
        ),
      );
    }

    // Theme toggle action
    if (widget.showThemeToggle) {
      actions.add(
        IconButton(
          icon: Icon(
            widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
          ),
          onPressed: widget.onThemeToggle,
          tooltip: widget.isDarkMode ? 'Switch to light mode' : 'Switch to dark mode',
        ),
      );
    }

    // Custom actions
    if (widget.actions != null) {
      actions.addAll(widget.actions!);
    }

    return actions;
  }
}

class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;
  final VoidCallback? onClear;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final TextEditingController? controller;
  final bool autofocus;

  const SearchAppBar({
    Key? key,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.onBack,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
    this.controller,
    this.autofocus = true,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<SearchAppBar> createState() => _SearchAppBarState();
}

class _SearchAppBarState extends State<SearchAppBar> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = FocusNode();
    
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppBar(
      backgroundColor: widget.backgroundColor ?? theme.appBarTheme.backgroundColor,
      foregroundColor: widget.foregroundColor ?? theme.appBarTheme.foregroundColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: widget.onBack ?? () => Navigator.of(context).pop(),
      ),
      title: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: widget.onChanged,
        onSubmitted: (_) => widget.onSubmitted?.call(),
        style: TextStyle(
          color: widget.foregroundColor ?? theme.appBarTheme.foregroundColor,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText ?? 'Search...',
          hintStyle: TextStyle(
            color: (widget.foregroundColor ?? theme.appBarTheme.foregroundColor)
                ?.withOpacity(0.7),
          ),
          border: InputBorder.none,
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    widget.onClear?.call();
                  },
                  color: widget.foregroundColor ?? theme.appBarTheme.foregroundColor,
                )
              : null,
        ),
      ),
      actions: widget.actions,
    );
  }
}