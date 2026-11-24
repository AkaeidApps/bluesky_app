import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:bluesky_app/core/auth/atproto_oauth_service.dart';
import 'package:bluesky_app/core/auth/secure_token_storage.dart';
import 'package:bluesky_app/core/network/atproto_api_service.dart';
import 'package:bluesky_app/data/models/user_model.dart';

class AtprotoAuthService {
  final SecureTokenStorage _tokenStorage;
  final AtprotoApiService _apiService;

  AtprotoAuthService({
    SecureTokenStorage? tokenStorage,
    AtprotoApiService? apiService,
  })  : _tokenStorage = tokenStorage ?? SecureTokenStorage(),
        _apiService = apiService ?? AtprotoApiService(tokenStorage: tokenStorage);

  AtprotoApiService get apiService => _apiService;

  static const String _blueskyAuthUrl = 'https://bsky.app/oauth/authorize';
  static const String _clientId = 'aura-social';
  static const String _redirectUri = 'aura://oauth-callback';

  Future<bool> hasValidSession() async {
    return _tokenStorage.hasValidSession();
  }

  Future<UserModel?> getCurrentUser() async {
    final hasSession = await hasValidSession();
    if (!hasSession) return null;

    final did = await _tokenStorage.getDid();
    if (did == null || did.isEmpty) return null;

    try {
      return await _apiService.getProfile(actor: did);
    } catch (e) {
      if (kDebugMode) {
        print('[AtprotoAuthService] Failed to get current user: $e');
      }
      return null;
    }
  }

  String generateAuthUrl({
    required String codeVerifier,
    required String state,
    String? pdspUrl,
  }) {
    final codeChallenge = AtprotoOAuthService.generateCodeChallenge(codeVerifier);

    final params = {
      'client_id': _clientId,
      'redirect_uri': _redirectUri,
      'scope': 'atproto transition:generic',
      'response_type': 'code',
      'code_challenge': codeChallenge,
      'code_challenge_method': 'S256',
      'state': state,
    };

    final queryString = params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return '$_blueskyAuthUrl?$queryString';
  }

  Future<void> startOAuthFlow({
    required Function(String authUrl) onAuthUrlReady,
    required Function(String error) onError,
  }) async {
    try {
      final codeVerifier = AtprotoOAuthService.generateCodeVerifier();
      final state = AtprotoOAuthService.generateOAuthState();

      await _tokenStorage.saveSession(
        accessJwt: '',
        refreshJwt: '',
        did: '',
        handle: '',
        pdsUrl: 'https://bsky.social',
      );

      final authUrl = generateAuthUrl(
        codeVerifier: codeVerifier,
        state: state,
      );

      await _tokenStorage.saveCodeVerifier(codeVerifier);
      await _tokenStorage.saveOAuthState(state);

      onAuthUrlReady(authUrl);
    } catch (e) {
      onError('Failed to start OAuth flow: $e');
    }
  }

  Future<void> handleCallback(Uri callbackUri) async {
    final queryParams = callbackUri.queryParameters;
    final code = queryParams['code'];
    final state = queryParams['state'];
    final error = queryParams['error'];
    final errorDescription = queryParams['error_description'];

    if (error != null) {
      throw Exception('OAuth error: $error - $errorDescription');
    }

    if (code == null) {
      throw Exception('No authorization code received');
    }

    final storedState = await _tokenStorage.getOAuthState();
    if (storedState != state) {
      throw Exception('Invalid OAuth state');
    }

    final codeVerifier = await _tokenStorage.getCodeVerifier();
    if (codeVerifier == null || codeVerifier.isEmpty) {
      throw Exception('Missing code verifier');
    }

    await exchangeCodeForTokens(code: code, codeVerifier: codeVerifier);

    await _tokenStorage.clearOAuthState();
  }

  Future<void> exchangeCodeForTokens({
    required String code,
    required String codeVerifier,
  }) async {
    final response = await _apiService.dio.post(
      'https://bsky.social/oauth/token',
      data: {
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': _redirectUri,
        'client_id': _clientId,
        'code_verifier': codeVerifier,
      },
      options: Options(
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      ),
    );

    final data = response.data;
    final accessJwt = data['access_token'] as String?;
    final refreshJwt = data['refresh_token'] as String?;
    final did = data['sub'] as String?;

    if (accessJwt == null || refreshJwt == null || did == null) {
      throw Exception('Invalid token response');
    }

    final profile = await _apiService.getProfile(actor: did);

    await _tokenStorage.saveSession(
      accessJwt: accessJwt,
      refreshJwt: refreshJwt,
      did: did,
      handle: profile.handle,
      email: profile.email,
      pdsUrl: await _tokenStorage.getPdsUrl() ?? 'https://bsky.social',
    );
  }

  Future<bool> refreshAccessToken() async {
    try {
      final refreshJwt = await _tokenStorage.getRefreshJwt();
      final pdsUrl = await _tokenStorage.getPdsUrl() ?? 'https://bsky.social';

      if (refreshJwt == null || refreshJwt.isEmpty) {
        return false;
      }

      final response = await _apiService.dio.post(
        '$pdsUrl/oauth/token',
        data: {
          'grant_type': 'refresh_token',
          'refresh_token': refreshJwt,
          'client_id': _clientId,
        },
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
      );

      final data = response.data;
      final accessJwt = data['access_token'] as String?;
      final newRefreshJwt = data['refresh_token'] as String?;

      if (accessJwt == null) {
        return false;
      }

      final did = await _tokenStorage.getDid();
      final handle = await _tokenStorage.getHandle();

      await _tokenStorage.saveSession(
        accessJwt: accessJwt,
        refreshJwt: newRefreshJwt ?? refreshJwt,
        did: did ?? '',
        handle: handle ?? '',
        pdsUrl: pdsUrl,
      );

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('[AtprotoAuthService] Failed to refresh token: $e');
      }
      return false;
    }
  }

  Future<void> signOut() async {
    await _tokenStorage.clearSession();
  }

  Future<void> launchAuthUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not launch OAuth URL');
    }
  }
}