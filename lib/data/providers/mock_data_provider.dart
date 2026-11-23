import 'package:bluesky_app/data/models/user_model.dart';
import 'package:bluesky_app/data/models/post_model.dart';
import 'package:bluesky_app/data/models/feed_model.dart';
import 'package:bluesky_app/data/models/chat_model.dart';
import 'package:bluesky_app/data/models/notification_model.dart';

class MockDataProvider {
  MockDataProvider._();

  static final UserModel currentUser = UserModel(
    id: 'user_current',
    email: 'developer@aura.social',
    displayName: 'Aura Explorer',
    handle: 'explorer.aura.social',
    avatarUrl:
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
    bannerUrl:
        'https://images.unsplash.com/photo-1579546929518-9e396f3cc809?w=800',
    bio: 'Building the next generation of social networking on Flutter. Open web & decentralized future enthusiasts. 🦋✨',
    website: 'https://aura.social',
    location: 'San Francisco, CA',
    createdAt: DateTime(2025, 4, 12),
    followersCount: 1420,
    followingCount: 388,
    postsCount: 124,
    isVerified: true,
  );

  static final List<UserModel> sampleUsers = [
    UserModel(
      id: 'user_1',
      email: 'maya@aura.social',
      displayName: 'Maya Lin',
      handle: 'mayalin.aura.social',
      avatarUrl:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
      bannerUrl:
          'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=800',
      bio: 'Interface designer & creative coder. Exploring typography, generative art and calm software.',
      website: 'https://mayalin.design',
      location: 'Tokyo, Japan',
      createdAt: DateTime(2025, 1, 10),
      followersCount: 8940,
      followingCount: 412,
      postsCount: 652,
      isVerified: true,
      isFollowing: true,
    ),
    UserModel(
      id: 'user_2',
      email: 'alex@aura.social',
      displayName: 'Alex Rivera',
      handle: 'alex.aura.social',
      avatarUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      bannerUrl:
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800',
      bio: 'Mobile architect & open source contributor. Crafting fast and accessible cross-platform apps.',
      website: 'https://github.com/alexrivera',
      location: 'Berlin, Germany',
      createdAt: DateTime(2025, 2, 1),
      followersCount: 12400,
      followingCount: 610,
      postsCount: 1230,
      isVerified: true,
      isFollowing: true,
    ),
    UserModel(
      id: 'user_3',
      email: 'aurateam@aura.social',
      displayName: 'Aura Official',
      handle: 'aura.social',
      avatarUrl:
          'https://images.unsplash.com/photo-1518770660439-4636190af475?w=150',
      bannerUrl:
          'https://images.unsplash.com/photo-1550684848-fac1c5b4e853?w=800',
      bio: 'Official updates, releases and news from the Aura Social engineering and design team. 🦋',
      website: 'https://aura.social',
      location: 'Everywhere',
      createdAt: DateTime(2024, 11, 1),
      followersCount: 85200,
      followingCount: 15,
      postsCount: 310,
      isVerified: true,
      isFollowing: true,
    ),
  ];

  static final List<FeedModel> sampleFeeds = [
    const FeedModel(
      id: 'feed_discover',
      name: 'Discover',
      description:
          'Trending and most engaging posts across the entire Aura network.',
      avatarUrl:
          'https://images.unsplash.com/photo-1518770660439-4636190af475?w=100',
      creatorHandle: 'aura.social',
      creatorDisplayName: 'Aura Official',
      likesCount: 34500,
      isSaved: true,
      isPinned: true,
      queryTag: 'discover',
    ),
    const FeedModel(
      id: 'feed_tech',
      name: 'Tech & Dev',
      description: 'Engineering, Flutter, open source and cutting-edge software architecture.',
      avatarUrl:
          'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=100',
      creatorHandle: 'alex.aura.social',
      creatorDisplayName: 'Alex Rivera',
      likesCount: 18200,
      isSaved: true,
      isPinned: false,
      queryTag: 'tech',
    ),
    const FeedModel(
      id: 'feed_art',
      name: 'Design & Art',
      description:
          'Visual arts, typography, photography and modern UI aesthetics.',
      avatarUrl:
          'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?w=100',
      creatorHandle: 'mayalin.aura.social',
      creatorDisplayName: 'Maya Lin',
      likesCount: 22100,
      isSaved: false,
      isPinned: false,
      queryTag: 'art',
    ),
  ];

  static final List<PostModel> samplePosts = [
    PostModel(
      id: 'post_1',
      authorId: 'user_3',
      authorDisplayName: 'Aura Official',
      authorHandle: 'aura.social',
      authorAvatarUrl:
          'https://images.unsplash.com/photo-1518770660439-4636190af475?w=150',
      authorIsVerified: true,
      content: 'Welcome to Aura Social! 🦋 An open, modern social network built with Flutter, GetX and Firebase. Clean lines, spacious feeds, rich threads, and authentic interactions.',
      mediaUrls: [
        'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=800',
      ],
      mediaTypes: ['image'],
      altTexts: [
        'Vibrant abstract blue butterfly waves representing freedom and connection',
      ],
      createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
      likesCount: 428,
      repostsCount: 142,
      repliesCount: 39,
      quotesCount: 18,
      isLiked: true,
      isReposted: false,
      isBookmarked: true,
      facets: [
        const PostFacet(
          type: 'mention',
          value: 'aura.social',
          start: 11,
          end: 22,
        ),
      ],
    ),
    PostModel(
      id: 'post_2',
      authorId: 'user_1',
      authorDisplayName: 'Maya Lin',
      authorHandle: 'mayalin.aura.social',
      authorAvatarUrl:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
      authorIsVerified: true,
      content: 'Morning sky in Tokyo today was breathtaking. Minimalist architecture paired with early winter light is pure tranquility. ⛅🗼 #photography #architecture',
      mediaUrls: [
        'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?w=800',
        'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=800',
      ],
      mediaTypes: ['image', 'image'],
      altTexts: [
        'Tokyo skyline with tower',
        'Morning light reflection on glass skyscraper',
      ],
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      likesCount: 284,
      repostsCount: 31,
      repliesCount: 14,
      quotesCount: 5,
      isLiked: false,
      isReposted: true,
      isBookmarked: false,
      facets: [
        const PostFacet(
          type: 'tag',
          value: 'photography',
          start: 114,
          end: 126,
        ),
        const PostFacet(
          type: 'tag',
          value: 'architecture',
          start: 127,
          end: 140,
        ),
      ],
    ),
    PostModel(
      id: 'post_3',
      authorId: 'user_2',
      authorDisplayName: 'Alex Rivera',
      authorHandle: 'alex.aura.social',
      authorAvatarUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      authorIsVerified: true,
      content: 'Flutter 3.47 is astonishingly fast. The smoothness of custom painters, sliver feeds, and cached media makes native experience seamless. What are you building this week? 🚀',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      likesCount: 195,
      repostsCount: 22,
      repliesCount: 48,
      quotesCount: 7,
      isLiked: false,
      isReposted: false,
      isBookmarked: false,
    ),
  ];

  static final List<NotificationModel> sampleNotifications = [
    NotificationModel(
      id: 'notif_1',
      userId: 'user_current',
      senderId: 'user_1',
      senderDisplayName: 'Maya Lin',
      senderHandle: 'mayalin.aura.social',
      senderAvatarUrl:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
      type: NotificationType.like,
      postId: 'post_1',
      postSnippet:
          'Welcome to Aura Social! 🦋 An open, modern social network...',
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
      isRead: false,
    ),
    NotificationModel(
      id: 'notif_2',
      userId: 'user_current',
      senderId: 'user_2',
      senderDisplayName: 'Alex Rivera',
      senderHandle: 'alex.aura.social',
      senderAvatarUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      type: NotificationType.follow,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: false,
    ),
    NotificationModel(
      id: 'notif_3',
      userId: 'user_current',
      senderId: 'user_3',
      senderDisplayName: 'Aura Official',
      senderHandle: 'aura.social',
      senderAvatarUrl:
          'https://images.unsplash.com/photo-1518770660439-4636190af475?w=150',
      type: NotificationType.repost,
      postId: 'post_1',
      postSnippet:
          'Building the next generation of social networking on Flutter...',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      isRead: true,
    ),
  ];

  static final List<ConversationModel> sampleConversations = [
    ConversationModel(
      id: 'conv_1',
      participantIds: ['user_current', 'user_1'],
      participants: {
        'user_1': const ChatParticipant(
          id: 'user_1',
          displayName: 'Maya Lin',
          handle: 'mayalin.aura.social',
          avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
        ),
      },
      lastMessageText:
          'The new UI design looks super clean! Loved the butterfly mark.',
      lastMessageSenderId: 'user_1',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 15)),
      unreadCount: 1,
    ),
    ConversationModel(
      id: 'conv_2',
      participantIds: ['user_current', 'user_2'],
      participants: {
        'user_2': const ChatParticipant(
          id: 'user_2',
          displayName: 'Alex Rivera',
          handle: 'alex.aura.social',
          avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        ),
      },
      lastMessageText:
          'Can you check the latest pull request when you have a moment?',
      lastMessageSenderId: 'user_2',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 4)),
      unreadCount: 0,
    ),
  ];
}
