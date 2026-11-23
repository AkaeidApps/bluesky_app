import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:bluesky_app/core/constants/app_colors.dart';
import 'package:bluesky_app/data/models/post_model.dart';

class RichPostText extends StatelessWidget {
  final String text;
  final List<PostFacet> facets;
  final TextStyle? style;
  final Function(String mention)? onMentionTap;
  final Function(String tag)? onTagTap;
  final Function(String url)? onLinkTap;

  const RichPostText({
    super.key,
    required this.text,
    this.facets = const [],
    this.style,
    this.onMentionTap,
    this.onTagTap,
    this.onLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    final defaultStyle =
        style ??
        TextStyle(
          fontSize: 15,
          height: 1.4,
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkTextPrimary
              : AppColors.lightTextPrimary,
        );

    final highlightStyle = defaultStyle.copyWith(
      color: AppColors.primary,
      fontWeight: FontWeight.w600,
    );

    if (facets.isEmpty) {
      return Text(text, style: defaultStyle);
    }

    final spans = <TextSpan>[];
    int current = 0;

    for (final facet in facets) {
      if (facet.start > current && facet.start <= text.length) {
        spans.add(
          TextSpan(
            text: text.substring(current, facet.start),
            style: defaultStyle,
          ),
        );
      }

      if (facet.start < text.length && facet.end <= text.length) {
        final chunk = text.substring(facet.start, facet.end);
        GestureRecognizer? recognizer;

        if (facet.type == 'mention' && onMentionTap != null) {
          recognizer = TapGestureRecognizer()
            ..onTap = () => onMentionTap!(facet.value);
        } else if (facet.type == 'tag' && onTagTap != null) {
          recognizer = TapGestureRecognizer()
            ..onTap = () => onTagTap!(facet.value);
        } else if (facet.type == 'link' && onLinkTap != null) {
          recognizer = TapGestureRecognizer()
            ..onTap = () => onLinkTap!(facet.value);
        }

        spans.add(
          TextSpan(text: chunk, style: highlightStyle, recognizer: recognizer),
        );
        current = facet.end;
      }
    }

    if (current < text.length) {
      spans.add(TextSpan(text: text.substring(current), style: defaultStyle));
    }

    return RichText(text: TextSpan(children: spans));
  }
}
