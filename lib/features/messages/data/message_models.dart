class MessageHistoryResponse {
  final List<ServerMessageModel> data;
  final MessageHistoryMeta meta;

  const MessageHistoryResponse({
    required this.data,
    required this.meta,
  });

  factory MessageHistoryResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'] as List<dynamic>? ?? [];

    return MessageHistoryResponse(
      data: rawData
          .map(
            (item) => ServerMessageModel.fromJson(
          item as Map<String, dynamic>,
        ),
      )
          .toList(),
      meta: MessageHistoryMeta.fromJson(
        json['meta'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}

class MessageHistoryMeta {
  final int limit;
  final bool hasMore;
  final int? nextBeforeMessageId;

  const MessageHistoryMeta({
    required this.limit,
    required this.hasMore,
    required this.nextBeforeMessageId,
  });

  factory MessageHistoryMeta.fromJson(Map<String, dynamic> json) {
    return MessageHistoryMeta(
      limit: _parseInt(json['limit']) ?? 30,
      hasMore: json['has_more'] as bool? ?? false,
      nextBeforeMessageId: _parseInt(json['next_before_message_id']),
    );
  }
}

class ServerMessageModel {
  final int id;
  final int conversationId;
  final int senderId;
  final int? serverSequence;
  final String? clientMessageId;
  final String type;
  final String body;
  final DateTime? serverReceivedAt;
  final DateTime? sentAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String status;
  final ServerMessageSenderModel? sender;
  final List<ServerMessageReceiptModel> receipts;
  final Map<String, dynamic> payload;

  const ServerMessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.clientMessageId,
    required this.serverSequence,
    required this.type,
    required this.body,
    required this.serverReceivedAt,
    required this.sentAt,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.sender,
    required this.receipts,
    required this.payload,
  });

  factory ServerMessageModel.fromJson(Map<String, dynamic> json) {
    final rawReceipts = json['receipts'] as List<dynamic>? ?? [];

    return ServerMessageModel(
      id: _requiredInt(json['id'], 'message.id'),
      conversationId: _requiredInt(
        json['conversation_id'],
        'message.conversation_id',
      ),
      senderId: _requiredInt(json['sender_id'], 'message.sender_id'),
      clientMessageId: json['client_message_id']?.toString(),
      serverSequence: _parseInt(json['server_sequence']),
      type: json['type']?.toString() ?? 'text',
      body: json['body']?.toString() ?? '',
      payload: _parseMap(json['payload']),
      serverReceivedAt: _parseDateTime(json['server_received_at']),
      sentAt: _parseDateTime(json['sent_at']),
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
      status: json['status']?.toString() ?? 'sent',
      sender: json['sender'] is Map
          ? ServerMessageSenderModel.fromJson(
        Map<String, dynamic>.from(json['sender'] as Map),
      )
          : null,
      receipts: rawReceipts
          .whereType<Map>()
          .map(
            (item) => ServerMessageReceiptModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList(),
    );
  }

  DateTime? get firstDeliveredAt {
    for (final receipt in receipts) {
      if (receipt.deliveredAt != null) {
        return receipt.deliveredAt;
      }
    }

    return null;
  }

  DateTime? get firstReadAt {
    for (final receipt in receipts) {
      if (receipt.readAt != null) {
        return receipt.readAt;
      }
    }

    return null;
  }

  String get localStatus {
    if (firstReadAt != null) return 'read';
    if (firstDeliveredAt != null) return 'delivered';

    return status.isEmpty ? 'sent' : status;
  }
}

class ServerMessageSenderModel {
  final int id;
  final String name;
  final String email;

  const ServerMessageSenderModel({
    required this.id,
    required this.name,
    required this.email,
  });

  factory ServerMessageSenderModel.fromJson(Map<String, dynamic> json) {
    return ServerMessageSenderModel(
      id: _requiredInt(json['id'], 'sender.id'),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }
}

class ServerMessageReceiptModel {
  final int userId;
  final DateTime? deliveredAt;
  final DateTime? readAt;

  const ServerMessageReceiptModel({
    required this.userId,
    required this.deliveredAt,
    required this.readAt,
  });

  factory ServerMessageReceiptModel.fromJson(Map<String, dynamic> json) {
    return ServerMessageReceiptModel(
      userId: _requiredInt(json['user_id'], 'receipt.user_id'),
      deliveredAt: _parseDateTime(json['delivered_at']),
      readAt: _parseDateTime(json['read_at']),
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

Map<String, dynamic> _parseMap(dynamic value) {
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