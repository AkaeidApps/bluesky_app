import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bluesky_app/core/widgets/aura_avatar.dart';
import 'package:bluesky_app/core/widgets/aura_button.dart';
import 'package:bluesky_app/data/models/user_model.dart';
import 'package:bluesky_app/data/providers/mock_data_provider.dart';

class FollowersView extends StatelessWidget {
  const FollowersView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final type = args?['type'] ?? 'followers';
    final title = type == 'following' ? 'Following' : 'Followers';

    final List<UserModel> list = MockDataProvider.sampleUsers;

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
          final user = list[index];
          return ListTile(
            leading: AuraAvatar(
              imageUrl: user.avatarUrl,
              fallbackName: user.displayName,
            ),
            title: Text(
              user.displayName,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text('@${user.handle}'),
            trailing: AuraButton(
              text: user.isFollowing ? 'Following' : 'Follow',
              isCompact: true,
              variant: user.isFollowing
                  ? AuraButtonVariant.outline
                  : AuraButtonVariant.primary,
              onPressed: () {},
            ),
          );
        },
      ),
    );
  }
}
