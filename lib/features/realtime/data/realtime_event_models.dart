import 'dart:convert';

import '../../sync/data/sync_models.dart';

class RealtimeEventEnvelope {
  final String eventName;
  final String channelName;
  final SyncEventModel syncEvent;

  const RealtimeEventEnvelope({
    required this.eventName,
    required this.channelName,
    required this.syncEvent,
  });

  factory RealtimeEventEnvelope.fromFrame(Map<String, dynamic> frame) {
    final eventName = frame['event']?.toString() ?? '';
    final channelName = frame['channel']?.toString() ?? '';
    final rawData = frame['data'];

    final Map<String, dynamic> decodedData;

    if (rawData is String) {
      decodedData = Map<String, dynamic>.from(
        jsonDecode(rawData) as Map,
      );
    } else if (rawData is Map) {
      decodedData = Map<String, dynamic>.from(rawData);
    } else {
      throw FormatException(
        'Unsupported realtime event data type: ${rawData.runtimeType}',
      );
    }

    return RealtimeEventEnvelope(
      eventName: eventName,
      channelName: channelName,
      syncEvent: SyncEventModel.fromJson(decodedData),
    );
  }
}