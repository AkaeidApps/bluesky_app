import 'package:get/get.dart';
import 'package:bluesky_app/features/chat/views/chat_conversation_view.dart';
import 'package:bluesky_app/features/composer/controllers/composer_controller.dart';
import 'package:bluesky_app/features/composer/views/composer_view.dart';
import 'package:bluesky_app/features/feeds/controllers/feeds_controller.dart';
import 'package:bluesky_app/features/feeds/views/feeds_view.dart';
import 'package:bluesky_app/features/followers/views/followers_view.dart';
import 'package:bluesky_app/features/home/bindings/home_binding.dart';
import 'package:bluesky_app/features/home/views/main_navigation_shell.dart';
import 'package:bluesky_app/features/onboarding/views/onboarding_view.dart';
import 'package:bluesky_app/features/post_details/controllers/post_details_controller.dart';
import 'package:bluesky_app/features/post_details/views/post_details_view.dart';
import 'package:bluesky_app/features/profile/controllers/profile_controller.dart';
import 'package:bluesky_app/features/profile/views/edit_profile_view.dart';
import 'package:bluesky_app/features/profile/views/profile_view.dart';
import 'package:bluesky_app/features/settings/controllers/settings_controller.dart';
import 'package:bluesky_app/features/settings/views/settings_view.dart';
import 'package:bluesky_app/features/splash/bindings/splash_binding.dart';
import 'package:bluesky_app/features/splash/views/splash_view.dart';

import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = AppRoutes.splash;

  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(name: AppRoutes.onboarding, page: () => const OnboardingView()),
    GetPage(
      name: AppRoutes.mainNav,
      page: () => const MainNavigationShell(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.composer,
      page: () => const ComposerView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ComposerController>(() => ComposerController());
      }),
    ),
    GetPage(
      name: AppRoutes.postDetails,
      page: () => const PostDetailsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<PostDetailsController>(() => PostDetailsController());
      }),
    ),
    GetPage(
      name: AppRoutes.chatConversation,
      page: () => const ChatConversationView(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ProfileController>(() => ProfileController());
      }),
    ),
    GetPage(name: AppRoutes.editProfile, page: () => const EditProfileView()),
    GetPage(
      name: AppRoutes.feeds,
      page: () => const FeedsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<FeedsController>(() => FeedsController());
      }),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SettingsController>(() => SettingsController());
      }),
    ),
    GetPage(name: AppRoutes.followers, page: () => const FollowersView()),
  ];
}