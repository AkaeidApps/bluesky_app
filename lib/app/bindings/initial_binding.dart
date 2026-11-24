import 'package:get/get.dart';
import 'package:bluesky_app/core/auth/atproto_auth_service.dart';
import 'package:bluesky_app/core/auth/secure_token_storage.dart';
import 'package:bluesky_app/core/services/network_service.dart';
import 'package:bluesky_app/core/network/atproto_api_service.dart';
import 'package:bluesky_app/data/repositories/auth_repository.dart';
import 'package:bluesky_app/data/repositories/chat_repository.dart';
import 'package:bluesky_app/data/repositories/feed_repository.dart';
import 'package:bluesky_app/data/repositories/notification_repository.dart';
import 'package:bluesky_app/data/repositories/post_repository.dart';
import 'package:bluesky_app/data/repositories/user_repository.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<SecureTokenStorage>(SecureTokenStorage(), permanent: true);

    Get.put<AtprotoApiService>(
      AtprotoApiService(tokenStorage: Get.find<SecureTokenStorage>()),
      permanent: true,
    );

    Get.put<AtprotoAuthService>(
      AtprotoAuthService(
        tokenStorage: Get.find<SecureTokenStorage>(),
        apiService: Get.find<AtprotoApiService>(),
      ),
      permanent: true,
    );

    Get.put<NetworkService>(NetworkService(), permanent: true);

    Get.lazyPut<AuthRepository>(
      () => AuthRepository(
        authService: Get.find<AtprotoAuthService>(),
        tokenStorage: Get.find<SecureTokenStorage>(),
      ),
      fenix: true,
    );
    Get.lazyPut<UserRepository>(
      () => UserRepository(apiService: Get.find<AtprotoApiService>()),
      fenix: true,
    );
    Get.lazyPut<PostRepository>(
      () => PostRepository(apiService: Get.find<AtprotoApiService>()),
      fenix: true,
    );
    Get.lazyPut<ChatRepository>(
      () => ChatRepository(apiService: Get.find<AtprotoApiService>()),
      fenix: true,
    );
    Get.lazyPut<NotificationRepository>(
      () => NotificationRepository(apiService: Get.find<AtprotoApiService>()),
      fenix: true,
    );
    Get.lazyPut<FeedRepository>(
      () => FeedRepository(apiService: Get.find<AtprotoApiService>()),
      fenix: true,
    );
  }
}