import 'package:bluesky_app/core/network/atproto_api_service.dart';
import 'package:bluesky_app/data/models/feed_model.dart';
import 'package:bluesky_app/data/providers/mock_data_provider.dart';

class FeedRepository {
  final AtprotoApiService _apiService;

  FeedRepository({AtprotoApiService? apiService})
      : _apiService = apiService ?? AtprotoApiService();

  Future<List<FeedModel>> getFeeds() async {
    try {
      final suggestedFeeds = await _apiService.getSuggestedFeeds();
      final feedGenerators = await _apiService.getFeedGenerators();
      final allFeeds = [...suggestedFeeds, ...feedGenerators];

      final uniqueFeeds = <String, FeedModel>{};
      for (final feed in allFeeds) {
        uniqueFeeds[feed.id] = feed;
      }

      final feeds = uniqueFeeds.values.toList();
      feeds.sort((a, b) => b.likesCount.compareTo(a.likesCount));
      return feeds;
    } catch (e) {
      return MockDataProvider.sampleFeeds;
    }
  }

  Future<List<FeedModel>> getSavedFeeds() async {
    try {
      return await _apiService.getFeedGenerators();
    } catch (e) {
      return MockDataProvider.sampleFeeds.where((f) => f.isSaved).toList();
    }
  }
}