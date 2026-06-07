import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'chat_sync_controller.dart';

final chatSyncBootstrapProvider = Provider<void>((ref) {
  final connectivity = Connectivity();

  Future<void> syncIfConnected() async {
    final results = await connectivity.checkConnectivity();

    final hasConnection = results.any(
          (result) => result != ConnectivityResult.none,
    );

    if (!hasConnection) return;

    await ref.read(chatSyncControllerProvider.notifier).syncNow();
  }

  Future.microtask(syncIfConnected);

  final subscription = connectivity.onConnectivityChanged.listen((results) {
    final hasConnection = results.any(
          (result) => result != ConnectivityResult.none,
    );

    if (!hasConnection) return;

    ref.read(chatSyncControllerProvider.notifier).syncNow();
  });

  ref.onDispose(subscription.cancel);
});