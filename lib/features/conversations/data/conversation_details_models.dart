class ConversationDetailsResponse {
  final ConversationDetailsModel data;

  const ConversationDetailsResponse({
    required this.data,
  });

  factory ConversationDetailsResponse.fromJson(Map<String, dynamic> json) {
    return ConversationDetailsResponse(
      data: ConversationDetailsModel.fromJson(
        json['data'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}

class ConversationDetailsModel {
  final int id;
  final String type;
  final String? title;
  final String? myRole;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<ConversationParticipantModel> participants;

  const ConversationDetailsModel({
    required this.id,
    required this.type,
    required this.title,
    required this.myRole,
    required this.createdAt,
    required this.updatedAt,
    required this.participants,
  });

  factory ConversationDetailsModel.fromJson(Map<String, dynamic> json) {
    final rawParticipants = json['participants'] as List<dynamic>? ?? [];

    return ConversationDetailsModel(
      id: _requiredInt(json['id'], 'conversation.id'),
      type: json['type']?.toString() ?? 'direct',
      title: json['title']?.toString(),
      myRole: json['my_role']?.toString(),
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
      participants: rawParticipants
          .whereType<Map>()
          .map(
            (item) => ConversationParticipantModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList(),
    );
  }
}

class ConversationMemberActionResponse {
  final String message;
  final ConversationParticipantModel data;

  const ConversationMemberActionResponse({
    required this.message,
    required this.data,
  });

  factory ConversationMemberActionResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    return ConversationMemberActionResponse(
      message: json['message']?.toString() ?? '',
      data: ConversationParticipantModel.fromJson(
        json['data'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}

class ConversationParticipantModel {
  final int conversationId;
  final int userId;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? phone;
  final bool isActive;
  final DateTime? lastSeenAt;
  final String? role;
  final DateTime? joinedAt;
  final DateTime? leftAt;

  const ConversationParticipantModel({
    required this.conversationId,
    required this.userId,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.phone,
    required this.isActive,
    required this.lastSeenAt,
    required this.role,
    required this.joinedAt,
    required this.leftAt,
  });

  factory ConversationParticipantModel.fromJson(Map<String, dynamic> json) {
    return ConversationParticipantModel(
      conversationId: _parseInt(json['conversation_id']) ?? 0,
      userId: _requiredInt(json['user_id'], 'participant.user_id'),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      avatarUrl: json['avatar_url']?.toString(),
      phone: json['phone']?.toString(),
      isActive: _parseBool(json['is_active']) ?? true,
      lastSeenAt: _parseDateTime(json['last_seen_at']),
      role: json['role']?.toString(),
      joinedAt: _parseDateTime(json['joined_at']),
      leftAt: _parseDateTime(json['left_at']),
    );
  }

  ConversationParticipantModel copyWith({
    int? conversationId,
    int? userId,
    String? name,
    String? email,
    String? avatarUrl,
    String? phone,
    bool? isActive,
    DateTime? lastSeenAt,
    String? role,
    DateTime? joinedAt,
    DateTime? leftAt,
  }) {
    return ConversationParticipantModel(
      conversationId: conversationId ?? this.conversationId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      leftAt: leftAt ?? this.leftAt,
    );
  }
}

int _requiredInt(dynamic value, String fieldName) {
  final parsed = _parseInt(value);

  if (parsed == null) {
    throw FormatException('Invalid integer for $fieldName: $value');
  }

  return parsed;
}

int? _parseInt(dynamic value) {
  if (value == null) return null;

  if (value is int) return value;

  if (value is num) return value.toInt();

  if (value is String) {
    return int.tryParse(value);
  }

  return null;
}

bool? _parseBool(dynamic value) {
  if (value == null) return null;

  if (value is bool) return value;

  if (value is num) return value != 0;

  if (value is String) {
    final normalized = value.trim().toLowerCase();

    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
  }

  return null;
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;

  final text = value.toString();

  if (text.isEmpty) return null;

  return DateTime.tryParse(text);
}