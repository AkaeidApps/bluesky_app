import 'package:get/get.dart';
import 'package:bluesky_app/data/models/user_model.dart';
import 'package:bluesky_app/data/providers/mock_data_provider.dart';
import 'package:bluesky_app/data/repositories/auth_repository.dart';
import 'package:bluesky_app/data/repositories/chat_repository.dart';
import 'package:bluesky_app/data/repositories/notification_repository.dart';
import 'package:bluesky_app/data/repositories/user_repository.dart';

class HomeController extends GetxController {
  final AuthRepository _authRepo = Get.find<AuthRepository>();
  final UserRepository _userRepo = Get.find<UserRepository>();
  final NotificationRepository _notifRepo = Get.find<NotificationRepository>();
  final ChatRepository _chatRepo = Get.find<ChatRepository>();

  final currentTabIndex = 0.obs;
  final currentUser = Rxn<UserModel>();

  final unreadNotificationsCount = 0.obs;
  final unreadMessagesCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUser();
    _listenToBadges();
  }

  Future<void> _loadUser() async {
    final hasSession = await _authRepo.hasValidSession();
    if (hasSession) {
      final user = await _authRepo.getCurrentUserProfile();
      currentUser.value = user;
    } else {
      currentUser.value = MockDataProvider.currentUser;
    }
  }

  void _listenToBadges() {
    _notifRepo.getNotificationsStream('user_current').listen((notifs) {
      unreadNotificationsCount.value = notifs.where((n) => !n.isRead).length;
    });

    _chatRepo.getConversationsStream('user_current').listen((convs) {
      unreadMessagesCount.value = convs.fold(
        0,
        (sum, c) => sum + c.unreadCount,
      );
    });
  }

  void switchTab(int index) {
    currentTabIndex.value = index;
  }
}