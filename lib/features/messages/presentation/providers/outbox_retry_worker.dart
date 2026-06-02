import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/app_database_provider.dart';
import '../../../../core/database/daos/chat_local_dao.dart';
import '../../data/message_api.dart';
import '../../data/message_send_error_classifier.dart';
import 'outbox_retry_state.dart';

final outboxRetryWorkerProvider =
StateNotifierProvider<OutboxRetryWorker, OutboxRetryState>((ref) {
  return OutboxRetryWorker(
    dao: ref.watch(chatLocalDaoProvider),
    api: ref.watch(messageApiProvider),
  );
});

class OutboxRetryWorker extends StateNotifier<OutboxRetryState> {
  final ChatLocalDao dao;
  final MessageApi api;

  OutboxRetryWorker({
    required this.dao,
    required this.api,
  }) : super(const OutboxRetryState.initial());

  Future<void> flushPendingOutbox() async {
    if (state.isFlushing) return;

    state = state.copyWith(
      isFlushing: true,
      lastFlushedCount: 0,
      clearError: true,
    );

    var successCount = 0;

    try {
      final items = await dao.getRetryablePendingOutboxItems();

      for (final item in items) {
        final sent = await _retryItem(item);

        if (sent) {
          successCount++;
        }
      }

      state = state.copyWith(
        isFlushing: false,
        lastFlushedCount: successCount,
      );
    } catch (error) {
      state = state.copyWith(
        isFlushing: false,
        lastFlushedCount: successCount,
        errorMessage: 'Could not retry pending messages.',
      );
    }
  }

  Future<void> retryFailedMessage({
    required String clientMessageId,
  }) async {
    if (state.isFlushing) return;

    await dao.markFailedMessagePendingAgain(
      clientMessageId: clientMessageId,
    );

    await flushPendingOutbox();
  }

  Future<bool> _retryItem(LocalOutboxData item) async {
    await dao.markOutboxSending(item.clientMessageId);

    try {
      final serverMessage = await api.sendMessage(
        conversationId: item.conversationId,
        clientMessageId: item.clientMessageId,
        body: item.body,
      );

      final serverReceivedAt = serverMessage.serverReceivedAt ??
          serverMessage.sentAt ??
          serverMessage.createdAt ??
          DateTime.fromMillisecondsSinceEpoch(0);

      await dao.markMessageAsSent(
        clientMessageId: item.clientMessageId,
        serverId: serverMessage.id,
        serverSequence: serverMessage.serverSequence ?? serverMessage.id,
        serverReceivedAt: serverReceivedAt,
      );

      return true;
    } catch (error) {
      final action = classifySendFailure(error);
      final message = sendFailureMessage(error);

      if (action == SendFailureAction.markFailed) {
        await dao.markMessageFailed(
          clientMessageId: item.clientMessageId,
          error: message,
        );
      } else {
        await dao.rescheduleOutboxItem(
          clientMessageId: item.clientMessageId,
          error: message,
          nextRetryAt: _nextRetryAt(item.attemptCount),
        );
      }

      return false;
    }
  }

  DateTime _nextRetryAt(int currentAttemptCount) {
    final nextAttempt = currentAttemptCount + 1;

    final seconds = min(
      60,
      pow(2, nextAttempt).toInt() * 5,
    );

    return DateTime.now().add(
      Duration(seconds: seconds),
    );
  }
}