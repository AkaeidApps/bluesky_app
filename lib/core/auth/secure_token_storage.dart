import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureTokenStorage {
  final FlutterSecureStorage _storage;

  SecureTokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
            );

  static const String keyAccessJwt = 'bsky_access_jwt';
  static const String keyRefreshJwt = 'bsky_refresh_jwt';
  static const String keyDid = 'bsky_user_did';
  static const String keyHandle = 'bsky_user_handle';
  static const String keyPdsUrl = 'bsky_pds_url';
  static const String keyEmail = 'bsky_user_email';

  // OAuth PKCE keys
  static const String keyCodeVerifier = 'oauth_code_verifier';
  static const String keyOAuthState = 'oauth_state';

  Future<void> saveSession({
    required String accessJwt,
    required String refreshJwt,
    required String did,
    required String handle,
    String? email,
    String? pdsUrl,
  }) async {
    try {
      await Future.wait([
        _storage.write(key: keyAccessJwt, value: accessJwt),
        _storage.write(key: keyRefreshJwt, value: refreshJwt),
        _storage.write(key: keyDid, value: did),
        _storage.write(key: keyHandle, value: handle),
        if (email != null) _storage.write(key: keyEmail, value: email),
        if (pdsUrl != null) _storage.write(key: keyPdsUrl, value: pdsUrl),
      ]);
    } catch (_) {}
  }

  Future<String?> getAccessJwt() async {
    try {
      return await _storage.read(key: keyAccessJwt);
    } catch (_) {
      return null;
    }
  }

  Future<String?> getRefreshJwt() async {
    try {
      return await _storage.read(key: keyRefreshJwt);
    } catch (_) {
      return null;
    }
  }

  Future<String?> getDid() async {
    try {
      return await _storage.read(key: keyDid);
    } catch (_) {
      return null;
    }
  }

  Future<String?> getHandle() async {
    try {
      return await _storage.read(key: keyHandle);
    } catch (_) {
      return null;
    }
  }

  Future<String?> getEmail() async {
    try {
      return await _storage.read(key: keyEmail);
    } catch (_) {
      return null;
    }
  }

  Future<String?> getPdsUrl() async {
    try {
      return await _storage.read(key: keyPdsUrl);
    } catch (_) {
      return null;
    }
  }

  Future<bool> hasValidSession() async {
    try {
      final token = await getAccessJwt();
      final did = await getDid();
      return token != null && token.isNotEmpty && did != null && did.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> clearSession() async {
    try {
      await Future.wait([
        _storage.delete(key: keyAccessJwt),
        _storage.delete(key: keyRefreshJwt),
        _storage.delete(key: keyDid),
        _storage.delete(key: keyHandle),
        _storage.delete(key: keyEmail),
        _storage.delete(key: keyPdsUrl),
        _storage.delete(key: keyCodeVerifier),
        _storage.delete(key: keyOAuthState),
      ]);
    } catch (_) {}
  }

  // OAuth PKCE methods
  Future<void> saveCodeVerifier(String codeVerifier) async {
    try {
      await _storage.write(key: keyCodeVerifier, value: codeVerifier);
    } catch (_) {}
  }

  Future<String?> getCodeVerifier() async {
    try {
      return await _storage.read(key: keyCodeVerifier);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveOAuthState(String state) async {
    try {
      await _storage.write(key: keyOAuthState, value: state);
    } catch (_) {}
  }

  Future<String?> getOAuthState() async {
    try {
      return await _storage.read(key: keyOAuthState);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearOAuthState() async {
    try {
      await Future.wait([
        _storage.delete(key: keyCodeVerifier),
        _storage.delete(key: keyOAuthState),
      ]);
    } catch (_) {}
  }
}
