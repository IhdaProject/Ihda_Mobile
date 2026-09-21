enum FeedCategory { community, hadith, dua, verse, notificationDaily, notificationRecommended }

class FeedItem {
  final String id;
  final FeedCategory category;
  final String authorName;
  final String? title;
  final String body;
  final String timeLabel;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final bool unread;

  const FeedItem({
    required this.id,
    required this.category,
    required this.authorName,
    this.title,
    required this.body,
    required this.timeLabel,
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.unread = false,
  });
}
