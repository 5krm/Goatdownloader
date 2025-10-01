import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../domain/entities/video.dart';
import '../common/loading_widget.dart';

enum VideoCardType {
  list,
  grid,
  compact,
  detailed,
}

class VideoCard extends StatelessWidget {
  final Video video;
  final VideoCardType type;
  final VoidCallback? onTap;
  final VoidCallback? onDownload;
  final VoidCallback? onShare;
  final VoidCallback? onFavorite;
  final VoidCallback? onMoreOptions;
  final bool showDownloadButton;
  final bool showShareButton;
  final bool showFavoriteButton;
  final bool showMoreOptions;
  final bool isFavorite;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;

  const VideoCard({
    Key? key,
    required this.video,
    this.type = VideoCardType.list,
    this.onTap,
    this.onDownload,
    this.onShare,
    this.onFavorite,
    this.onMoreOptions,
    this.showDownloadButton = true,
    this.showShareButton = true,
    this.showFavoriteButton = true,
    this.showMoreOptions = true,
    this.isFavorite = false,
    this.margin,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case VideoCardType.list:
        return _buildListCard(context);
      case VideoCardType.grid:
        return _buildGridCard(context);
      case VideoCardType.compact:
        return _buildCompactCard(context);
      case VideoCardType.detailed:
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              _buildThumbnail(context, width: 120, height: 90),
              const SizedBox(width: 12),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      video.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // Channel
                    if (video.channelName.isNotEmpty) ...[
                      Text(
                        video.channelName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                    ],
                    
                    // Metadata
                    _buildMetadata(context),
                    const SizedBox(height: 8),
                    
                    // Actions
                    _buildActions(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridCard(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: margin ?? const EdgeInsets.all(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            _buildThumbnail(context, aspectRatio: 16 / 9),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    video.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  
                  // Channel
                  if (video.channelName.isNotEmpty) ...[
                    Text(
                      video.channelName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                  ],
                  
                  // Metadata
                  _buildMetadata(context, compact: true),
                  const SizedBox(height: 8),
                  
                  // Actions
                  _buildActions(context, compact: true),
                ],
              ),
            ),
          ],
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
              _buildThumbnail(context, width: 80, height: 60),
              const SizedBox(width: 12),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      video.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    
                    // Channel and duration
                    Row(
                      children: [
                        if (video.channelName.isNotEmpty) ...[
                          Expanded(
                            child: Text(
                              video.channelName,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                        if (video.duration > 0) ...[
                          Text(
                            _formatDuration(video.duration),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              
              // Download button
              if (showDownloadButton && onDownload != null)
                IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: onDownload,
                  iconSize: 20,
                ),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            _buildThumbnail(context, aspectRatio: 16 / 9),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    video.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  // Channel info
                  if (video.channelName.isNotEmpty) ...[
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: video.channelThumbnail.isNotEmpty
                              ? CachedNetworkImageProvider(video.channelThumbnail)
                              : null,
                          child: video.channelThumbnail.isEmpty
                              ? Text(
                                  video.channelName.isNotEmpty
                                      ? video.channelName[0].toUpperCase()
                                      : '?',
                                  style: theme.textTheme.bodySmall,
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                video.channelName,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (video.subscriberCount > 0)
                                Text(
                                  '${_formatNumber(video.subscriberCount)} subscribers',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  
                  // Description
                  if (video.description.isNotEmpty) ...[
                    Text(
                      video.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                  ],
                  
                  // Metadata
                  _buildMetadata(context),
                  const SizedBox(height: 16),
                  
                  // Actions
                  _buildActions(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(
    BuildContext context, {
    double? width,
    double? height,
    double? aspectRatio,
  }) {
    Widget thumbnail = ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: video.thumbnail,
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
            size: 32,
            color: Colors.grey,
          ),
        ),
      ),
    );

    if (aspectRatio != null) {
      thumbnail = AspectRatio(
        aspectRatio: aspectRatio,
        child: thumbnail,
      );
    }

    return Stack(
      children: [
        thumbnail,
        
        // Duration overlay
        if (video.duration > 0)
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _formatDuration(video.duration),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        
        // Quality badge
        if (video.quality.isNotEmpty)
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                video.quality,
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

  Widget _buildMetadata(BuildContext context, {bool compact = false}) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurface.withOpacity(0.7),
    );

    List<Widget> metadata = [];

    // Views
    if (video.viewCount > 0) {
      metadata.add(
        Text(
          '${_formatNumber(video.viewCount)} views',
          style: textStyle,
        ),
      );
    }

    // Upload date
    if (video.uploadDate.isNotEmpty) {
      metadata.add(
        Text(
          video.uploadDate,
          style: textStyle,
        ),
      );
    }

    // Duration (for compact mode)
    if (compact && video.duration > 0) {
      metadata.add(
        Text(
          _formatDuration(video.duration),
          style: textStyle,
        ),
      );
    }

    // Platform
    if (video.platform.isNotEmpty) {
      metadata.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            video.platform.toUpperCase(),
            style: textStyle?.copyWith(
              color: theme.colorScheme.primary,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    if (metadata.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: metadata,
    );
  }

  Widget _buildActions(BuildContext context, {bool compact = false}) {
    List<Widget> actions = [];

    if (compact) {
      // Compact actions - only essential buttons
      if (showDownloadButton && onDownload != null) {
        actions.add(
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: onDownload,
            iconSize: 20,
            tooltip: 'Download',
          ),
        );
      }

      if (showMoreOptions && onMoreOptions != null) {
        actions.add(
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: onMoreOptions,
            iconSize: 20,
            tooltip: 'More options',
          ),
        );
      }
    } else {
      // Full actions
      if (showDownloadButton && onDownload != null) {
        actions.add(
          OutlinedButton.icon(
            onPressed: onDownload,
            icon: const Icon(Icons.download, size: 18),
            label: const Text('Download'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        );
      }

      if (showShareButton && onShare != null) {
        actions.add(
          TextButton.icon(
            onPressed: onShare,
            icon: const Icon(Icons.share, size: 18),
            label: const Text('Share'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        );
      }

      if (showFavoriteButton && onFavorite != null) {
        actions.add(
          TextButton.icon(
            onPressed: onFavorite,
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              size: 18,
              color: isFavorite ? Colors.red : null,
            ),
            label: Text(isFavorite ? 'Favorited' : 'Favorite'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        );
      }

      if (showMoreOptions && onMoreOptions != null) {
        actions.add(
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: onMoreOptions,
            tooltip: 'More options',
          ),
        );
      }
    }

    if (actions.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: actions,
    );
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final secs = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(1)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }
}