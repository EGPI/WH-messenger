import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import 'message_models.dart';

extension ServerMessageModelMapper on ServerMessageModel {
  LocalMessagesCompanion toLocalCompanion() {
    final safeServerReceivedAt =
        serverReceivedAt ?? sentAt ?? createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

    return LocalMessagesCompanion(
      serverId: Value(id),
      conversationId: Value(conversationId),
      senderId: Value(senderId),
      body: Value(body),
      type: Value(type),
      status: Value(localStatus),
      clientMessageId: Value(clientMessageId),

      // Prefer real server_sequence if Laravel returns it.
      // Fallback to id because your current message history endpoint orders by id.
      serverSequence: Value(serverSequence ?? id),

      // Required local DB field. Not used for final message ordering.
      createdAt: Value(safeServerReceivedAt),

      serverReceivedAt: Value(serverReceivedAt ?? sentAt ?? createdAt),
      deliveredAt: Value(firstDeliveredAt),
      readAt: Value(firstReadAt),
      locallyUpdatedAt: Value(DateTime.now()),
    );
  }
}