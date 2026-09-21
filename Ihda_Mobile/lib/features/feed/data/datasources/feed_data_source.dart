import '../../domain/entities/feed_item.dart';

abstract class FeedDataSource {
  Future<List<FeedItem>> getFeed(FeedCategory category);
}
