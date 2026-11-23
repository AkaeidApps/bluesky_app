import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bluesky_app/core/widgets/aura_button.dart';
import 'package:bluesky_app/core/widgets/aura_text_field.dart';
import 'package:bluesky_app/features/profile/controllers/profile_controller.dart';

class EditProfileView extends GetView<ProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: AuraButton(
              text: 'Save',
              isCompact: true,
              onPressed: controller.saveProfile,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            AuraTextField(
              controller: controller.editDisplayNameController,
              labelText: 'Display Name',
            ),
            const SizedBox(height: 18),
            AuraTextField(
              controller: controller.editBioController,
              labelText: 'Bio',
              maxLines: 3,
              maxLength: 256,
            ),
            const SizedBox(height: 18),
            AuraTextField(
              controller: controller.editWebsiteController,
              labelText: 'Website',
              hintText: 'https://yourwebsite.com',
            ),
            const SizedBox(height: 18),
            AuraTextField(
              controller: controller.editLocationController,
              labelText: 'Location',
              hintText: 'e.g. San Francisco, CA',
            ),
          ],
        ),
      ),
    );
  }
}
