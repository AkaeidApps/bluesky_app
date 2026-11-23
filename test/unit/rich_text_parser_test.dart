import 'package:flutter_test/flutter_test.dart';
import 'package:bluesky_app/core/utils/rich_text_parser.dart';

void main() {
  group('RichTextParser Unit Tests', () {
    test('extracts mentions correctly', () {
      const text = 'Hello @maya and @alex.aura.social how are you?';
      final facets = RichTextParser.parseFacets(text);

      expect(facets.length, 2);
      expect(facets[0].type, 'mention');
      expect(facets[0].value, 'maya');
      expect(facets[1].type, 'mention');
      expect(facets[1].value, 'alex.aura.social');
    });

    test('extracts hashtags correctly', () {
      const text = 'Building cool apps with #flutter and #bluesky!';
      final facets = RichTextParser.parseFacets(text);

      expect(facets.length, 2);
      expect(facets[0].type, 'tag');
      expect(facets[0].value, 'flutter');
      expect(facets[1].type, 'tag');
      expect(facets[1].value, 'bluesky');
    });

    test('extracts links correctly', () {
      const text = 'Visit https://aura.social for updates';
      final facets = RichTextParser.parseFacets(text);

      expect(facets.length, 1);
      expect(facets[0].type, 'link');
      expect(facets[0].value, 'https://aura.social');
    });

    test('sorts facets by start index', () {
      const text = 'Check #first then @second then https://third.com';
      final facets = RichTextParser.parseFacets(text);

      expect(facets.length, 3);
      expect(facets[0].type, 'tag');
      expect(facets[1].type, 'mention');
      expect(facets[2].type, 'link');
      expect(facets[0].start < facets[1].start, true);
      expect(facets[1].start < facets[2].start, true);
    });
  });
}
