import 'package:bluesky_app/data/models/post_model.dart';

class RichTextParser {
  RichTextParser._();

  static final RegExp mentionRegex = RegExp(r'@([a-zA-Z0-9_\.]+)');
  static final RegExp hashtagRegex = RegExp(r'#([a-zA-Z0-9_]+)');
  static final RegExp urlRegex = RegExp(
    r'(https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|www\.[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|https?:\/\/[^\s]+)',
    caseSensitive: false,
  );

  /// Analyzes text and extracts facets (mentions, hashtags, links) with start/end indices.
  static List<PostFacet> parseFacets(String text) {
    final List<PostFacet> facets = [];

    // Extract Mentions
    for (final match in mentionRegex.allMatches(text)) {
      facets.add(
        PostFacet(
          type: 'mention',
          value: match.group(1) ?? '',
          start: match.start,
          end: match.end,
        ),
      );
    }

    // Extract Hashtags
    for (final match in hashtagRegex.allMatches(text)) {
      facets.add(
        PostFacet(
          type: 'tag',
          value: match.group(1) ?? '',
          start: match.start,
          end: match.end,
        ),
      );
    }

    // Extract URLs
    for (final match in urlRegex.allMatches(text)) {
      facets.add(
        PostFacet(
          type: 'link',
          value: match.group(0) ?? '',
          start: match.start,
          end: match.end,
        ),
      );
    }

    // Sort by start index
    facets.sort((a, b) => a.start.compareTo(b.start));
    return facets;
  }
}
