class BlueskyMediaItem {
  final String thumbUrl;
  final String fullsizeUrl;
  final String altText;
  final double? aspectRatio;

  const BlueskyMediaItem({
    required this.thumbUrl,
    required this.fullsizeUrl,
    this.altText = '',
    this.aspectRatio,
  });
}

class BlueskyExternalCard {
  final String uri;
  final String title;
  final String description;
  final String? thumbUrl;

  const BlueskyExternalCard({
    required this.uri,
    required this.title,
    required this.description,
    this.thumbUrl,
  });
}

class MediaResolver {
  MediaResolver._();

  /// Parses Bluesky post embed object into media items, video, or external cards
  static List<BlueskyMediaItem> parseEmbedImages(dynamic embed) {
    if (embed == null || embed is! Map) return [];

    final type = embed[r'$type'] as String?;

    // Direct image embed: app.bsky.embed.images#view
    if (type == 'app.bsky.embed.images#view') {
      final rawImages = embed['images'] as List<dynamic>? ?? [];
      return rawImages.map((img) {
        final m = Map<String, dynamic>.from(img);
        double? ratio;
        if (m['aspectRatio'] is Map) {
          final width = (m['aspectRatio']['width'] as num?)?.toDouble() ?? 1;
          final height = (m['aspectRatio']['height'] as num?)?.toDouble() ?? 1;
          if (height > 0) ratio = width / height;
        }

        return BlueskyMediaItem(
          thumbUrl: m['thumb'] ?? m['fullsize'] ?? '',
          fullsizeUrl: m['fullsize'] ?? m['thumb'] ?? '',
          altText: m['alt'] ?? '',
          aspectRatio: ratio,
        );
      }).where((i) => i.thumbUrl.isNotEmpty).toList();
    }

    // Combined embed: app.bsky.embed.recordWithMedia#view
    if (type == 'app.bsky.embed.recordWithMedia#view') {
      final media = embed['media'];
      return parseEmbedImages(media);
    }

    return [];
  }

  /// Parses external web link preview card
  static BlueskyExternalCard? parseExternalCard(dynamic embed) {
    if (embed == null || embed is! Map) return null;

    final type = embed[r'$type'] as String?;

    if (type == 'app.bsky.embed.external#view') {
      final external = embed['external'] as Map<String, dynamic>?;
      if (external != null) {
        return BlueskyExternalCard(
          uri: external['uri'] ?? '',
          title: external['title'] ?? '',
          description: external['description'] ?? '',
          thumbUrl: external['thumb'],
        );
      }
    }

    if (type == 'app.bsky.embed.recordWithMedia#view') {
      return parseExternalCard(embed['media']);
    }

    return null;
  }

  /// Parses video embed: app.bsky.embed.video#view
  static Map<String, dynamic>? parseVideo(dynamic embed) {
    if (embed == null || embed is! Map) return null;

    final type = embed[r'$type'] as String?;
    if (type == 'app.bsky.embed.video#view') {
      return {
        'playlist': embed['playlist'],
        'thumbnail': embed['thumbnail'],
        'alt': embed['alt'] ?? '',
      };
    }

    if (type == 'app.bsky.embed.recordWithMedia#view') {
      return parseVideo(embed['media']);
    }

    return null;
  }
}
