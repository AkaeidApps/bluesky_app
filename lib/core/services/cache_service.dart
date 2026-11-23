import 'package:shared_preferences/shared_preferences.dart';
import 'package:bluesky_app/core/constants/app_constants.dart';

class CacheService {
  final SharedPreferences _prefs;

  CacheService(this._prefs);

  static Future<CacheService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return CacheService(prefs);
  }

  // Theme Mode
  String getThemeMode() =>
      _prefs.getString(AppConstants.keyThemeMode) ?? 'system';
  Future<bool> setThemeMode(String mode) =>
      _prefs.setString(AppConstants.keyThemeMode, mode);

  // Recent Searches
  List<String> getRecentSearches() =>
      _prefs.getStringList(AppConstants.keyRecentSearches) ?? [];
  Future<bool> addRecentSearch(String query) async {
    final current = getRecentSearches();
    current.remove(query);
    current.insert(0, query);
    if (current.length > 10) current.removeLast();
    return _prefs.setStringList(AppConstants.keyRecentSearches, current);
  }

  Future<bool> clearRecentSearches() =>
      _prefs.remove(AppConstants.keyRecentSearches);

  // Muted Words
  List<String> getMutedWords() =>
      _prefs.getStringList(AppConstants.keyMutedWords) ?? [];
  Future<bool> addMutedWord(String word) async {
    final words = getMutedWords();
    if (!words.contains(word.toLowerCase())) {
      words.add(word.toLowerCase());
      return _prefs.setStringList(AppConstants.keyMutedWords, words);
    }
    return true;
  }

  Future<bool> removeMutedWord(String word) async {
    final words = getMutedWords();
    words.remove(word.toLowerCase());
    return _prefs.setStringList(AppConstants.keyMutedWords, words);
  }

  // Saved Feeds
  List<String> getSavedFeeds() =>
      _prefs.getStringList(AppConstants.keySavedFeeds) ??
      [AppConstants.feedFollowing, AppConstants.feedDiscover];

  Future<bool> saveFeeds(List<String> feedIds) =>
      _prefs.setStringList(AppConstants.keySavedFeeds, feedIds);
}
