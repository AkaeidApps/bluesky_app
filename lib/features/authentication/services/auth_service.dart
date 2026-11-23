import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:bluesky_app/core/services/firebase_service.dart';
import 'package:bluesky_app/data/models/user_model.dart';
import 'package:bluesky_app/data/providers/mock_data_provider.dart';

class AuthService {
  final FirebaseAuth? _auth = FirebaseService.isInitialized
      ? FirebaseAuth.instance
      : null;
  final FirebaseFirestore? _firestore = FirebaseService.isInitialized
      ? FirebaseFirestore.instance
      : null;
  final FirebaseStorage? _storage = FirebaseService.isInitialized
      ? FirebaseStorage.instance
      : null;

  Stream<User?> get authStateChanges =>
      _auth != null ? _auth.authStateChanges() : Stream.value(null);

  User? get currentFirebaseUser => _auth?.currentUser;

  bool get isEmailVerified => _auth?.currentUser?.emailVerified ?? false;

  /// Normalizes usernames to lowercase without spaces or @ symbol
  String normalizeUsername(String username) {
    return username.replaceAll('@', '').trim().toLowerCase();
  }

  /// Checks if a username is available in the 'usernames' collection
  Future<bool> isUsernameAvailable(String username) async {
    final clean = normalizeUsername(username);
    if (clean.length < 3 || clean.length > 30) return false;

    if (_firestore != null) {
      final doc = await _firestore.collection('usernames').doc(clean).get();
      return !doc.exists;
    }

    return !['admin', 'aura', 'official', 'bluesky'].contains(clean);
  }

  /// Sign In with either email or handle/username
  Future<UserModel> signIn({
    required String identifier,
    required String password,
  }) async {
    final cleanIdentifier = identifier.trim();

    if (_auth != null && _firestore != null) {
      String emailToUse = cleanIdentifier;

      // If identifier is not an email, resolve username to email
      if (!cleanIdentifier.contains('@')) {
        final cleanUsername = normalizeUsername(cleanIdentifier);
        final usernameDoc = await _firestore
            .collection('usernames')
            .doc(cleanUsername)
            .get();
        if (!usernameDoc.exists) {
          throw FirebaseAuthException(
            code: 'user-not-found',
            message: 'No account found for username @$cleanUsername.',
          );
        }

        final uid = usernameDoc.data()?['uid'] as String?;
        if (uid == null) {
          throw FirebaseAuthException(code: 'user-not-found');
        }

        final userDoc = await _firestore.collection('users').doc(uid).get();
        final userEmail = userDoc.data()?['email'] as String?;
        if (userEmail == null || userEmail.isEmpty) {
          throw FirebaseAuthException(code: 'user-not-found');
        }

        emailToUse = userEmail;
      }

      final credential = await _auth.signInWithEmailAndPassword(
        email: emailToUse,
        password: password,
      );

      final doc = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      } else {
        return UserModel(
          id: credential.user!.uid,
          email: credential.user!.email ?? emailToUse,
          displayName: credential.user!.displayName ?? 'User',
          handle: normalizeUsername(
            credential.user!.email?.split('@').first ?? 'user',
          ),
          createdAt: DateTime.now(),
          emailVerified: credential.user!.emailVerified,
        );
      }
    } else {
      // Mock / Offline fallback
      await Future.delayed(const Duration(milliseconds: 500));
      return MockDataProvider.currentUser;
    }
  }

  /// Real registration with atomic username reservation and profile creation
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String displayName,
    required String username,
  }) async {
    final cleanUsername = normalizeUsername(username);
    final cleanEmail = email.trim();
    final cleanName = displayName.trim();

    if (_auth != null && _firestore != null) {
      // 1. Pre-check username availability
      final usernameRef = _firestore.collection('usernames').doc(cleanUsername);
      final preCheck = await usernameRef.get();
      if (preCheck.exists) {
        throw FirebaseAuthException(
          code: 'username-already-in-use',
          message:
              'Username @$cleanUsername is already taken. Please choose another.',
        );
      }

      // 2. Create Firebase Authentication account
      final credential = await _auth.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );

      final uid = credential.user!.uid;

      // 3. Atomically reserve username and create user document using a Firestore Transaction
      try {
        await _firestore.runTransaction((transaction) async {
          final usernameSnapshot = await transaction.get(usernameRef);
          if (usernameSnapshot.exists) {
            throw FirebaseAuthException(
              code: 'username-already-in-use',
              message:
                  'Username @$cleanUsername was just taken. Please choose another.',
            );
          }

          // Reserve username in usernames/{username}
          transaction.set(usernameRef, {
            'uid': uid,
            'reservedAt': FieldValue.serverTimestamp(),
          });

          // Create users/{uid} document
          final userRef = _firestore.collection('users').doc(uid);
          final userProfile = {
            'uid': uid,
            'id': uid,
            'displayName': cleanName,
            'username': cleanUsername,
            'handle': cleanUsername,
            'email': cleanEmail,
            'photoURL': null,
            'avatarUrl': null,
            'bannerUrl': null,
            'bio': '',
            'website': null,
            'location': null,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
            'emailVerified': false,
            'followersCount': 0,
            'followingCount': 0,
            'postsCount': 0,
            'isPrivate': false,
            'isVerified': false,
          };

          transaction.set(userRef, userProfile);
        });

        // Update Auth profile display name
        await credential.user!.updateDisplayName(cleanName);

        // Send Email Verification
        try {
          await credential.user!.sendEmailVerification();
        } catch (_) {
          // Non-blocking if rate limited
        }

        return UserModel(
          id: uid,
          email: cleanEmail,
          displayName: cleanName,
          handle: cleanUsername,
          createdAt: DateTime.now(),
          emailVerified: false,
        );
      } catch (transactionError) {
        // If Firestore transaction failed after Auth creation, delete Auth account to prevent orphaned state
        await credential.user!.delete().catchError((_) {});
        rethrow;
      }
    } else {
      await Future.delayed(const Duration(milliseconds: 600));
      return UserModel(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: cleanEmail,
        displayName: cleanName,
        handle: cleanUsername,
        createdAt: DateTime.now(),
      );
    }
  }

  /// Sends email verification to the currently signed in user
  Future<void> sendEmailVerification() async {
    if (_auth != null && _auth.currentUser != null) {
      await _auth.currentUser!.sendEmailVerification();
    }
  }

  /// Reload current user to check verification status
  Future<bool> reloadAndCheckEmailVerification() async {
    if (_auth != null && _auth.currentUser != null) {
      await _auth.currentUser!.reload();
      final verified = _auth.currentUser!.emailVerified;
      if (verified && _firestore != null) {
        await _firestore.collection('users').doc(_auth.currentUser!.uid).update(
          {'emailVerified': true},
        );
      }
      return verified;
    }
    return true;
  }

  /// Send password reset link
  Future<void> sendPasswordReset(String email) async {
    if (_auth != null) {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } else {
      await Future.delayed(const Duration(milliseconds: 400));
    }
  }

  /// Profile photo upload to Firebase Storage
  Future<String?> uploadProfilePhoto(File imageFile, String uid) async {
    if (_storage != null && _firestore != null) {
      final ref = _storage.ref().child(
        'users/$uid/avatars/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      final uploadTask = await ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Update Firestore profile
      await _firestore.collection('users').doc(uid).update({
        'photoURL': downloadUrl,
        'avatarUrl': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update Firebase Auth user photoURL
      await _auth?.currentUser?.updatePhotoURL(downloadUrl);

      return downloadUrl;
    }
    return null;
  }

  /// Fetch user profile from Firestore
  Future<UserModel?> getUserProfile(String uid) async {
    if (_firestore != null) {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    }
    return MockDataProvider.currentUser;
  }

  /// Sign out
  Future<void> signOut() async {
    if (_auth != null) {
      await _auth.signOut();
    }
  }

  /// Permanently delete account and user documents
  Future<void> deleteAccount() async {
    if (_auth != null && _auth.currentUser != null) {
      final uid = _auth.currentUser!.uid;
      if (_firestore != null) {
        final userDoc = await _firestore.collection('users').doc(uid).get();
        final username = userDoc.data()?['username'] as String?;
        if (username != null) {
          await _firestore
              .collection('usernames')
              .doc(username)
              .delete()
              .catchError((_) {});
        }
        await _firestore
            .collection('users')
            .doc(uid)
            .delete()
            .catchError((_) {});
      }
      await _auth.currentUser!.delete();
    }
  }
}
