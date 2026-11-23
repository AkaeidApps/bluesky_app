class ApiConfig {
  ApiConfig._();

  // Official Bluesky & AT Protocol API hosts
  static const String publicAppView = 'https://public.api.bsky.app';
  static const String defaultPds = 'https://bsky.social';
  static const String cdnBase = 'https://cdn.bsky.app';

  // Chat service proxy
  static const String chatProxyDid = 'did:web:api.bsky.chat#bsky_chat';

  // Popular Discover Feed Generator AT-URI (What's Hot on Bluesky)
  static const String discoverFeedUri =
      'at://did:plc:z72i7hdynmk6r22z27h6tvur/app.bsky.feed.generator/whats-hot';

  // Standard XRPC Methods
  // Authentication & Server
  static const String createSession = '/xrpc/com.atproto.server.createSession';
  static const String refreshSession = '/xrpc/com.atproto.server.refreshSession';
  static const String deleteSession = '/xrpc/com.atproto.server.deleteSession';
  static const String getSession = '/xrpc/com.atproto.server.getSession';

  // Identity
  static const String resolveHandle = '/xrpc/com.atproto.identity.resolveHandle';

  // Repository Operations
  static const String createRecord = '/xrpc/com.atproto.repo.createRecord';
  static const String deleteRecord = '/xrpc/com.atproto.repo.deleteRecord';
  static const String getRecord = '/xrpc/com.atproto.repo.getRecord';
  static const String listRecords = '/xrpc/com.atproto.repo.listRecords';
  static const String uploadBlob = '/xrpc/com.atproto.repo.uploadBlob';

  // Feed Operations
  static const String getTimeline = '/xrpc/app.bsky.feed.getTimeline';
  static const String getFeed = '/xrpc/app.bsky.feed.getFeed';
  static const String getAuthorFeed = '/xrpc/app.bsky.feed.getAuthorFeed';
  static const String getPostThread = '/xrpc/app.bsky.feed.getPostThread';
  static const String getPosts = '/xrpc/app.bsky.feed.getPosts';
  static const String searchPosts = '/xrpc/app.bsky.feed.searchPosts';
  static const String getLikes = '/xrpc/app.bsky.feed.getLikes';
  static const String getRepostedBy = '/xrpc/app.bsky.feed.getRepostedBy';
  static const String getSuggestedFeeds = '/xrpc/app.bsky.feed.getSuggestedFeeds';
  static const String getFeedGenerators = '/xrpc/app.bsky.feed.getFeedGenerators';

  // Actor / Profile Operations
  static const String getProfile = '/xrpc/app.bsky.actor.getProfile';
  static const String getProfiles = '/xrpc/app.bsky.actor.getProfiles';
  static const String searchActors = '/xrpc/app.bsky.actor.searchActors';
  static const String getSuggestions = '/xrpc/app.bsky.actor.getSuggestions';
  static const String getFollowers = '/xrpc/graph.getFollowers';
  static const String getFollows = '/xrpc/graph.getFollows';

  // Notifications
  static const String listNotifications = '/xrpc/app.bsky.notification.listNotifications';
  static const String getUnreadCount = '/xrpc/app.bsky.notification.getUnreadCount';
  static const String updateSeen = '/xrpc/app.bsky.notification.updateSeen';

  // Chat Operations
  static const String listConvos = '/xrpc/chat.bsky.convo.listConvos';
  static const String getConvo = '/xrpc/chat.bsky.convo.getConvo';
  static const String getMessages = '/xrpc/chat.bsky.convo.getMessages';
  static const String sendMessage = '/xrpc/chat.bsky.convo.sendMessage';
  static const String updateRead = '/xrpc/chat.bsky.convo.updateRead';

  // Record Collection Names
  static const String collectionLike = 'app.bsky.feed.like';
  static const String collectionRepost = 'app.bsky.feed.repost';
  static const String collectionPost = 'app.bsky.feed.post';
  static const String collectionFollow = 'app.bsky.graph.follow';
  static const String collectionBlock = 'app.bsky.graph.block';
}
