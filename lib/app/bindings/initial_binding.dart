import 'package:get/get.dart';
import 'package:bluesky_app/core/services/network_service.dart';
import 'package:bluesky_app/data/repositories/auth_repository.dart';
import 'package:bluesky_app/data/repositories/chat_repository.dart';
import 'package:bluesky_app/data/repositories/feed_repository.dart';
import 'package:bluesky_app/data/repositories/notification_repository.dart';
import 'package:bluesky_app/data/repositories/post_repository.dart';
import 'package:bluesky_app/data/repositories/user_repository.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Core Services
    Get.put<NetworkService>(NetworkService(), permanent: true);

    // Repositories
    Get.lazyPut<AuthRepository>(() => AuthRepository(), fenix: true);
    Get.lazyPut<UserRepository>(() => UserRepository(), fenix: true);
    Get.lazyPut<PostRepository>(() => PostRepository(), fenix: true);
    Get.lazyPut<ChatRepository>(() => ChatRepository(), fenix: true);
    Get.lazyPut<NotificationRepository>(
      () => NotificationRepository(),
      fenix: true,
    );
    Get.lazyPut<FeedRepository>(() => FeedRepository(), fenix: true);
  }
}
