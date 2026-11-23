class AppConstants {
  AppConstants._();

  static const String appName = 'Aura';
  static const String appTagline = 'The next evolution of social networking';
  static const String domainHandleSuffix = '.aura.social';

  // Limits
  static const int maxPostLength = 300;
  static const int maxMediaAttachments = 4;
  static const int maxBioLength = 256;
  static const int maxDisplayNameLength = 64;
  static const int maxHandleLength = 30;
  static const int minHandleLength = 3;
  static const int pageSize = 20;

  // Feeds
  static const String feedFollowing = 'following';
  static const String feedDiscover = 'discover';
  static const String feedPopular = 'popular';
  static const String feedTech = 'technology';
  static const String feedArt = 'art';

  // Storage Keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyUserAuth = 'user_auth_state';
  static const String keyRecentSearches = 'recent_searches';
  static const String keySavedFeeds = 'saved_feeds';
  static const String keyMutedWords = 'muted_words';
}
