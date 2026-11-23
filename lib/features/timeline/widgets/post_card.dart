import 'package:flutter/material.dart';
import 'package:bluesky_app/core/constants/app_colors.dart';
import 'package:bluesky_app/core/constants/app_radius.dart';
import 'package:bluesky_app/core/utils/date_formatter.dart';
import 'package:bluesky_app/core/widgets/aura_avatar.dart';
import 'package:bluesky_app/core/widgets/media_grid.dart';
import 'package:bluesky_app/core/widgets/rich_post_text.dart';
import 'package:bluesky_app/data/models/post_model.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onRepost;
  final VoidCallback? onReply;
  final VoidCallback? onBookmark;
  final VoidCallback? onShare;
  final VoidCallback? onMore;
  final VoidCallback? onProfileTap;
  final bool showThreadConnector;

  const PostCard({
    super.key,
    required this.post,
    this.onTap,
    this.onLike,
    this.onRepost,
    this.onReply,
    this.onBookmark,
    this.onShare,
    this.onMore,
    this.onProfileTap,
    this.showThreadConnector = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
              width: 0.8,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Avatar Column with Thread Line Connector
            Column(
              children: [
                AuraAvatar(
                  imageUrl: post.authorAvatarUrl,
                  fallbackName: post.authorDisplayName,
                  size: 44,
                  onTap: onProfileTap,
                ),
                if (showThreadConnector)
                  Container(
                    width: 2,
                    height: 48,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // Right Content Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row: Display Name + Verified Badge + Handle + Dot + Relative Timestamp
                  Row(
                    children: [
                      Flexible(
                        child: GestureDetector(
                          onTap: onProfileTap,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  post.authorDisplayName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.lightTextPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (post.authorIsVerified) ...[
                                const SizedBox(width: 3),
                                const Icon(
                                  Icons.verified,
                                  size: 14,
                                  color: AppColors.verifiedBadge,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '@${post.authorHandle}',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? AppColors.darkTextTertiary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '·',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.darkTextTertiary
                              : AppColors.lightTextTertiary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormatter.formatRelative(post.createdAt),
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.darkTextTertiary
                              : AppColors.lightTextTertiary,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.more_horiz, size: 18),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        color: isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.lightTextTertiary,
                        onPressed: onMore,
                      ),
                    ],
                  ),

                  // Post Text Body
                  if (post.content.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    RichPostText(text: post.content, facets: post.facets),
                  ],

                  // Media Grid (1-4 images)
                  if (post.mediaUrls.isNotEmpty)
                    MediaGrid(
                      mediaUrls: post.mediaUrls,
                      altTexts: post.altTexts,
                    ),

                  // Quote Post Embed (if quote post exists)
                  if (post.quotePost != null) ...[
                    const SizedBox(height: 8),
                    _buildQuotePostEmbed(context, post.quotePost!, isDark),
                  ],

                  const SizedBox(height: 10),

                  // Action Bar (Reply, Repost, Like, Bookmark, Share)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Reply Button
                      _buildActionItem(
                        icon: Icons.chat_bubble_outline_rounded,
                        count: post.repliesCount,
                        color: isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.lightTextSecondary,
                        activeColor: AppColors.primary,
                        isActive: false,
                        onTap: onReply,
                      ),
                      // Repost Button
                      _buildActionItem(
                        icon: Icons.repeat_rounded,
                        count: post.repostsCount,
                        color: isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.lightTextSecondary,
                        activeColor: AppColors.repost,
                        isActive: post.isReposted,
                        onTap: onRepost,
                      ),
                      // Like Button
                      _buildActionItem(
                        icon: post.isLiked
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        count: post.likesCount,
                        color: isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.lightTextSecondary,
                        activeColor: AppColors.like,
                        isActive: post.isLiked,
                        onTap: onLike,
                      ),
                      // Bookmark Button
                      _buildActionItem(
                        icon: post.isBookmarked
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        count: 0,
                        color: isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.lightTextSecondary,
                        activeColor: AppColors.bookmark,
                        isActive: post.isBookmarked,
                        onTap: onBookmark,
                      ),
                      // Share Button
                      IconButton(
                        icon: const Icon(Icons.share_outlined, size: 18),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        color: isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.lightTextSecondary,
                        onPressed: onShare,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required int count,
    required Color color,
    required Color activeColor,
    required bool isActive,
    required VoidCallback? onTap,
  }) {
    final effectiveColor = isActive ? activeColor : color;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: effectiveColor),
            if (count > 0) ...[
              const SizedBox(width: 5),
              Text(
                count > 999
                    ? '${(count / 1000).toStringAsFixed(1)}k'
                    : '$count',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: effectiveColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuotePostEmbed(
    BuildContext context,
    PostModel quote,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.8,
        ),
        borderRadius: AppRadius.radiusMd,
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AuraAvatar(
                imageUrl: quote.authorAvatarUrl,
                fallbackName: quote.authorDisplayName,
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                quote.authorDisplayName,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '@${quote.authorHandle}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            quote.content,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
