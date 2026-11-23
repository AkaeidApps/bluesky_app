import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:bluesky_app/core/constants/app_colors.dart';
import 'package:bluesky_app/core/constants/app_radius.dart';

class MediaGrid extends StatelessWidget {
  final List<String> mediaUrls;
  final List<String> altTexts;
  final Function(int index)? onImageTap;

  const MediaGrid({
    super.key,
    required this.mediaUrls,
    this.altTexts = const [],
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    if (mediaUrls.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
      child: ClipRRect(
        borderRadius: AppRadius.radiusMd,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkBorder
                  : AppColors.lightBorder,
              width: 0.8,
            ),
            borderRadius: AppRadius.radiusMd,
          ),
          child: _buildLayout(context),
        ),
      ),
    );
  }

  Widget _buildLayout(BuildContext context) {
    switch (mediaUrls.length) {
      case 1:
        return AspectRatio(aspectRatio: 16 / 9, child: _buildItem(context, 0));
      case 2:
        return AspectRatio(
          aspectRatio: 16 / 9,
          child: Row(
            children: [
              Expanded(child: _buildItem(context, 0)),
              const SizedBox(width: 2),
              Expanded(child: _buildItem(context, 1)),
            ],
          ),
        );
      case 3:
        return AspectRatio(
          aspectRatio: 16 / 9,
          child: Row(
            children: [
              Expanded(child: _buildItem(context, 0)),
              const SizedBox(width: 2),
              Expanded(
                child: Column(
                  children: [
                    Expanded(child: _buildItem(context, 1)),
                    const SizedBox(height: 2),
                    Expanded(child: _buildItem(context, 2)),
                  ],
                ),
              ),
            ],
          ),
        );
      default: // 4 items
        return AspectRatio(
          aspectRatio: 16 / 9,
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: _buildItem(context, 0)),
                    const SizedBox(width: 2),
                    Expanded(child: _buildItem(context, 1)),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: _buildItem(context, 2)),
                    const SizedBox(width: 2),
                    Expanded(child: _buildItem(context, 3)),
                  ],
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildItem(BuildContext context, int index) {
    final url = mediaUrls[index];
    final hasAlt = altTexts.length > index && altTexts[index].isNotEmpty;

    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          onTap: () {
            if (onImageTap != null) {
              onImageTap!(index);
            } else {
              _showImageDialog(context, index);
            }
          },
          child: CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: AppColors.lightSurface,
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: AppColors.lightSurface,
              child: const Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  color: AppColors.lightTextTertiary,
                ),
              ),
            ),
          ),
        ),
        if (hasAlt)
          Positioned(
            left: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: AppRadius.radiusXs,
              ),
              child: const Text(
                'ALT',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showImageDialog(BuildContext context, int initialIndex) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: CachedNetworkImage(
                imageUrl: mediaUrls[initialIndex],
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: 40,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
