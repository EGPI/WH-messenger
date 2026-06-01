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

      // API has no server_sequence yet.
      // Use message id as the stable server ordering value for now.
      serverSequence: Value(id),

      // Required local DB field.
      // This is not used for final message ordering.
      createdAt: Value(safeServerReceivedAt),

      serverReceivedAt: Value(serverReceivedAt ?? sentAt),
      deliveredAt: Value(firstDeliveredAt),
      readAt: Value(firstReadAt),
      locallyUpdatedAt: Value(DateTime.now()),
    );
  }
}