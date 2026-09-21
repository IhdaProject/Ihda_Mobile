import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/entities/feed_item.dart';

/// Shared card used for Community posts, Hadith/Dua entries, and (in a
/// compact variant) notifications. Keeping one widget avoids duplicating
/// the avatar/title/body/engagement-row layout across three screens.
class PostCard extends StatelessWidget {
  final FeedItem item;
  final bool compact;

  const PostCard({super.key, required this.item, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: compact ? 16 : 18,
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                child: Icon(
                  compact ? Icons.notifications_none_rounded : Icons.person_rounded,
                  size: compact ? 16 : 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.authorName,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(item.timeLabel, style: Theme.of(context).textTheme.labelMedium),
                  ],
                ),
              ),
              if (item.unread)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          if (item.title != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              item.title!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
          const SizedBox(height: AppSpacing.xs),
          Text(
            item.body,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: compact ? 2 : null,
          ),
          if (!compact) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                _EngagementIcon(icon: Icons.star_border_rounded, count: item.likeCount),
                const SizedBox(width: AppSpacing.md),
                _EngagementIcon(icon: Icons.mode_comment_outlined, count: item.commentCount),
                const Spacer(),
                _EngagementIcon(icon: Icons.share_outlined, count: item.shareCount),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _EngagementIcon extends StatelessWidget {
  final IconData icon;
  final int count;

  const _EngagementIcon({required this.icon, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text('$count', style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}
