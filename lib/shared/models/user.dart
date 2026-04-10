// lib/shared/models/user.dart  — FULL REPLACEMENT

/// Envelope for the pre-built, channel-specific outbox stored on the user doc.
/// The Worker reads this; never re-calculates.
class MessageState {
  /// Pre-rendered Telegram HTML string. Null when no content is available.
  final String? telegram;

  /// Reserved for WhatsApp plain-text. Null until provider is wired.
  final String? whatsapp;

  /// Reserved for Email HTML. Null until provider is wired.
  final String? email;

  /// UTC epoch-ms when this state was last written by the app.
  final DateTime? computedAt;

  const MessageState({
    this.telegram,
    this.whatsapp,
    this.email,
    this.computedAt,
  });

  bool get isEmpty =>
      (telegram == null || telegram!.isEmpty) &&
      (whatsapp == null || whatsapp!.isEmpty) &&
      (email == null || email!.isEmpty);

  Map<String, dynamic> toJson() => {
    'telegram':    telegram,
    'whatsapp':    whatsapp,
    'email':       email,
    'computed_at': computedAt?.toIso8601String(),
  };

  factory MessageState.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const MessageState();
    return MessageState(
      telegram:   json['telegram']  as String?,
      whatsapp:   json['whatsapp']  as String?,
      email:      json['email']     as String?,
      computedAt: json['computed_at'] is String
          ? DateTime.tryParse(json['computed_at'] as String)
          : null,
    );
  }

  MessageState copyWith({
    String? telegram,
    String? whatsapp,
    String? email,
    DateTime? computedAt,
  }) => MessageState(
    telegram:   telegram   ?? this.telegram,
    whatsapp:   whatsapp   ?? this.whatsapp,
    email:      email      ?? this.email,
    computedAt: computedAt ?? this.computedAt,
  );
}

class User {
  final String uid;
  final String email;
  final String displayName;
  final Map<String, dynamic> googleTokens;
  final String? telegramChatId;

  /// Legacy single-slot field — kept for backward compat with existing docs.
  final String digestTime;

  /// Multi-slot schedule in "HH:MM" format (UTC). Source of truth for Worker.
  final List<String> digestSlots;

  final Map<String, dynamic> overlayPosition;
  final bool overlayVisible;
  final String fcmToken;
  final DateTime createdAt;

  /// Pre-built outbox — the Worker reads this instead of re-calculating.
  final MessageState messageState;

  const User({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.googleTokens,
    this.telegramChatId,
    required this.digestTime,
    this.digestSlots = const [],
    required this.overlayPosition,
    required this.overlayVisible,
    required this.fcmToken,
    required this.createdAt,
    this.messageState = const MessageState(),
  });

  Map<String, dynamic> toJson() => {
    'uid':              uid,
    'email':            email,
    'display_name':     displayName,
    'google_tokens':    googleTokens,
    'telegram_chat_id': telegramChatId,
    'digest_time':      digestTime,
    'digest_slots':     digestSlots,
    'overlay_position': overlayPosition,
    'overlay_visible':  overlayVisible,
    'fcm_token':        fcmToken,
    'created_at':       createdAt.toIso8601String(),
    'message_state':    messageState.toJson(),
  };

  factory User.fromJson(Map<String, dynamic> json) {
    // digest_slots: accept List<dynamic> or fall back to single digestTime entry.
    final rawSlots = json['digest_slots'];
    final slots = rawSlots is List
        ? rawSlots.whereType<String>().toList()
        : <String>[];

    return User(
      uid:             json['uid']           as String? ?? '',
      email:           json['email']         as String? ?? '',
      displayName:     json['display_name']  as String? ?? '',
      googleTokens:    (json['google_tokens'] as Map<String, dynamic>?) ?? {},
      telegramChatId:  json['telegram_chat_id'] as String?,
      digestTime:      json['digest_time']   as String? ?? '09:00',
      digestSlots:     slots.isNotEmpty ? slots
          : [(json['digest_time'] as String? ?? '09:00')],
      overlayPosition: (json['overlay_position'] as Map<String, dynamic>?) ?? {},
      overlayVisible:  json['overlay_visible'] as bool? ?? false,
      fcmToken:        json['fcm_token']     as String? ?? '',
      createdAt:       json['created_at'] is String
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      messageState: MessageState.fromJson(
        json['message_state'] as Map<String, dynamic>?,
      ),
    );
  }

  User copyWith({
    String?                  uid,
    String?                  email,
    String?                  displayName,
    Map<String, dynamic>?    googleTokens,
    String?                  telegramChatId,
    String?                  digestTime,
    List<String>?            digestSlots,
    Map<String, dynamic>?    overlayPosition,
    bool?                    overlayVisible,
    String?                  fcmToken,
    DateTime?                createdAt,
    MessageState?            messageState,
  }) => User(
    uid:             uid             ?? this.uid,
    email:           email           ?? this.email,
    displayName:     displayName     ?? this.displayName,
    googleTokens:    googleTokens    ?? this.googleTokens,
    telegramChatId:  telegramChatId  ?? this.telegramChatId,
    digestTime:      digestTime      ?? this.digestTime,
    digestSlots:     digestSlots     ?? this.digestSlots,
    overlayPosition: overlayPosition ?? this.overlayPosition,
    overlayVisible:  overlayVisible  ?? this.overlayVisible,
    fcmToken:        fcmToken        ?? this.fcmToken,
    createdAt:       createdAt       ?? this.createdAt,
    messageState:    messageState    ?? this.messageState,
  );
}