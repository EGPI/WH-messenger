import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'call_debug_log.dart';

final webRtcAudioServiceProvider = Provider<WebRtcAudioService>((ref) {
  final logger = ref.read(callDebugLogProvider.notifier);

  final service = WebRtcAudioService(
    log: logger.add,
  );

  ref.onDispose(() {
    unawaited(service.dispose());
  });

  return service;
});

typedef IceCandidateSender = Future<void> Function(
    Map<String, dynamic> candidate,
    );

typedef PeerConnectionStateListener = void Function(
    RTCPeerConnectionState state,
    );

typedef CallDebugLogger = void Function(String message);

class WebRtcAudioService {
  final CallDebugLogger _log;

  WebRtcAudioService({
    CallDebugLogger? log,
  }) : _log = log ?? ((_) {});

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;

  IceCandidateSender? _onIceCandidate;
  PeerConnectionStateListener? _onConnectionStateChanged;

  bool _isInitialized = false;
  bool _isMuted = false;
  bool _isSpeakerphoneEnabled = false;

  bool get isInitialized => _isInitialized;

  bool get isMuted => _isMuted;
  bool get isSpeakerphoneEnabled => _isSpeakerphoneEnabled;

  MediaStream? get localStream => _localStream;

  MediaStream? get remoteStream => _remoteStream;

  Future<void> initialize({
    required IceCandidateSender onIceCandidate,
    PeerConnectionStateListener? onConnectionStateChanged,
  }) async {
    if (_isInitialized) {
      _log('WEBRTC SERVICE: already initialized');
      return;
    }

    _log('WEBRTC SERVICE: requesting microphone');
    await useEarpiece();

    _onIceCandidate = onIceCandidate;
    _onConnectionStateChanged = onConnectionStateChanged;

    final localStream = await navigator.mediaDevices.getUserMedia(
      const {
        'audio': true,
        'video': false,
      },
    );

    _log(
      'WEBRTC SERVICE: microphone ready, audioTracks=${localStream.getAudioTracks().length}',
    );

    final peerConnection = await createPeerConnection(
      _iceConfiguration,
      _peerConnectionConstraints,
    );

    _log('WEBRTC SERVICE: peer connection created');

    peerConnection.onIceCandidate = _handleIceCandidate;
    peerConnection.onConnectionState = _handleConnectionState;

    peerConnection.onTrack = (RTCTrackEvent event) {
      _log(
        'WEBRTC SERVICE: remote track received, streams=${event.streams.length}',
      );

      unawaited(useEarpiece());

      if (event.streams.isNotEmpty) {
        _remoteStream = event.streams.first;
      }
    };

    final audioTracks = localStream.getAudioTracks();

    _log('WEBRTC SERVICE: adding local audio tracks=${audioTracks.length}');

    for (final track in audioTracks) {
      await peerConnection.addTrack(track, localStream);
    }

    _localStream = localStream;
    _peerConnection = peerConnection;
    _isInitialized = true;
    _isMuted = false;

    _log('WEBRTC SERVICE: initialized successfully');
  }

  Future<Map<String, dynamic>> createOffer() async {
    final peerConnection = _requirePeerConnection();

    _log('WEBRTC SERVICE: creating offer');

    final offer = await peerConnection.createOffer(
      const {
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': false,
      },
    );

    await peerConnection.setLocalDescription(offer);

    _log(
      'WEBRTC SERVICE: local offer set type=${offer.type} sdpLength=${offer.sdp?.length}',
    );

    return _descriptionToJson(offer);
  }

  Future<Map<String, dynamic>> createAnswer() async {
    final peerConnection = _requirePeerConnection();

    _log('WEBRTC SERVICE: creating answer');

    final answer = await peerConnection.createAnswer(
      const {
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': false,
      },
    );

    await peerConnection.setLocalDescription(answer);

    _log(
      'WEBRTC SERVICE: local answer set type=${answer.type} sdpLength=${answer.sdp?.length}',
    );

    return _descriptionToJson(answer);
  }

  Future<void> setRemoteDescription({
    required String type,
    required String sdp,
  }) async {
    final peerConnection = _requirePeerConnection();

    final normalizedType = type.trim().toLowerCase();
    final normalizedSdp = _normalizeSdp(sdp);

    _log(
      'WEBRTC SERVICE: setting remote description type=$normalizedType '
          'originalSdpLength=${sdp.length} normalizedSdpLength=${normalizedSdp.length} '
          'firstLine=${_firstSdpLine(normalizedSdp)} hasAudio=${_hasAudioMLine(normalizedSdp)}',
    );

    await peerConnection.setRemoteDescription(
      RTCSessionDescription(
        normalizedSdp,
        normalizedType,
      ),
    );

    _log('WEBRTC SERVICE: remote description set');
  }

  Future<void> addIceCandidate({
    required String candidate,
    required String? sdpMid,
    required int? sdpMLineIndex,
  }) async {
    final peerConnection = _requirePeerConnection();

    _log(
      'WEBRTC SERVICE: adding ICE candidate sdpMid=$sdpMid sdpMLineIndex=$sdpMLineIndex candidateLength=${candidate.length}',
    );

    await peerConnection.addCandidate(
      RTCIceCandidate(
        candidate,
        sdpMid,
        sdpMLineIndex,
      ),
    );

    _log('WEBRTC SERVICE: ICE candidate added');
  }

  Future<void> setMuted(bool muted) async {
    final stream = _localStream;

    if (stream == null) {
      _log('WEBRTC SERVICE: cannot mute, local stream is null');
      return;
    }

    for (final track in stream.getAudioTracks()) {
      track.enabled = !muted;
    }

    _isMuted = muted;

    _log('WEBRTC SERVICE: muted=$muted');
  }

  Future<void> toggleMuted() async {
    await setMuted(!_isMuted);
  }
  Future<void> setSpeakerphoneEnabled(bool enabled) async {
    _log('WEBRTC SERVICE: setting speakerphone enabled=$enabled');

    await Helper.setSpeakerphoneOn(enabled);

    _isSpeakerphoneEnabled = enabled;

    _log('WEBRTC SERVICE: speakerphone enabled=$enabled');
  }

  Future<void> useEarpiece() async {
    await setSpeakerphoneEnabled(false);
  }

  Future<void> useLoudSpeaker() async {
    await setSpeakerphoneEnabled(true);
  }

  Future<void> toggleSpeakerphone() async {
    await setSpeakerphoneEnabled(!_isSpeakerphoneEnabled);
  }

  Future<void> disposeCall() async {
    _log('WEBRTC SERVICE: disposing call');

    final peerConnection = _peerConnection;
    final localStream = _localStream;
    final remoteStream = _remoteStream;

    _peerConnection = null;
    _localStream = null;
    _remoteStream = null;
    _onIceCandidate = null;
    _onConnectionStateChanged = null;
    _isInitialized = false;
    _isMuted = false;
    _isSpeakerphoneEnabled = false;

    if (localStream != null) {
      for (final track in localStream.getTracks()) {
        await track.stop();
      }

      await localStream.dispose();

      _log('WEBRTC SERVICE: local stream disposed');
    }

    if (remoteStream != null) {
      for (final track in remoteStream.getTracks()) {
        await track.stop();
      }

      await remoteStream.dispose();

      _log('WEBRTC SERVICE: remote stream disposed');
    }

    if (peerConnection != null) {
      await peerConnection.close();
      await peerConnection.dispose();

      _log('WEBRTC SERVICE: peer connection disposed');
    }
  }

  Future<void> dispose() {
    return disposeCall();
  }

  RTCPeerConnection _requirePeerConnection() {
    final peerConnection = _peerConnection;

    if (peerConnection == null) {
      throw StateError('WebRTC peer connection has not been initialized.');
    }

    return peerConnection;
  }

  Future<void> _handleIceCandidate(RTCIceCandidate candidate) async {
    final rawCandidate = candidate.candidate;

    if (rawCandidate == null || rawCandidate.trim().isEmpty) return;

    _log('WEBRTC SERVICE: local ICE candidate generated');

    await _onIceCandidate?.call({
      'candidate': rawCandidate,
      'sdpMid': candidate.sdpMid,
      'sdpMLineIndex': candidate.sdpMLineIndex,
    });
  }

  void _handleConnectionState(RTCPeerConnectionState state) {
    _log('WEBRTC SERVICE: connection state = $state');

    _onConnectionStateChanged?.call(state);
  }

  String _normalizeSdp(String value) {
    var text = value.trim();

    // Handle accidentally double-escaped SDP from JSON/realtime layers.
    text = text
        .replaceAll(r'\r\n', '\n')
        .replaceAll(r'\n', '\n')
        .replaceAll(r'\r', '\n');

    // Normalize actual line endings.
    text = text.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

    final lines = text
        .split('\n')
        .map((line) => line.trimRight())
        .where((line) => line.trim().isNotEmpty)
        .toList(growable: false);

    if (lines.isEmpty) return '';

    // WebRTC native SDP parser is safest with CRLF line endings and final CRLF.
    return '${lines.join('\r\n')}\r\n';
  }

  String _firstSdpLine(String sdp) {
    final lines = sdp
        .split(RegExp(r'\r\n|\r|\n'))
        .where((line) => line.trim().isNotEmpty);

    if (lines.isEmpty) return '<empty>';

    return lines.first.trim();
  }

  bool _hasAudioMLine(String sdp) {
    return RegExp(r'(^|\r\n|\n)m=audio\s').hasMatch(sdp);
  }

  Map<String, dynamic> _descriptionToJson(RTCSessionDescription description) {
    final sdp = description.sdp;

    return {
      'type': description.type?.trim().toLowerCase(),
      'sdp': sdp == null ? null : _normalizeSdp(sdp),
    };
  }

  Map<String, dynamic> get _iceConfiguration {
    return const {
      'iceServers': [
        {
          'urls': [
            'stun:stun.l.google.com:19302',
          ],
        },
      ],
      'sdpSemantics': 'unified-plan',
    };
  }

  Map<String, dynamic> get _peerConnectionConstraints {
    return const {
      'mandatory': {},
      'optional': [
        {
          'DtlsSrtpKeyAgreement': true,
        },
      ],
    };
  }
}