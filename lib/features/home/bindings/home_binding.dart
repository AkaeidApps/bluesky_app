import 'package:get/get.dart';
import 'package:bluesky_app/features/home/controllers/home_controller.dart';
import 'package:bluesky_app/features/timeline/controllers/timeline_controller.dart';
import 'package:bluesky_app/features/search/controllers/search_controller.dart';
import 'package:bluesky_app/features/notifications/controllers/notifications_controller.dart';
import 'package:bluesky_app/features/chat/controllers/chat_controller.dart';
import 'package:bluesky_app/features/profile/controllers/profile_controller.dart';
import 'package:bluesky_app/features/composer/controllers/composer_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<HomeController>(HomeController());
    Get.lazyPut<TimelineController>(() => TimelineController(), fenix: true);
    Get.lazyPut<AuraSearchController>(
      () => AuraSearchController(),
      fenix: true,
    );
    Get.lazyPut<NotificationsController>(
      () => NotificationsController(),
      fenix: true,
    );
    Get.lazyPut<ChatController>(() => ChatController(), fenix: true);
    Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
    Get.lazyPut<ComposerController>(() => ComposerController(), fenix: true);
  }
}
