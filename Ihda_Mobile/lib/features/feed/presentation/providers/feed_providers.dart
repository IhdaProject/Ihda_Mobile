import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/feed_data_source.dart';
import '../../data/datasources/mock_feed_data_source.dart';
import '../../domain/entities/feed_item.dart';

final feedDataSourceProvider = Provider<FeedDataSource>((ref) => MockFeedDataSource());

final feedByCategoryProvider =
    FutureProvider.autoDispose.family<List<FeedItem>, FeedCategory>((ref, category) {
  return ref.watch(feedDataSourceProvider).getFeed(category);
});
