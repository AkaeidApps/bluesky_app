import 'package:flutter/material.dart';
import 'package:bluesky_app/core/constants/app_colors.dart';

import 'aura_avatar.dart';
import 'aura_brand_mark.dart';

class AuraAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final String? userAvatarUrl;
  final String userDisplayName;
  final VoidCallback? onAvatarTap;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  const AuraAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.userAvatarUrl,
    this.userDisplayName = 'User',
    this.onAvatarTap,
    this.actions,
    this.bottom,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(54.0 + (bottom?.preferredSize.height ?? 0.0));

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      leadingWidth: 56,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Center(
          child: AuraAvatar(
            imageUrl: userAvatarUrl,
            fallbackName: userDisplayName,
            size: 32,
            onTap: onAvatarTap ?? () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      centerTitle: true,
      title:
          titleWidget ??
          (title != null
              ? Text(
                  title!,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                )
              : const AuraBrandMark(size: 28)),
      actions: actions != null ? [...actions!, const SizedBox(width: 8)] : null,
      bottom: bottom,
    );
  }
}
