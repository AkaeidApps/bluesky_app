import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bluesky_app/core/services/firebase_service.dart';
import 'package:bluesky_app/data/models/feed_model.dart';
import 'package:bluesky_app/data/providers/mock_data_provider.dart';

class FeedRepository {
  final FirebaseFirestore? _firestore = FirebaseService.isInitialized
      ? FirebaseFirestore.instance
      : null;

  Future<List<FeedModel>> getFeeds() async {
    if (_firestore != null) {
      final snapshot = await _firestore
          .collection('feeds')
          .orderBy('likesCount', descending: true)
          .get();
      return snapshot.docs.map((doc) => FeedModel.fromFirestore(doc)).toList();
    }
    return MockDataProvider.sampleFeeds;
  }
}
