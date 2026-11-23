import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bluesky_app/core/services/firebase_service.dart';
import 'package:bluesky_app/data/models/post_model.dart';
import 'package:bluesky_app/data/models/reply_model.dart';
import 'package:bluesky_app/data/providers/mock_data_provider.dart';

class PostRepository {
  final FirebaseFirestore? _firestore = FirebaseService.isInitialized
      ? FirebaseFirestore.instance
      : null;

  Future<List<PostModel>> getPosts({
    String? feedType,
    DocumentSnapshot? lastDocument,
    int limit = 20,
  }) async {
    if (_firestore != null) {
      Query query = _firestore
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (feedType != null &&
          feedType != 'discover' &&
          feedType != 'following') {
        query = _firestore
            .collection('posts')
            .where('contentLabels', arrayContains: feedType)
            .orderBy('createdAt', descending: true)
            .limit(limit);
      }

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList();
    }

    // High quality mock data
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(MockDataProvider.samplePosts);
  }

  Future<PostModel> createPost(PostModel post) async {
    if (_firestore != null) {
      final docRef = _firestore
          .collection('posts')
          .doc(post.id.isNotEmpty ? post.id : null);
      final newPost = post.copyWith(id: docRef.id);
      await docRef.set(newPost.toMap());

      // Increment author posts count
      await _firestore.collection('users').doc(post.authorId).update({
        'postsCount': FieldValue.increment(1),
      });

      return newPost;
    }
    return post;
  }

  Future<void> likePost(String postId, String userId) async {
    if (_firestore != null) {
      final batch = _firestore.batch();
      final likeRef = _firestore
          .collection('posts')
          .doc(postId)
          .collection('likes')
          .doc(userId);
      batch.set(likeRef, {'likedAt': FieldValue.serverTimestamp()});
      batch.update(_firestore.collection('posts').doc(postId), {
        'likesCount': FieldValue.increment(1),
      });
      await batch.commit();
    }
  }

  Future<void> unlikePost(String postId, String userId) async {
    if (_firestore != null) {
      final batch = _firestore.batch();
      final likeRef = _firestore
          .collection('posts')
          .doc(postId)
          .collection('likes')
          .doc(userId);
      batch.delete(likeRef);
      batch.update(_firestore.collection('posts').doc(postId), {
        'likesCount': FieldValue.increment(-1),
      });
      await batch.commit();
    }
  }

  Future<void> repost(String postId, String userId) async {
    if (_firestore != null) {
      final batch = _firestore.batch();
      final repostRef = _firestore
          .collection('posts')
          .doc(postId)
          .collection('reposts')
          .doc(userId);
      batch.set(repostRef, {'repostedAt': FieldValue.serverTimestamp()});
      batch.update(_firestore.collection('posts').doc(postId), {
        'repostsCount': FieldValue.increment(1),
      });
      await batch.commit();
    }
  }

  Future<void> undoRepost(String postId, String userId) async {
    if (_firestore != null) {
      final batch = _firestore.batch();
      final repostRef = _firestore
          .collection('posts')
          .doc(postId)
          .collection('reposts')
          .doc(userId);
      batch.delete(repostRef);
      batch.update(_firestore.collection('posts').doc(postId), {
        'repostsCount': FieldValue.increment(-1),
      });
      await batch.commit();
    }
  }

  Future<void> bookmarkPost(String postId, String userId) async {
    if (_firestore != null) {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('bookmarks')
          .doc(postId)
          .set({'bookmarkedAt': FieldValue.serverTimestamp()});
    }
  }

  Future<void> unbookmarkPost(String postId, String userId) async {
    if (_firestore != null) {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('bookmarks')
          .doc(postId)
          .delete();
    }
  }

  Future<List<ReplyModel>> getReplies(String postId) async {
    if (_firestore != null) {
      final snapshot = await _firestore
          .collection('posts')
          .doc(postId)
          .collection('replies')
          .orderBy('createdAt', descending: false)
          .get();

      return snapshot.docs.map((doc) => ReplyModel.fromFirestore(doc)).toList();
    }

    return [
      ReplyModel(
        id: 'reply_1',
        postId: postId,
        authorId: 'user_1',
        authorDisplayName: 'Maya Lin',
        authorHandle: 'mayalin.aura.social',
        authorAvatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
        authorIsVerified: true,
        content: 'Excited to see the architecture coming together cleanly! Great work on the design tokens.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
        likesCount: 12,
      ),
      ReplyModel(
        id: 'reply_2',
        postId: postId,
        authorId: 'user_2',
        authorDisplayName: 'Alex Rivera',
        authorHandle: 'alex.aura.social',
        authorAvatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        authorIsVerified: true,
        content: 'The custom butterfly vector mark is super clean. Looking forward to testing on device.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        likesCount: 8,
      ),
    ];
  }

  Future<ReplyModel> createReply(String postId, ReplyModel reply) async {
    if (_firestore != null) {
      final docRef = _firestore
          .collection('posts')
          .doc(postId)
          .collection('replies')
          .doc();
      final newReply = reply.copyWith(id: docRef.id);
      await docRef.set(newReply.toMap());

      await _firestore.collection('posts').doc(postId).update({
        'repliesCount': FieldValue.increment(1),
      });

      return newReply;
    }
    return reply;
  }
}
