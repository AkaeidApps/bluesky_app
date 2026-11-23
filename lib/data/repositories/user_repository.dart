import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bluesky_app/core/services/firebase_service.dart';
import 'package:bluesky_app/data/models/user_model.dart';
import 'package:bluesky_app/data/providers/mock_data_provider.dart';

class UserRepository {
  final FirebaseFirestore? _firestore = FirebaseService.isInitialized
      ? FirebaseFirestore.instance
      : null;

  Future<UserModel?> getUser(String uid) async {
    if (_firestore != null) {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    }
    if (uid == MockDataProvider.currentUser.id) {
      return MockDataProvider.currentUser;
    }
    return MockDataProvider.sampleUsers.firstWhere(
      (u) => u.id == uid,
      orElse: () => MockDataProvider.currentUser,
    );
  }

  Future<void> updateUserProfile(UserModel user) async {
    if (_firestore != null) {
      await _firestore.collection('users').doc(user.id).update(user.toMap());
    }
  }

  Future<void> followUser({
    required String currentUid,
    required String targetUid,
  }) async {
    if (_firestore != null) {
      final batch = _firestore.batch();
      // users/{currentUid}/following/{targetUid}
      final followingRef = _firestore
          .collection('users')
          .doc(currentUid)
          .collection('following')
          .doc(targetUid);
      batch.set(followingRef, {'timestamp': FieldValue.serverTimestamp()});

      // users/{targetUid}/followers/{currentUid}
      final followerRef = _firestore
          .collection('users')
          .doc(targetUid)
          .collection('followers')
          .doc(currentUid);
      batch.set(followerRef, {'timestamp': FieldValue.serverTimestamp()});

      // Increment counters
      batch.update(_firestore.collection('users').doc(currentUid), {
        'followingCount': FieldValue.increment(1),
      });
      batch.update(_firestore.collection('users').doc(targetUid), {
        'followersCount': FieldValue.increment(1),
      });

      await batch.commit();
    }
  }

  Future<void> unfollowUser({
    required String currentUid,
    required String targetUid,
  }) async {
    if (_firestore != null) {
      final batch = _firestore.batch();
      final followingRef = _firestore
          .collection('users')
          .doc(currentUid)
          .collection('following')
          .doc(targetUid);
      batch.delete(followingRef);

      final followerRef = _firestore
          .collection('users')
          .doc(targetUid)
          .collection('followers')
          .doc(currentUid);
      batch.delete(followerRef);

      // Decrement counters
      batch.update(_firestore.collection('users').doc(currentUid), {
        'followingCount': FieldValue.increment(-1),
      });
      batch.update(_firestore.collection('users').doc(targetUid), {
        'followersCount': FieldValue.increment(-1),
      });

      await batch.commit();
    }
  }

  Future<void> blockUser({
    required String currentUid,
    required String targetUid,
  }) async {
    if (_firestore != null) {
      await _firestore
          .collection('users')
          .doc(currentUid)
          .collection('blocks')
          .doc(targetUid)
          .set({'blockedAt': FieldValue.serverTimestamp()});
    }
  }

  Future<void> muteUser({
    required String currentUid,
    required String targetUid,
  }) async {
    if (_firestore != null) {
      await _firestore
          .collection('users')
          .doc(currentUid)
          .collection('mutes')
          .doc(targetUid)
          .set({'mutedAt': FieldValue.serverTimestamp()});
    }
  }

  Future<List<UserModel>> searchUsers(String query) async {
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) return [];

    if (_firestore != null) {
      final snapshot = await _firestore
          .collection('users')
          .where('handle', isGreaterThanOrEqualTo: clean)
          .where('handle', isLessThanOrEqualTo: '$clean\uf8ff')
          .limit(20)
          .get();

      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    }

    return MockDataProvider.sampleUsers
        .where(
          (u) =>
              u.displayName.toLowerCase().contains(clean) ||
              u.handle.toLowerCase().contains(clean),
        )
        .toList();
  }
}
