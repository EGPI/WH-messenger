import 'package:flutter_riverpod/flutter_riverpod.dart';

final callDebugLogProvider =
NotifierProvider<CallDebugLogController, List<String>>(
  CallDebugLogController.new,
);

class CallDebugLogController extends Notifier<List<String>> {
  @override
  List<String> build() {
    return const [];
  }

  void add(String message) {
    final now = DateTime.now();

    final timestamp =
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}.'
        '${now.millisecond.toString().padLeft(3, '0')}';

    final line = '[$timestamp] $message';

    final next = [
      ...state,
      line,
    ];

    state = next.length > 300 ? next.sublist(next.length - 300) : next;
  }

  void clear() {
    state = const [];
  }

  String exportText() {
    return state.join('\n');
  }
}