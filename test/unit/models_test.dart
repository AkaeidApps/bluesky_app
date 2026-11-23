import 'package:flutter_test/flutter_test.dart';
import 'package:bluesky_app/data/models/user_model.dart';
import 'package:bluesky_app/data/models/post_model.dart';

void main() {
  group('Data Models Unit Tests', () {
    test('UserModel serialization, getters and copyWith', () {
      final user = UserModel(
        id: 'u123',
        email: 'test@aura.social',
        displayName: 'Test User',
        handle: 'testuser',
        createdAt: DateTime(2025, 1, 1),
        followersCount: 50,
        emailVerified: true,
        isPrivate: false,
      );

      expect(user.uid, 'u123');
      expect(user.username, 'testuser');
      expect(user.emailVerified, true);
      expect(user.isPrivate, false);

      final map = user.toMap();
      expect(map['uid'], 'u123');
      expect(map['username'], 'testuser');
      expect(map['displayName'], 'Test User');
      expect(map['emailVerified'], true);
      expect(map['isPrivate'], false);

      final deserialized = UserModel.fromMap(map, docId: 'u123');
      expect(deserialized.uid, 'u123');
      expect(deserialized.username, 'testuser');
      expect(deserialized.emailVerified, true);

      final updated = user.copyWith(followersCount: 51);
      expect(updated.followersCount, 51);
      expect(updated.displayName, 'Test User');
    });

    test('PostModel serialization and facets conversion', () {
      final post = PostModel(
        id: 'p123',
        authorId: 'u123',
        authorDisplayName: 'Test User',
        authorHandle: 'testuser',
        content: 'Hello #flutter world',
        createdAt: DateTime(2025, 1, 1),
        facets: [
          const PostFacet(type: 'tag', value: 'flutter', start: 6, end: 14),
        ],
      );

      final map = post.toMap();
      expect(map['content'], 'Hello #flutter world');
      expect((map['facets'] as List).length, 1);

      final deserialized = PostModel.fromMap(map, docId: 'p123');
      expect(deserialized.id, 'p123');
      expect(deserialized.facets.first.value, 'flutter');
    });
  });
}
