import 'dart:async';
import 'dart:io';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../presentation/screens/audio_call_screen.dart';
import 'call_debug_log.dart';

final callForegroundServiceProvider = Provider<CallForegroundService>((ref) {
  return CallForegroundService(ref);
});

@pragma('vm:entry-point')
void callForegroundTaskStartCallback() {
  FlutterForegroundTask.setTaskHandler(CallForegroundTaskHandler());
}

class CallForegroundTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    // Keep this lightweight. WebRTC stays in the main app isolate.
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // No repeated work needed for now.
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    // Service stopped.
  }

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp(AudioCallScreen.routePath);
  }

  @override
  void onNotificationButtonPressed(String id) {
    // Later we can support an "End" button here.
  }
}

class CallForegroundService {
  final Ref _ref;

  bool _didInit = false;

  CallForegroundService(this._ref);

  Future<void> initialize() async {
    if (_didInit) return;

    if (!Platform.isAndroid) {
      _didInit = true;
      return;
    }

    final notificationPermission =
    await FlutterForegroundTask.checkNotificationPermission();

    if (notificationPermission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }

    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'active_audio_call',
        channelName: 'Active audio calls',
        channelDescription:
        'Keeps audio calls active while the app is in the background.',
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(10000),
        autoRunOnBoot: false,
        autoRunOnMyPackageReplaced: false,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );

    _didInit = true;
  }

  Future<void> startForCall({
    required int callId,
    required String peerName,
  }) async {
    if (!Platform.isAndroid) return;

    await initialize();

    _log('starting foreground service for callId=$callId peer=$peerName');

    final title = 'Audio call in progress';
    final text = peerName.trim().isEmpty
        ? 'Tap to return to the call'
        : 'Talking with $peerName';

    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.updateService(
        notificationTitle: title,
        notificationText: text,
      );

      _log('foreground service updated');
      return;
    }

    final result = await FlutterForegroundTask.startService(
      serviceId: 9001,
      notificationTitle: title,
      notificationText: text,
      notificationInitialRoute: AudioCallScreen.routePath,
      serviceTypes: const [
        ForegroundServiceTypes.microphone,
      ],
      callback: callForegroundTaskStartCallback,
    );

    _log('foreground service start result=$result');
  }

  Future<void> stop() async {
    if (!Platform.isAndroid) return;

    if (!await FlutterForegroundTask.isRunningService) {
      _log('foreground service already stopped');
      return;
    }

    _log('stopping foreground service');

    final result = await FlutterForegroundTask.stopService();

    _log('foreground service stop result=$result');
  }

  void _log(String message) {
    _ref.read(callDebugLogProvider.notifier).add(
      'CALL FOREGROUND: $message',
    );
  }
}