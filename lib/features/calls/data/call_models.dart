class CallResponseModel {
  final String? message;
  final CallModel data;

  const CallResponseModel({
    required this.message,
    required this.data,
  });

  factory CallResponseModel.fromJson(Map<String, dynamic> json) {
    return CallResponseModel(
      message: json['message']?.toString(),
      data: CallModel.fromJson(
        _asMap(json['data']),
      ),
    );
  }
}

class CallDetailsResponseModel {
  final CallModel data;

  const CallDetailsResponseModel({
    required this.data,
  });

  factory CallDetailsResponseModel.fromJson(Map<String, dynamic> json) {
    return CallDetailsResponseModel(
      data: CallModel.fromJson(
        _asMap(json['data']),
      ),
    );
  }
}

class CallModel {
  final int id;
  final int conversationId;
  final int? callerId;
  final int? calleeId;
  final String type;
  final String status;
  final DateTime? startedAt;
  final DateTime? answeredAt;
  final DateTime? endedAt;
  final int durationSeconds;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<CallParticipantModel> participants;

  const CallModel({
    required this.id,
    required this.conversationId,
    required this.callerId,
    required this.calleeId,
    required this.type,
    required this.status,
    required this.startedAt,
    required this.answeredAt,
    required this.endedAt,
    required this.durationSeconds,
    required this.createdAt,
    required this.updatedAt,
    required this.participants,
  });

  factory CallModel.fromJson(Map<String, dynamic> json) {
    return CallModel(
      id: _parseInt(json['id']) ?? 0,
      conversationId: _parseInt(json['conversation_id']) ?? 0,
      callerId: _parseInt(json['caller_id']),
      calleeId: _parseInt(json['callee_id']),
      type: json['type']?.toString() ?? 'audio',
      status: json['status']?.toString() ?? 'ringing',
      startedAt: _parseDateTime(json['started_at']),
      answeredAt: _parseDateTime(json['answered_at']),
      endedAt: _parseDateTime(json['ended_at']),
      durationSeconds: _parseInt(json['duration_seconds']) ?? 0,
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
      participants: _parseParticipants(json['participants']),
    );
  }

  bool get isAudio => type == 'audio';

  bool get isRinging => status == 'ringing';

  bool get isAccepted => status == 'accepted';

  bool get isFinished {
    return status == 'ended' ||
        status == 'rejected' ||
        status == 'missed' ||
        status == 'cancelled' ||
        status == 'failed';
  }

  bool isCaller(int? userId) {
    return userId != null && callerId == userId;
  }

  bool isCallee(int? userId) {
    return userId != null && calleeId == userId;
  }

  CallParticipantModel? participantForUser(int? userId) {
    if (userId == null) return null;

    for (final participant in participants) {
      if (participant.userId == userId) {
        return participant;
      }
    }

    return null;
  }

  CallParticipantModel? otherParticipant(int? currentUserId) {
    for (final participant in participants) {
      if (participant.userId != currentUserId) {
        return participant;
      }
    }

    return null;
  }
}

class CallParticipantModel {
  final int userId;
  final String role;
  final String status;
  final DateTime? joinedAt;
  final DateTime? leftAt;
  final CallUserModel? user;

  const CallParticipantModel({
    required this.userId,
    required this.role,
    required this.status,
    required this.joinedAt,
    required this.leftAt,
    required this.user,
  });

  factory CallParticipantModel.fromJson(Map<String, dynamic> json) {
    return CallParticipantModel(
      userId: _parseInt(json['user_id']) ?? 0,
      role: json['role']?.toString() ?? 'callee',
      status: json['status']?.toString() ?? 'ringing',
      joinedAt: _parseDateTime(json['joined_at']),
      leftAt: _parseDateTime(json['left_at']),
      user: json['user'] is Map<String, dynamic>
          ? CallUserModel.fromJson(
        json['user'] as Map<String, dynamic>,
      )
          : null,
    );
  }

  String get displayName {
    final name = user?.name.trim();

    if (name != null && name.isNotEmpty) {
      return name;
    }

    return 'User $userId';
  }
}

class CallUserModel {
  final int id;
  final String name;
  final String email;
  final String? avatarUrl;

  const CallUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
  });

  factory CallUserModel.fromJson(Map<String, dynamic> json) {
    return CallUserModel(
      id: _parseInt(json['id']) ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      avatarUrl: json['avatar_url']?.toString(),
    );
  }
}

class CallSignalRequestModel {
  final String type;
  final Map<String, dynamic> payload;

  const CallSignalRequestModel({
    required this.type,
    required this.payload,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'payload': payload,
    };
  }
}

class CallRealtimeEventModel {
  final String eventType;
  final int? eventId;
  final int? callId;
  final int? conversationId;
  final Map<String, dynamic> payload;
  final DateTime? occurredAt;

  const CallRealtimeEventModel({
    required this.eventType,
    required this.eventId,
    required this.callId,
    required this.conversationId,
    required this.payload,
    required this.occurredAt,
  });

  factory CallRealtimeEventModel.fromJson(Map<String, dynamic> json) {
    return CallRealtimeEventModel(
      eventType: json['event_type']?.toString() ?? '',
      eventId: _parseInt(json['event_id']),
      callId: _parseInt(json['call_id']),
      conversationId: _parseInt(json['conversation_id']),
      payload: _asMap(json['payload']),
      occurredAt: _parseDateTime(json['occurred_at']),
    );
  }

  CallModel? get call {
    final rawCall = payload['call'];

    if (rawCall is! Map<String, dynamic>) return null;

    return CallModel.fromJson(rawCall);
  }

  bool get isSignalEvent {
    return eventType == 'call.offer' ||
        eventType == 'call.answer' ||
        eventType == 'call.ice_candidate';
  }

  int? get fromUserId {
    return _parseInt(payload['from_user_id']);
  }

  String? get signalType {
    return payload['type']?.toString();
  }

  Map<String, dynamic> get signalPayload {
    return _asMap(payload['payload']);
  }
}

List<CallParticipantModel> _parseParticipants(dynamic value) {
  if (value is! List) return const [];

  return value
      .whereType<Map<String, dynamic>>()
      .map(CallParticipantModel.fromJson)
      .toList(growable: false);
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;

  if (value is Map) {
    return value.map(
          (key, value) => MapEntry(
        key.toString(),
        value,
      ),
    );
  }

  return <String, dynamic>{};
}

int? _parseInt(dynamic value) {
  if (value == null) return null;

  if (value is int) return value;

  if (value is num) return value.toInt();

  return int.tryParse(value.toString());
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;

  if (value is DateTime) return value;

  final text = value.toString();

  if (text.isEmpty) return null;

  return DateTime.tryParse(text);
}