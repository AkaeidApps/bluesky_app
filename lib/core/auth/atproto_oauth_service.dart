import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class AtprotoOAuthService {
  AtprotoOAuthService._();

  /// Generates a high-entropy cryptographic PKCE code_verifier (32 random bytes, base64url encoded)
  static String generateCodeVerifier() {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    return base64UrlEncode(values).replaceAll('=', '');
  }

  /// Generates PKCE code_challenge from code_verifier using SHA-256
  static String generateCodeChallenge(String verifier) {
    final bytes = utf8.encode(verifier);
    final digest = sha256.convert(bytes);
    return base64UrlEncode(digest.bytes).replaceAll('=', '');
  }

  /// Generates a random cryptographic state string for OAuth CSRF protection
  static String generateOAuthState() {
    final random = Random.secure();
    final values = List<int>.generate(24, (i) => random.nextInt(256));
    return base64UrlEncode(values).replaceAll('=', '');
  }

  /// Creates a DPoP (Demonstrating Proof-of-Possession) header payload
  static Map<String, dynamic> createDPoPClaims({
    required String htm, // HTTP Method (e.g. 'POST', 'GET')
    required String htu, // HTTP URI (without query params)
    String? nonce,       // Server nonce challenge if required
    String? ath,         // Access token hash
  }) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final random = Random.secure();
    final jti = base64UrlEncode(List<int>.generate(16, (i) => random.nextInt(256))).replaceAll('=', '');

    return {
      'jti': jti,
      'htm': htm,
      'htu': htu,
      'iat': now,
      'exp': now + 300,
      if (nonce != null) 'nonce': nonce,
      if (ath != null) 'ath': ath,
    };
  }
}
