import 'package:drift/drift.dart';
import 'dart:convert';
import '../../../core/database/app_database.dart';
import 'sync_models.dart';

extension SyncMessageCreatedMapper on SyncEventModel {
  LocalMessagesCompanion? toMessageCreatedCompanion() {
    if (eventType != 'message.created') return null;

    final messageId = _parseInt(payload['message_id']) ?? this.messageId;
    final conversationId =
        _parseInt(payload['conversation_id']) ?? this.conversationId;
    final senderId = _parseInt(payload['sender_id']);

    if (messageId == null || conversationId == null || senderId == null) {
      return null;
    }

    final serverReceivedAt = _parseDateTime(payload['server_received_at']);
    final sentAt = _parseDateTime(payload['sent_at']);
    final createdAt = _parseDateTime(payload['created_at']);

    final safeCreatedAt = serverReceivedAt ??
        sentAt ??
        createdAt ??
        occurredAt ??
        this.createdAt ??
        DateTime.fromMillisecondsSinceEpoch(0);

    return LocalMessagesCompanion(
      serverId: Value(messageId),
      conversationId: Value(conversationId),
      senderId: Value(senderId),
      body: Value(payload['body']?.toString() ?? ''),
      type: Value(payload['type']?.toString() ?? 'text'),
      payloadJson: Value(
        _payloadJson(payload['payload']),
      ),
      status: const Value('sent'),
      clientMessageId: Value(payload['client_message_id']?.toString()),
      serverSequence: Value(messageId),
      createdAt: Value(safeCreatedAt),
      serverReceivedAt: Value(serverReceivedAt ?? sentAt ?? createdAt),
      locallyUpdatedAt: Value(DateTime.now()),
    );
  }

  

  int? get messageCreatedMessageId {
    return _parseInt(payload['message_id']) ?? messageId;
  }

  int? get messageCreatedConversationId {
    return _parseInt(payload['conversation_id']) ?? conversationId;
  }

  int? get messageCreatedSenderId {
    return _parseInt(payload['sender_id']);
  }

  String? get messageCreatedClientMessageId {
    return payload['client_message_id']?.toString();
  }

  String get messageCreatedBody {
    return payload['body']?.toString() ?? '';
  }

  DateTime? get messageCreatedServerReceivedAt {
    return _parseDateTime(payload['server_received_at']) ??
        _parseDateTime(payload['sent_at']) ??
        _parseDateTime(payload['created_at']) ??
        occurredAt ??
        createdAt;
  }
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

String? _payloadJson(dynamic value) {
  if (value == null) return null;

  if (value is Map && value.isEmpty) return null;

  return jsonEncode(value);
}