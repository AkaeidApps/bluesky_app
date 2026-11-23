import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_config.dart';
import '../auth/secure_token_storage.dart';

class DioClient {
  late final Dio dio;
  final SecureTokenStorage tokenStorage;

  DioClient({SecureTokenStorage? storage})
      : tokenStorage = storage ?? SecureTokenStorage() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.publicAppView,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(_createInterceptor());
  }

  Interceptor _createInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Check if this is an authenticated or chat request
        final isChat = options.path.contains('chat.bsky.');
        final requiresAuth = isChat ||
            options.path.contains('getTimeline') ||
            options.path.contains('app.bsky.repo.') ||
            options.path.contains('com.atproto.repo.') ||
            options.path.contains('notification.');

        final token = await tokenStorage.getAccessJwt();
        final pdsUrl = await tokenStorage.getPdsUrl();

        // If PDS URL is available and request is authenticated or a write operation, use user's PDS
        if (pdsUrl != null && pdsUrl.isNotEmpty && (requiresAuth || options.method != 'GET')) {
          options.baseUrl = pdsUrl;
        }

        // Attach access token if present
        if (token != null && token.isNotEmpty && !options.headers.containsKey('Authorization')) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        // Attach chat proxy header for Bluesky chat endpoints
        if (isChat) {
          options.headers['atproto-proxy'] = ApiConfig.chatProxyDid;
        }

        return handler.next(options);
      },
      onError: (DioException error, handler) async {
        // Handle 401 Token Expiration with Automatic Refresh
        if (error.response?.statusCode == 401 &&
            !error.requestOptions.path.contains('refreshSession') &&
            !error.requestOptions.path.contains('createSession')) {
          final refreshed = await _refreshToken();
          if (refreshed) {
            final newToken = await tokenStorage.getAccessJwt();
            final opts = error.requestOptions;
            opts.headers['Authorization'] = 'Bearer $newToken';

            try {
              final response = await dio.fetch(opts);
              return handler.resolve(response);
            } catch (retryError) {
              return handler.next(error);
            }
          }
        }

        // Handle rate limiting (429 Too Many Requests)
        if (error.response?.statusCode == 429) {
          if (kDebugMode) {
            print('[DioClient] Bluesky Rate limit encountered on ${error.requestOptions.path}');
          }
        }

        return handler.next(error);
      },
    );
  }

  Future<bool> _refreshToken() async {
    final refreshJwt = await tokenStorage.getRefreshJwt();
    final pdsUrl = await tokenStorage.getPdsUrl() ?? ApiConfig.defaultPds;

    if (refreshJwt == null || refreshJwt.isEmpty) {
      await tokenStorage.clearSession();
      return false;
    }

    try {
      final refreshDio = Dio(BaseOptions(baseUrl: pdsUrl));
      final response = await refreshDio.post(
        ApiConfig.refreshSession,
        options: Options(
          headers: {'Authorization': 'Bearer $refreshJwt'},
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        await tokenStorage.saveSession(
          accessJwt: data['accessJwt'],
          refreshJwt: data['refreshJwt'],
          did: data['did'],
          handle: data['handle'],
          pdsUrl: pdsUrl,
        );
        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('[DioClient] Failed to refresh AT Protocol session: $e');
      }
      await tokenStorage.clearSession();
    }
    return false;
  }
}
