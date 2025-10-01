import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../domain/entities/download.dart';
import '../common/loading_widget.dart';

enum DownloadCardType {
  list,
  compact,
  detailed,
}

class DownloadCard extends StatelessWidget {
  final Download download;
  final DownloadCardType type;
  final VoidCallback? onTap;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final VoidCallback? onCancel;
  final VoidCallback? onRetry;
  final VoidCallback? onDelete;
  final VoidCallback? onOpenFile;
  final VoidCallback? onOpenFolder;
  final VoidCallback? onShare;
  final bool showActions;
  final EdgeInsetsGeometry? margin;

  const DownloadCard({
    Key? key,
    required this.download,
    this.type = DownloadCardType.list,
    this.onTap,
    this.onPause,
    this.onResume,
    this.onCancel,
    this.onRetry,
    this.onDelete,
    this.onOpenFile,
    this.onOpenFolder,
    this.onShare,
    this.showActions = true,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case DownloadCardType.list:
        return _buildListCard(context);
      case DownloadCardType.compact:
        return _buildCompactCard(context);
      case DownloadCardType.detailed:
        return _buildDetailedCard(context);
    }
  }

  Widget _buildListCard(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail
                  _buildThumbnail(context, width: 80, height: 60),
                  const SizedBox(width: 12),
                  
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          download.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        
                        // Status and metadata
                        _buildStatusInfo(context),
                        const SizedBox(height: 8),
                        
                        // Progress bar
                        _buildProgressBar(context),
                      ],
                    ),
                  ),
                  
                  // Status icon
                  _buildStatusIcon(context),
                ],
              ),
              
              // Actions
              if (showActions) ...[
                const SizedBox(height: 12),
                _buildActions(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactCard(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              // Thumbnail
              _buildThumbnail(context, width: 60, height: 45),
              const SizedBox(width: 12),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      download.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // Progress bar
                    _buildProgressBar(context, compact: true),
                    const SizedBox(height: 2),
                    
                    // Status
                    Text(
                      _getStatusText(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _getStatusColor(theme),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Action button
              _buildPrimaryActionButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailedCard(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: margin ?? const EdgeInsets.all(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail
                  _buildThumbnail(context, width: 120, height: 90),
                  const SizedBox(width: 16),
                  
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          download.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        
                        // Channel
                        if (download.channelName.isNotEmpty) ...[
                          Text(
                            download.channelName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        
                        // Metadata
                        _buildDetailedMetadata(context),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Progress section
              _buildDetailedProgress(context),
              const SizedBox(height: 16),
              
              // Actions
              if (showActions) _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(
    BuildContext context, {
    required double width,
    required double height,
  }) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: download.thumbnail,
            width: width,
            height: height,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              width: width,
              height: height,
              color: Colors.grey[300],
              child: const LoadingWidget(
                type: LoadingType.skeleton,
                showMessage: false,
              ),
            ),
            errorWidget: (context, url, error) => Container(
              width: width,
              height: height,
              color: Colors.grey[300],
              child: const Icon(
                Icons.video_library,
                size: 24,
                color: Colors.grey,
              ),
            ),
          ),
        ),
        
        // Quality badge
        if (download.quality.isNotEmpty)
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                download.quality,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusIcon(BuildContext context) {
    final theme = Theme.of(context);
    IconData iconData;
    Color iconColor;

    switch (download.status) {
      case DownloadStatus.downloading:
        iconData = Icons.download;
        iconColor = theme.colorScheme.primary;
        break;
      case DownloadStatus.paused:
        iconData = Icons.pause;
        iconColor = Colors.orange;
        break;
      case DownloadStatus.completed:
        iconData = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case DownloadStatus.failed:
        iconData = Icons.error;
        iconColor = Colors.red;
        break;
      case DownloadStatus.cancelled:
        iconData = Icons.cancel;
        iconColor = Colors.grey;
        break;
      case DownloadStatus.queued:
        iconData = Icons.queue;
        iconColor = Colors.blue;
        break;
      default:
        iconData = Icons.help_outline;
        iconColor = Colors.grey;
        break;
    }

    return Icon(
      iconData,
      color: iconColor,
      size: 24,
    );
  }

  Widget _buildStatusInfo(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status and speed
        Row(
          children: [
            Text(
              _getStatusText(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: _getStatusColor(theme),
                fontWeight: FontWeight.w500,
              ),
            ),
            if (download.status == DownloadStatus.downloading && download.speed > 0) ...[
              const SizedBox(width: 8),
              Text(
                '• ${_formatSpeed(download.speed)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 2),
        
        // Size info
        Text(
          _getSizeInfo(),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context, {bool compact = false}) {
    final theme = Theme.of(context);
    final progress = download.totalSize > 0 
        ? download.downloadedSize / download.totalSize 
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: progress,
          backgroundColor: theme.colorScheme.onSurface.withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation<Color>(
            _getStatusColor(theme),
          ),
        ),
        if (!compact) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toStringAsFixed(1)}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              if (download.estimatedTimeRemaining > 0)
                Text(
                  _formatTimeRemaining(download.estimatedTimeRemaining),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDetailedProgress(BuildContext context) {
    final theme = Theme.of(context);
    final progress = download.totalSize > 0 
        ? download.downloadedSize / download.totalSize 
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: progress,
            backgroundColor: theme.colorScheme.onSurface.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(
              _getStatusColor(theme),
            ),
          ),
          const SizedBox(height: 12),
          
          // Progress info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Progress',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    '${(progress * 100).toStringAsFixed(1)}%',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (download.speed > 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Speed',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      _formatSpeed(download.speed),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              if (download.estimatedTimeRemaining > 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Time Left',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      _formatTimeRemaining(download.estimatedTimeRemaining),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedMetadata(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Format and quality
        Row(
          children: [
            if (download.format.isNotEmpty) ...[
              _buildMetadataChip(context, download.format.toUpperCase()),
              const SizedBox(width: 8),
            ],
            if (download.quality.isNotEmpty)
              _buildMetadataChip(context, download.quality),
          ],
        ),
        const SizedBox(height: 8),
        
        // File info
        Text(
          'File: ${download.fileName}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        
        // Path
        Text(
          'Path: ${download.filePath}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildMetadataChip(BuildContext context, String text) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPrimaryActionButton(BuildContext context) {
    switch (download.status) {
      case DownloadStatus.downloading:
        return IconButton(
          icon: const Icon(Icons.pause),
          onPressed: onPause,
          tooltip: 'Pause',
        );
      case DownloadStatus.paused:
        return IconButton(
          icon: const Icon(Icons.play_arrow),
          onPressed: onResume,
          tooltip: 'Resume',
        );
      case DownloadStatus.failed:
        return IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: onRetry,
          tooltip: 'Retry',
        );
      case DownloadStatus.completed:
        return IconButton(
          icon: const Icon(Icons.folder_open),
          onPressed: onOpenFolder,
          tooltip: 'Open folder',
        );
      default:
        return IconButton(
          icon: const Icon(Icons.cancel),
          onPressed: onCancel,
          tooltip: 'Cancel',
        );
    }
  }

  Widget _buildActions(BuildContext context) {
    List<Widget> actions = [];

    switch (download.status) {
      case DownloadStatus.downloading:
        actions.addAll([
          OutlinedButton.icon(
            onPressed: onPause,
            icon: const Icon(Icons.pause, size: 18),
            label: const Text('Pause'),
          ),
          TextButton.icon(
            onPressed: onCancel,
            icon: const Icon(Icons.cancel, size: 18),
            label: const Text('Cancel'),
          ),
        ]);
        break;
      case DownloadStatus.paused:
        actions.addAll([
          ElevatedButton.icon(
            onPressed: onResume,
            icon: const Icon(Icons.play_arrow, size: 18),
            label: const Text('Resume'),
          ),
          TextButton.icon(
            onPressed: onCancel,
            icon: const Icon(Icons.cancel, size: 18),
            label: const Text('Cancel'),
          ),
        ]);
        break;
      case DownloadStatus.failed:
        actions.addAll([
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Retry'),
          ),
          TextButton.icon(
            onPressed: onDelete,
            icon: const Icon(Icons.delete, size: 18),
            label: const Text('Delete'),
          ),
        ]);
        break;
      case DownloadStatus.completed:
        actions.addAll([
          ElevatedButton.icon(
            onPressed: onOpenFile,
            icon: const Icon(Icons.play_arrow, size: 18),
            label: const Text('Play'),
          ),
          OutlinedButton.icon(
            onPressed: onOpenFolder,
            icon: const Icon(Icons.folder_open, size: 18),
            label: const Text('Open Folder'),
          ),
          TextButton.icon(
            onPressed: onShare,
            icon: const Icon(Icons.share, size: 18),
            label: const Text('Share'),
          ),
        ]);
        break;
      default:
        actions.add(
          TextButton.icon(
            onPressed: onDelete,
            icon: const Icon(Icons.delete, size: 18),
            label: const Text('Delete'),
          ),
        );
        break;
    }

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: actions,
    );
  }

  String _getStatusText() {
    switch (download.status) {
      case DownloadStatus.downloading:
        return 'Downloading';
      case DownloadStatus.paused:
        return 'Paused';
      case DownloadStatus.completed:
        return 'Completed';
      case DownloadStatus.failed:
        return 'Failed';
      case DownloadStatus.cancelled:
        return 'Cancelled';
      case DownloadStatus.queued:
        return 'Queued';
      default:
        return 'Unknown';
    }
  }

  Color _getStatusColor(ThemeData theme) {
    switch (download.status) {
      case DownloadStatus.downloading:
        return theme.colorScheme.primary;
      case DownloadStatus.paused:
        return Colors.orange;
      case DownloadStatus.completed:
        return Colors.green;
      case DownloadStatus.failed:
        return Colors.red;
      case DownloadStatus.cancelled:
        return Colors.grey;
      case DownloadStatus.queued:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getSizeInfo() {
    if (download.totalSize > 0) {
      return '${_formatBytes(download.downloadedSize)} / ${_formatBytes(download.totalSize)}';
    } else {
      return _formatBytes(download.downloadedSize);
    }
  }

  String _formatBytes(int bytes) {
    if (bytes >= 1073741824) {
      return '${(bytes / 1073741824).toStringAsFixed(1)} GB';
    } else if (bytes >= 1048576) {
      return '${(bytes / 1048576).toStringAsFixed(1)} MB';
    } else if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '$bytes B';
    }
  }

  String _formatSpeed(double bytesPerSecond) {
    if (bytesPerSecond >= 1048576) {
      return '${(bytesPerSecond / 1048576).toStringAsFixed(1)} MB/s';
    } else if (bytesPerSecond >= 1024) {
      return '${(bytesPerSecond / 1024).toStringAsFixed(1)} KB/s';
    } else {
      return '${bytesPerSecond.toStringAsFixed(0)} B/s';
    }
  }

  String _formatTimeRemaining(int seconds) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final secs = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }
}