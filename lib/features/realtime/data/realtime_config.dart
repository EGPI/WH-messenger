class RealtimeConfig {
  const RealtimeConfig._();

  static const String appKey = 'local-chat-key';

  // For real Android phone testing, do not use 127.0.0.1.
  static const String host = '192.168.1.33';

  static const int port = 8080;

  static const bool useTls = false;

  static const String authEndpoint =
      'http://192.168.1.33:8000/broadcasting/auth';

  static String get websocketUrl {
    final scheme = useTls ? 'wss' : 'ws';

    return '$scheme://$host:$port/app/$appKey'
        '?protocol=7'
        '&client=flutter'
        '&version=1.0';
  }
}