import 'package:get/get.dart';
import 'package:bluesky_app/data/models/feed_model.dart';
import 'package:bluesky_app/data/repositories/feed_repository.dart';

class FeedsController extends GetxController {
  final FeedRepository _feedRepo = Get.find<FeedRepository>();

  final feeds = <FeedModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadFeeds();
  }

  Future<void> loadFeeds() async {
    isLoading.value = true;
    try {
      final list = await _feedRepo.getFeeds();
      feeds.assignAll(list);
    } finally {
      isLoading.value = false;
    }
  }

  void toggleSaveFeed(FeedModel feed) {
    final idx = feeds.indexWhere((f) => f.id == feed.id);
    if (idx != -1) {
      feeds[idx] = feed.copyWith(isSaved: !feed.isSaved);
    }
  }
}
