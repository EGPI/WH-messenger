class RealtimeConfig {
  const RealtimeConfig._();

  static const String appKey = 'wh-messenger-key-prod';

  static const String host = 'wh-egpi.com';

  static const int port = 443;

  static const bool useTls = true;

  static const String _pathPrefix = '/messenger-api';

  static const String authEndpoint =
      'https://wh-egpi.com/messenger-api/broadcasting/auth';

  static String get websocketUrl {
    final scheme = useTls ? 'wss' : 'ws';

    return '$scheme://$host$_pathPrefix/app/$appKey'
        '?protocol=7'
        '&client=flutter'
        '&version=1.0'
        '&flash=false';
  }
}
