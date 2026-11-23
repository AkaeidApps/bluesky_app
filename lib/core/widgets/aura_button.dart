import 'package:flutter/material.dart';
import 'package:bluesky_app/core/constants/app_colors.dart';
import 'package:bluesky_app/core/constants/app_radius.dart';

enum AuraButtonVariant { primary, secondary, outline, text, danger }

class AuraButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AuraButtonVariant variant;
  final bool isLoading;
  final bool isCompact;
  final IconData? icon;
  final double? width;

  const AuraButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AuraButtonVariant.primary,
    this.isLoading = false,
    this.isCompact = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bg;
    Color fg;
    BorderSide? border;

    switch (variant) {
      case AuraButtonVariant.primary:
        bg = AppColors.primary;
        fg = Colors.white;
        break;
      case AuraButtonVariant.secondary:
        bg = isDark ? AppColors.darkSurfaceHover : AppColors.lightSurfaceHover;
        fg = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
        break;
      case AuraButtonVariant.outline:
        bg = Colors.transparent;
        fg = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
        border = BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.2,
        );
        break;
      case AuraButtonVariant.danger:
        bg = AppColors.error;
        fg = Colors.white;
        break;
      case AuraButtonVariant.text:
        bg = Colors.transparent;
        fg = AppColors.primary;
        break;
    }

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: bg,
      foregroundColor: fg,
      disabledBackgroundColor: bg.withValues(alpha: 0.5),
      disabledForegroundColor: fg.withValues(alpha: 0.5),
      elevation: 0,
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 14 : 20,
        vertical: isCompact ? 6 : 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusFull,
        side: border ?? BorderSide.none,
      ),
      minimumSize: Size(width ?? (isCompact ? 0 : 80), isCompact ? 32 : 44),
    );

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null && !isLoading) ...[
          Icon(icon, size: isCompact ? 16 : 18),
          const SizedBox(width: 6),
        ],
        Text(
          text,
          style: TextStyle(
            fontSize: isCompact ? 13 : 15,
            fontWeight: FontWeight.w700,
            color: fg,
          ),
        ),
      ],
    );

    if (isLoading) {
      content = SizedBox(
        width: isCompact ? 16 : 20,
        height: isCompact ? 16 : 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(fg),
        ),
      );
    }

    return SizedBox(
      width: width,
      child: ElevatedButton(
        style: buttonStyle,
        onPressed: isLoading ? null : onPressed,
        child: content,
      ),
    );
  }
}
