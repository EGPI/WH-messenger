class SyncResponse {
  final List<SyncEventModel> events;
  final int nextEventId;
  final bool hasMore;

  const SyncResponse({
    required this.events,
    required this.nextEventId,
    required this.hasMore,
  });

  factory SyncResponse.fromJson(Map<String, dynamic> json) {
    final rawEvents = json['events'] as List<dynamic>? ?? [];

    return SyncResponse(
      events: rawEvents
          .whereType<Map>()
          .map(
            (item) => SyncEventModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList(),
      nextEventId: _parseInt(json['next_event_id']) ?? 0,
      hasMore: json['has_more'] as bool? ?? false,
    );
  }
}

class SyncEventModel {
  final int id;
  final String eventType;
  final int? conversationId;
  final int? messageId;
  final Map<String, dynamic> payload;
  final DateTime? occurredAt;
  final DateTime? createdAt;

  const SyncEventModel({
    required this.id,
    required this.eventType,
    required this.conversationId,
    required this.messageId,
    required this.payload,
    required this.occurredAt,
    required this.createdAt,
  });

  factory SyncEventModel.fromJson(Map<String, dynamic> json) {
    final rawPayload = json['payload'];

    return SyncEventModel(
      id: _requiredInt(json['id'], 'sync_event.id'),
      eventType: json['event_type']?.toString() ?? '',
      conversationId: _parseInt(json['conversation_id']),
      messageId: _parseInt(json['message_id']),
      payload: rawPayload is Map
          ? Map<String, dynamic>.from(rawPayload)
          : const {},
      occurredAt: _parseDateTime(json['occurred_at']),
      createdAt: _parseDateTime(json['created_at']),
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

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;

  final text = value.toString();
  if (text.isEmpty) return null;

  return DateTime.tryParse(text);
}