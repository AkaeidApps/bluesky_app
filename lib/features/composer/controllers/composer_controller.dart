import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bluesky_app/core/constants/app_constants.dart';
import 'package:bluesky_app/core/utils/rich_text_parser.dart';
import 'package:bluesky_app/data/models/post_model.dart';
import 'package:bluesky_app/data/models/reply_model.dart';
import 'package:bluesky_app/data/providers/mock_data_provider.dart';
import 'package:bluesky_app/data/repositories/post_repository.dart';
import 'package:bluesky_app/features/timeline/controllers/timeline_controller.dart';

class ComposerController extends GetxController {
  final PostRepository _postRepo = Get.find<PostRepository>();

  final textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  final selectedImages = <XFile>[].obs;
  final altTexts = <String>[].obs;
  final remainingChars = AppConstants.maxPostLength.obs;
  final isPublishing = false.obs;
  final replyPermission = ReplyPermission.everyone.obs;

  final Rxn<PostModel> replyingToPost = Rxn<PostModel>();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map && args.containsKey('replyTo')) {
      replyingToPost.value = args['replyTo'] as PostModel;
    }

    textController.addListener(_updateCharCount);
  }

  void _updateCharCount() {
    remainingChars.value =
        AppConstants.maxPostLength - textController.text.length;
  }

  Future<void> pickImages() async {
    if (selectedImages.length >= AppConstants.maxMediaAttachments) {
      Get.snackbar('Limit Reached', 'You can attach up to 4 images per post.');
      return;
    }

    try {
      final List<XFile> images = await _picker.pickMultiImage(
        limit: AppConstants.maxMediaAttachments - selectedImages.length,
      );

      for (final img in images) {
        selectedImages.add(img);
        altTexts.add('');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < selectedImages.length) {
      selectedImages.removeAt(index);
      altTexts.removeAt(index);
    }
  }

  void editAltText(int index) {
    final altController = TextEditingController(text: altTexts[index]);

    Get.defaultDialog(
      title: 'Add Alt Text',
      content: TextField(
        controller: altController,
        maxLines: 3,
        decoration: const InputDecoration(
          hintText: 'Describe this image for visually impaired users...',
        ),
      ),
      textConfirm: 'Save',
      textCancel: 'Cancel',
      onConfirm: () {
        altTexts[index] = altController.text.trim();
        Get.back();
      },
    );
  }

  Future<void> publishPost() async {
    final content = textController.text.trim();
    if (content.isEmpty && selectedImages.isEmpty) {
      Get.snackbar('Empty Post', 'Please write something or attach media.');
      return;
    }

    if (remainingChars.value < 0) {
      Get.snackbar(
        'Character Limit Exceeded',
        'Please keep your post within 300 characters.',
      );
      return;
    }

    try {
      isPublishing.value = true;
      final user = MockDataProvider.currentUser;
      final facets = RichTextParser.parseFacets(content);

      if (replyingToPost.value != null) {
        // Creating a reply
        final reply = ReplyModel(
          id: '',
          postId: replyingToPost.value!.id,
          authorId: user.id,
          authorDisplayName: user.displayName,
          authorHandle: user.handle,
          authorAvatarUrl: user.avatarUrl,
          authorIsVerified: user.isVerified,
          content: content,
          createdAt: DateTime.now(),
          facets: facets,
        );

        await _postRepo.createReply(replyingToPost.value!.id, reply);
      } else {
        // Creating a top-level post
        final post = PostModel(
          id: '',
          authorId: user.id,
          authorDisplayName: user.displayName,
          authorHandle: user.handle,
          authorAvatarUrl: user.avatarUrl,
          authorIsVerified: user.isVerified,
          content: content,
          mediaUrls: selectedImages.map((i) => i.path).toList(),
          mediaTypes: selectedImages.map((_) => 'image').toList(),
          altTexts: altTexts,
          createdAt: DateTime.now(),
          facets: facets,
          replyPermission: replyPermission.value,
        );

        final created = await _postRepo.createPost(post);

        // Prepend to following and discover feeds in TimelineController
        if (Get.isRegistered<TimelineController>()) {
          final timeline = Get.find<TimelineController>();
          timeline.followingPosts.insert(0, created);
          timeline.discoverPosts.insert(0, created);
        }
      }

      Get.back();
      Get.snackbar(
        'Success',
        'Your post has been published! 🦋',
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar('Publish Error', e.toString());
    } finally {
      isPublishing.value = false;
    }
  }

  @override
  void onClose() {
    textController.removeListener(_updateCharCount);
    textController.dispose();
    super.onClose();
  }
}
