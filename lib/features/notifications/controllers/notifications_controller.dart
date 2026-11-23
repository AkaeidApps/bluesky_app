import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bluesky_app/data/models/notification_model.dart';
import 'package:bluesky_app/data/repositories/notification_repository.dart';

class NotificationsController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final NotificationRepository _notifRepo = Get.find<NotificationRepository>();

  late TabController tabController;
  final notifications = <NotificationModel>[].obs;
  final isLoading = false.obs;

  List<NotificationModel> get mentionNotifications => notifications
      .where(
        (n) =>
            n.type == NotificationType.mention ||
            n.type == NotificationType.reply,
      )
      .toList();

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    _listenNotifications();
  }

  void _listenNotifications() {
    isLoading.value = true;
    _notifRepo.getNotificationsStream('user_current').listen((data) {
      notifications.assignAll(data);
      isLoading.value = false;
    });
  }

  Future<void> markAllAsRead() async {
    await _notifRepo.markAllAsRead('user_current');
    for (int i = 0; i < notifications.length; i++) {
      notifications[i] = notifications[i].copyWith(isRead: true);
    }
    Get.snackbar(
      'Notifications',
      'All notifications marked as read',
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}
