import 'dart:io';
import 'package:bluesky_app/core/auth/atproto_auth_service.dart';
import 'package:bluesky_app/core/auth/secure_token_storage.dart';
import 'package:bluesky_app/data/models/user_model.dart';

class AuthRepository {
  final AtprotoAuthService _authService;
  final SecureTokenStorage _tokenStorage;

  AuthRepository({
    AtprotoAuthService? authService,
    SecureTokenStorage? tokenStorage,
  })  : _authService = authService ?? AtprotoAuthService(tokenStorage: tokenStorage),
        _tokenStorage = tokenStorage ?? SecureTokenStorage();

  Stream<bool> get authStateChanges async* {
    yield await _authService.hasValidSession();
  }

  UserModel? get currentUser {
    return null;
  }

  // Compatibility getter for legacy controllers expecting Firebase user
  DummyFirebaseUser? get currentFirebaseUser => DummyFirebaseUser();

  bool get isEmailVerified => true;

  Future<UserModel> signInWithOAuth({
    required Function(String authUrl) onAuthUrlReady,
    required Function(String error) onError,
  }) async {
    await _authService.startOAuthFlow(
      onAuthUrlReady: onAuthUrlReady,
      onError: onError,
    );
    return UserModel(
      id: '',
      displayName: '',
      handle: '',
      createdAt: DateTime.now(),
    );
  }

  Future<void> handleOAuthCallback(Uri callbackUri) async {
    await _authService.handleCallback(callbackUri);
  }

  Future<UserModel> getCurrentUserProfile() async {
    final user = await _authService.getCurrentUser();
    return user ?? UserModel(
      id: '',
      displayName: '',
      handle: '',
      createdAt: DateTime.now(),
    );
  }

  Future<bool> hasValidSession() async {
    return _authService.hasValidSession();
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<void> refreshSession() async {
    await _authService.refreshAccessToken();
  }

  Future<bool> isHandleAvailable(String handle) async {
    try {
      final resolved = await _authService.apiService.resolveHandle(handle: handle);
      return resolved.isEmpty;
    } catch (e) {
      return true;
    }
  }

  Future<String?> uploadProfilePhoto(File imageFile, String uid) async {
    return null;
  }

  Future<UserModel?> getUserProfile(String uid) async {
    try {
      return await _authService.apiService.getProfile(actor: uid);
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteAccount() async {
    await _authService.signOut();
  }
}

class DummyFirebaseUser {
  final String uid = 'user_current';
}
