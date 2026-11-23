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

  Future<void> saveSession({
    required String accessJwt,
    required String refreshJwt,
    required String did,
    required String handle,
    String? email,
    String? pdsUrl,
  }) async {
    await Future.wait([
      _storage.write(key: keyAccessJwt, value: accessJwt),
      _storage.write(key: keyRefreshJwt, value: refreshJwt),
      _storage.write(key: keyDid, value: did),
      _storage.write(key: keyHandle, value: handle),
      if (email != null) _storage.write(key: keyEmail, value: email),
      if (pdsUrl != null) _storage.write(key: keyPdsUrl, value: pdsUrl),
    ]);
  }

  Future<String?> getAccessJwt() => _storage.read(key: keyAccessJwt);
  Future<String?> getRefreshJwt() => _storage.read(key: keyRefreshJwt);
  Future<String?> getDid() => _storage.read(key: keyDid);
  Future<String?> getHandle() => _storage.read(key: keyHandle);
  Future<String?> getEmail() => _storage.read(key: keyEmail);
  Future<String?> getPdsUrl() => _storage.read(key: keyPdsUrl);

  Future<bool> hasValidSession() async {
    final token = await getAccessJwt();
    final did = await getDid();
    return token != null && token.isNotEmpty && did != null && did.isNotEmpty;
  }

  Future<void> clearSession() async {
    await Future.wait([
      _storage.delete(key: keyAccessJwt),
      _storage.delete(key: keyRefreshJwt),
      _storage.delete(key: keyDid),
      _storage.delete(key: keyHandle),
      _storage.delete(key: keyEmail),
      _storage.delete(key: keyPdsUrl),
    ]);
  }
}
