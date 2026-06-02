import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'outbox_retry_worker.dart';

final outboxConnectivityBootstrapProvider = Provider<void>((ref) {
  final connectivity = Connectivity();

  Future<void> flushIfConnected() async {
    final results = await connectivity.checkConnectivity();

    final hasConnection = results.any(
          (result) => result != ConnectivityResult.none,
    );

    if (!hasConnection) return;

    await ref
        .read(outboxRetryWorkerProvider.notifier)
        .flushPendingOutbox();
  }

  Future.microtask(flushIfConnected);

  final subscription = connectivity.onConnectivityChanged.listen((results) {
    final hasConnection = results.any(
          (result) => result != ConnectivityResult.none,
    );

    if (!hasConnection) return;

    ref
        .read(outboxRetryWorkerProvider.notifier)
        .flushPendingOutbox();
  });

  ref.onDispose(subscription.cancel);
});