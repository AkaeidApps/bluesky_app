import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:bluesky_app/data/models/user_model.dart';
import 'package:bluesky_app/features/authentication/services/auth_service.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository({AuthService? authService})
    : _authService = authService ?? AuthService();

  Stream<User?> get authStateChanges => _authService.authStateChanges;

  User? get currentFirebaseUser => _authService.currentFirebaseUser;

  bool get isEmailVerified => _authService.isEmailVerified;

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    return _authService.signIn(identifier: email, password: password);
  }

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String displayName,
    required String handle,
  }) async {
    return _authService.signUp(
      email: email,
      password: password,
      displayName: displayName,
      username: handle,
    );
  }

  Future<bool> isHandleAvailable(String handle) async {
    return _authService.isUsernameAvailable(handle);
  }

  Future<void> sendPasswordReset(String email) async {
    await _authService.sendPasswordReset(email);
  }

  Future<void> sendEmailVerification() async {
    await _authService.sendEmailVerification();
  }

  Future<bool> checkEmailVerification() async {
    return _authService.reloadAndCheckEmailVerification();
  }

  Future<String?> uploadProfilePhoto(File imageFile, String uid) async {
    return _authService.uploadProfilePhoto(imageFile, uid);
  }

  Future<UserModel?> getUserProfile(String uid) async {
    return _authService.getUserProfile(uid);
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<void> deleteAccount() async {
    await _authService.deleteAccount();
  }
}
