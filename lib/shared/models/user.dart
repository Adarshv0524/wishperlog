class User {
  final String uid;
  final String email;
  final String displayName;
  final Map<String, dynamic> googleTokens;
  final String? telegramChatId;
  final String digestTime;
  final Map<String, dynamic> overlayPosition;
  final bool overlayVisible;
  final String fcmToken;
  final DateTime createdAt;

  User({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.googleTokens,
    this.telegramChatId,
    required this.digestTime,
    required this.overlayPosition,
    required this.overlayVisible,
    required this.fcmToken,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'display_name': displayName,
      'google_tokens': googleTokens,
      'telegram_chat_id': telegramChatId,
      'digest_time': digestTime,
      'overlay_position': overlayPosition,
      'overlay_visible': overlayVisible,
      'fcm_token': fcmToken,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'],
      email: json['email'],
      displayName: json['display_name'],
      googleTokens: json['google_tokens'],
      telegramChatId: json['telegram_chat_id'],
      digestTime: json['digest_time'],
      overlayPosition: json['overlay_position'],
      overlayVisible: json['overlay_visible'],
      fcmToken: json['fcm_token'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
