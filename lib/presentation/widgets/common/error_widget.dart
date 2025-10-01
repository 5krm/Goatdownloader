import 'package:flutter/material.dart';

enum ErrorType {
  network,
  server,
  notFound,
  unauthorized,
  forbidden,
  timeout,
  unknown,
  validation,
  storage,
  permission,
}

class CustomErrorWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final ErrorType type;
  final VoidCallback? onRetry;
  final String? retryButtonText;
  final Widget? icon;
  final EdgeInsetsGeometry? padding;
  final bool showRetryButton;
  final List<Widget>? actions;

  const CustomErrorWidget({
    Key? key,
    this.title,
    this.message,
    this.type = ErrorType.unknown,
    this.onRetry,
    this.retryButtonText,
    this.icon,
    this.padding,
    this.showRetryButton = true,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorInfo = _getErrorInfo(context);

    return Container(
      padding: padding ?? const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Error Icon
          icon ?? _buildDefaultIcon(theme),
          const SizedBox(height: 24),
          
          // Error Title
          Text(
            title ?? errorInfo.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          
          // Error Message
          Text(
            message ?? errorInfo.message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // Action Buttons
          if (showRetryButton && onRetry != null) ...[
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(retryButtonText ?? 'Retry'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Custom Actions
          if (actions != null) ...actions!,
        ],
      ),
    );
  }

  Widget _buildDefaultIcon(ThemeData theme) {
    IconData iconData;
    Color iconColor;

    switch (type) {
      case ErrorType.network:
        iconData = Icons.wifi_off;
        iconColor = Colors.orange;
        break;
      case ErrorType.server:
        iconData = Icons.dns;
        iconColor = Colors.red;
        break;
      case ErrorType.notFound:
        iconData = Icons.search_off;
        iconColor = Colors.grey;
        break;
      case ErrorType.unauthorized:
        iconData = Icons.lock;
        iconColor = Colors.amber;
        break;
      case ErrorType.forbidden:
        iconData = Icons.block;
        iconColor = Colors.red;
        break;
      case ErrorType.timeout:
        iconData = Icons.timer_off;
        iconColor = Colors.orange;
        break;
      case ErrorType.validation:
        iconData = Icons.error_outline;
        iconColor = Colors.amber;
        break;
      case ErrorType.storage:
        iconData = Icons.storage;
        iconColor = Colors.red;
        break;
      case ErrorType.permission:
        iconData = Icons.security;
        iconColor = Colors.amber;
        break;
      case ErrorType.unknown:
      default:
        iconData = Icons.error_outline;
        iconColor = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        size: 64,
        color: iconColor,
      ),
    );
  }

  ErrorInfo _getErrorInfo(BuildContext context) {
    switch (type) {
      case ErrorType.network:
        return ErrorInfo(
          title: 'No Internet Connection',
          message: 'Please check your internet connection and try again.',
        );
      case ErrorType.server:
        return ErrorInfo(
          title: 'Server Error',
          message: 'Something went wrong on our end. Please try again later.',
        );
      case ErrorType.notFound:
        return ErrorInfo(
          title: 'Not Found',
          message: 'The content you\'re looking for could not be found.',
        );
      case ErrorType.unauthorized:
        return ErrorInfo(
          title: 'Unauthorized',
          message: 'You need to sign in to access this content.',
        );
      case ErrorType.forbidden:
        return ErrorInfo(
          title: 'Access Denied',
          message: 'You don\'t have permission to access this content.',
        );
      case ErrorType.timeout:
        return ErrorInfo(
          title: 'Request Timeout',
          message: 'The request took too long to complete. Please try again.',
        );
      case ErrorType.validation:
        return ErrorInfo(
          title: 'Invalid Input',
          message: 'Please check your input and try again.',
        );
      case ErrorType.storage:
        return ErrorInfo(
          title: 'Storage Error',
          message: 'Unable to access storage. Please check permissions.',
        );
      case ErrorType.permission:
        return ErrorInfo(
          title: 'Permission Required',
          message: 'This feature requires additional permissions.',
        );
      case ErrorType.unknown:
      default:
        return ErrorInfo(
          title: 'Something Went Wrong',
          message: 'An unexpected error occurred. Please try again.',
        );
    }
  }
}

class ErrorInfo {
  final String title;
  final String message;

  ErrorInfo({required this.title, required this.message});
}

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(BuildContext context, Object error, StackTrace? stackTrace)? errorBuilder;
  final void Function(Object error, StackTrace? stackTrace)? onError;

  const ErrorBoundary({
    Key? key,
    required this.child,
    this.errorBuilder,
    this.onError,
  }) : super(key: key);

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(context, _error!, _stackTrace);
      }
      
      return CustomErrorWidget(
        type: ErrorType.unknown,
        title: 'Something Went Wrong',
        message: 'An unexpected error occurred in the application.',
        onRetry: () {
          setState(() {
            _error = null;
            _stackTrace = null;
          });
        },
      );
    }

    return widget.child;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    FlutterError.onError = (FlutterErrorDetails details) {
      if (mounted) {
        setState(() {
          _error = details.exception;
          _stackTrace = details.stack;
        });
        widget.onError?.call(details.exception, details.stack);
      }
    };
  }
}

class ErrorSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    ErrorType type = ErrorType.unknown,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onRetry,
    String? retryText,
  }) {
    final theme = Theme.of(context);
    Color backgroundColor;
    IconData iconData;

    switch (type) {
      case ErrorType.network:
        backgroundColor = Colors.orange;
        iconData = Icons.wifi_off;
        break;
      case ErrorType.server:
        backgroundColor = Colors.red;
        iconData = Icons.dns;
        break;
      case ErrorType.validation:
        backgroundColor = Colors.amber;
        iconData = Icons.error_outline;
        break;
      default:
        backgroundColor = theme.colorScheme.error;
        iconData = Icons.error_outline;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(iconData, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        action: onRetry != null
            ? SnackBarAction(
                label: retryText ?? 'Retry',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class ErrorDialog {
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    ErrorType type = ErrorType.unknown,
    VoidCallback? onRetry,
    String? retryText,
    List<Widget>? actions,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                _getIconForType(type),
                color: _getColorForType(type),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(title)),
            ],
          ),
          content: Text(message),
          actions: [
            if (actions != null) ...actions!,
            if (onRetry != null)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onRetry();
                },
                child: Text(retryText ?? 'Retry'),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static IconData _getIconForType(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.server:
        return Icons.dns;
      case ErrorType.notFound:
        return Icons.search_off;
      case ErrorType.unauthorized:
        return Icons.lock;
      case ErrorType.forbidden:
        return Icons.block;
      case ErrorType.timeout:
        return Icons.timer_off;
      case ErrorType.validation:
        return Icons.error_outline;
      case ErrorType.storage:
        return Icons.storage;
      case ErrorType.permission:
        return Icons.security;
      default:
        return Icons.error_outline;
    }
  }

  static Color _getColorForType(ErrorType type) {
    switch (type) {
      case ErrorType.network:
      case ErrorType.timeout:
        return Colors.orange;
      case ErrorType.server:
      case ErrorType.forbidden:
      case ErrorType.storage:
        return Colors.red;
      case ErrorType.unauthorized:
      case ErrorType.validation:
      case ErrorType.permission:
        return Colors.amber;
      case ErrorType.notFound:
        return Colors.grey;
      default:
        return Colors.red;
    }
  }
}

class ErrorListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final ErrorType type;
  final VoidCallback? onTap;
  final VoidCallback? onRetry;

  const ErrorListTile({
    Key? key,
    required this.title,
    this.subtitle,
    this.type = ErrorType.unknown,
    this.onTap,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: ErrorDialog._getColorForType(type).withOpacity(0.1),
        child: Icon(
          ErrorDialog._getIconForType(type),
          color: ErrorDialog._getColorForType(type),
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            )
          : null,
      trailing: onRetry != null
          ? IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: onRetry,
              tooltip: 'Retry',
            )
          : null,
      onTap: onTap,
    );
  }
}