import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:bluesky_app/core/constants/app_colors.dart';

class AuraAvatar extends StatelessWidget {
  final String? imageUrl;
  final String fallbackName;
  final double size;
  final VoidCallback? onTap;
  final bool hasBorder;
  final Color? borderColor;

  const AuraAvatar({
    super.key,
    this.imageUrl,
    this.fallbackName = 'User',
    this.size = 40.0,
    this.onTap,
    this.hasBorder = false,
    this.borderColor,
  });

  String get _initials {
    if (fallbackName.trim().isEmpty) return 'U';
    final parts = fallbackName.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fallbackName
        .substring(0, fallbackName.length >= 2 ? 2 : 1)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    Widget avatarChild;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      avatarChild = CachedNetworkImage(
        imageUrl: imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: size,
          height: size,
          color: AppColors.primarySurfaceLight,
          child: const Center(
            child: SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildInitials(),
      );
    } else {
      avatarChild = _buildInitials();
    }

    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: hasBorder
            ? Border.all(color: borderColor ?? Colors.white, width: 2.5)
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: avatarChild,
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: avatar);
    }

    return avatar;
  }

  Widget _buildInitials() {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.brandGradient,
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.38,
        ),
      ),
    );
  }
}
