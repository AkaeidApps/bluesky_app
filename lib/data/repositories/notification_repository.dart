import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bluesky_app/core/services/firebase_service.dart';
import 'package:bluesky_app/data/models/notification_model.dart';
import 'package:bluesky_app/data/providers/mock_data_provider.dart';

class NotificationRepository {
  final FirebaseFirestore? _firestore = FirebaseService.isInitialized
      ? FirebaseFirestore.instance
      : null;

  Stream<List<NotificationModel>> getNotificationsStream(String userId) {
    if (_firestore != null) {
      return _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => NotificationModel.fromFirestore(doc))
                .toList(),
          );
    }
    return Stream.value(MockDataProvider.sampleNotifications);
  }

  Future<void> markAllAsRead(String userId) async {
    if (_firestore != null) {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    }
  }
}
