import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class EspMqttConfig {
  const EspMqttConfig({
    required this.enabled,
    required this.host,
    required this.port,
    required this.baseTopic,
    required this.deviceId,
    this.username = '',
    this.password = '',
  });

  final bool enabled;
  final String host;
  final int port;
  final String baseTopic;
  final String deviceId;
  final String username;
  final String password;

  bool get isUsable =>
      enabled && host.trim().isNotEmpty && baseTopic.trim().isNotEmpty;
}

class EspMqttProbe {
  const EspMqttProbe({
    required this.connected,
    required this.message,
    this.topic,
  });

  final bool connected;
  final String message;
  final String? topic;
}

class EspMqttUpdate {
  const EspMqttUpdate({
    required this.topic,
    required this.payload,
    required this.receivedAt,
  });

  final String topic;
  final Map<String, Object?> payload;
  final DateTime receivedAt;
}

bool _mqttUsesTls(EspMqttConfig config) => config.port == 8883;

class HardwareMqttClient {
  const HardwareMqttClient();

  static const _connectTimeout = Duration(seconds: 6);
  static const _statusTimeout = Duration(seconds: 5);

  Future<EspMqttProbe> test(EspMqttConfig config) async {
    final client = _client(config);
    StreamSubscription<List<MqttReceivedMessage<MqttMessage>>>? subscription;
    try {
      await _connect(client, config);
      final statusTopic = _topic(config, 'status');
      final completer = Completer<EspMqttProbe>();
      client.subscribe(statusTopic, MqttQos.atLeastOnce);
      subscription = client.updates?.listen((events) {
        for (final event in events) {
          if (event.topic != statusTopic) continue;
          final message = event.payload as MqttPublishMessage;
          final payload = MqttPublishPayload.bytesToStringAsString(
            message.payload.message,
          );
          if (!completer.isCompleted) {
            completer.complete(
              EspMqttProbe(
                connected: true,
                topic: event.topic,
                message: 'MQTT conectado: $payload',
              ),
            );
          }
        }
      });
      _publishJson(client, _topic(config, 'ping'), {
        'source': 'app',
        'ts': DateTime.now().toIso8601String(),
      });
      return await completer.future.timeout(
        _statusTimeout,
        onTimeout: () => EspMqttProbe(
          connected: true,
          topic: statusTopic,
          message: 'MQTT conectado ao broker; aguardando status do ESP.',
        ),
      );
    } finally {
      await subscription?.cancel();
      client.disconnect();
    }
  }

  Future<void> publishRelayCommand({
    required EspMqttConfig config,
    required int channel,
    required String state,
  }) async {
    final client = _client(config);
    try {
      await _connect(client, config);
      _publishJson(client, _topic(config, 'relay/command'), {
        'channel': channel,
        'state': state,
        'source': 'app',
        'ts': DateTime.now().toIso8601String(),
      });
      await MqttUtilities.asyncSleep(1);
    } finally {
      client.disconnect();
    }
  }

  Future<void> publishScheduleCommand({
    required EspMqttConfig config,
    required List<int> channels,
    required List<Map<String, Object?>> schedules,
    required DateTime now,
  }) async {
    final client = _client(config);
    try {
      await _connect(client, config);
      _publishJson(client, _topic(config, 'schedule/command'), {
        'action': 'set',
        'channels': channels,
        'schedules': schedules,
        'epoch': now.millisecondsSinceEpoch ~/ 1000,
        'source': 'app',
        'ts': now.toIso8601String(),
      });
      await MqttUtilities.asyncSleep(1);
    } finally {
      client.disconnect();
    }
  }

  MqttServerClient _client(EspMqttConfig config) {
    final clientId =
        'seleto-app-${DateTime.now().millisecondsSinceEpoch % 100000}';
    final client = MqttServerClient.withPort(
      config.host.trim(),
      clientId,
      config.port,
    );
    client
      ..logging(on: false)
      ..secure = _mqttUsesTls(config)
      ..keepAlivePeriod = 20
      ..connectTimeoutPeriod = _connectTimeout.inMilliseconds
      ..autoReconnect = false;
    if (_mqttUsesTls(config)) {
      client.securityContext = SecurityContext.defaultContext;
    }
    client.connectionMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    return client;
  }

  Future<void> _connect(MqttServerClient client, EspMqttConfig config) async {
    final username = config.username.trim();
    final password = config.password;
    final result = await client
        .connect(username.isEmpty ? null : username, password)
        .timeout(_connectTimeout);
    if (result?.state != MqttConnectionState.connected) {
      throw StateError('Broker MQTT recusou a conexao: ${result?.state}.');
    }
  }

  void _publishJson(
    MqttServerClient client,
    String topic,
    Map<String, Object?> payload,
  ) {
    final builder = MqttClientPayloadBuilder()
      ..addUTF8String(jsonEncode(payload));
    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  String _topic(EspMqttConfig config, String suffix) {
    final base = config.baseTopic.trim().replaceAll(RegExp(r'/+$'), '');
    final device = config.deviceId.trim().isEmpty
        ? 'SELETO-RELE-01'
        : config.deviceId.trim();
    return '$base/$device/$suffix';
  }
}

class HardwareMqttRuntime {
  HardwareMqttRuntime();

  static const _connectTimeout = Duration(seconds: 6);
  static const _staleTimeout = Duration(seconds: 45);

  final _updates = StreamController<EspMqttUpdate>.broadcast();
  MqttServerClient? _client;
  EspMqttConfig? _config;
  StreamSubscription<List<MqttReceivedMessage<MqttMessage>>>? _subscription;
  Timer? _watchdog;
  DateTime? _lastPacketAt;
  bool _staleEmitted = false;

  Stream<EspMqttUpdate> get updates => _updates.stream;

  bool get connected =>
      _client?.connectionStatus?.state == MqttConnectionState.connected;

  Future<void> connect(EspMqttConfig config) async {
    if (!config.isUsable) {
      throw StateError('Configuracao MQTT incompleta.');
    }
    if (connected && _sameConfig(config)) return;
    await disconnect();
    _config = config;
    final client = _clientFor(config);
    _client = client;
    final username = config.username.trim();
    final result = await client
        .connect(username.isEmpty ? null : username, config.password)
        .timeout(_connectTimeout);
    if (result?.state != MqttConnectionState.connected) {
      client.disconnect();
      throw StateError('Broker MQTT recusou a conexao: ${result?.state}.');
    }
    for (final suffix in [
      'status',
      'sensors',
      'relay/state',
      'schedule/ack',
      'schedule/state',
      'command/ack',
    ]) {
      client.subscribe(_topic(config, suffix), MqttQos.atLeastOnce);
    }
    _subscription = client.updates?.listen(_handleUpdates);
    _markPacket();
    _startWatchdog();
    publishJson('ping', {
      'source': 'app',
      'ts': DateTime.now().toIso8601String(),
    });
  }

  Future<void> disconnect() async {
    _watchdog?.cancel();
    _watchdog = null;
    await _subscription?.cancel();
    _subscription = null;
    _client?.disconnect();
    _client = null;
  }

  Future<void> dispose() async {
    await disconnect();
    await _updates.close();
  }

  void publishRelayCommand({required int channel, required String state}) {
    publishJson('relay/command', {
      'channel': channel,
      'state': state,
      'source': 'app',
      'ts': DateTime.now().toIso8601String(),
    });
  }

  void publishScheduleCommand({
    required List<int> channels,
    required List<Map<String, Object?>> schedules,
    required DateTime now,
  }) {
    publishJson('schedule/command', {
      'action': 'set',
      'channels': channels,
      'schedules': schedules,
      'epoch': now.millisecondsSinceEpoch ~/ 1000,
      'source': 'app',
      'ts': now.toIso8601String(),
    });
  }

  void publishJson(String suffix, Map<String, Object?> payload) {
    final client = _client;
    final config = _config;
    if (client == null || config == null || !connected) {
      throw StateError('MQTT nao esta conectado em tempo real.');
    }
    final builder = MqttClientPayloadBuilder()
      ..addUTF8String(jsonEncode(payload));
    client.publishMessage(
      _topic(config, suffix),
      MqttQos.atLeastOnce,
      builder.payload!,
    );
  }

  MqttServerClient _clientFor(EspMqttConfig config) {
    final clientId =
        'seleto-runtime-${DateTime.now().millisecondsSinceEpoch % 100000}';
    final client = MqttServerClient.withPort(
      config.host.trim(),
      clientId,
      config.port,
    );
    client
      ..logging(on: false)
      ..secure = _mqttUsesTls(config)
      ..keepAlivePeriod = 20
      ..connectTimeoutPeriod = _connectTimeout.inMilliseconds
      ..autoReconnect = true
      ..resubscribeOnAutoReconnect = true
      ..onDisconnected = () {
        if (_updates.isClosed) return;
        _updates.add(
          EspMqttUpdate(
            topic: 'runtime/disconnected',
            payload: {'online': false},
            receivedAt: DateTime.now(),
          ),
        );
      }
      ..onConnected = () {
        final current = _config;
        if (current == null || _updates.isClosed) return;
        _updates.add(
          EspMqttUpdate(
            topic: 'runtime/connected',
            payload: {'online': true},
            receivedAt: DateTime.now(),
          ),
        );
      };
    if (_mqttUsesTls(config)) {
      client.securityContext = SecurityContext.defaultContext;
    }
    client.connectionMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    return client;
  }

  void _handleUpdates(List<MqttReceivedMessage<MqttMessage>> events) {
    for (final event in events) {
      _markPacket();
      final message = event.payload as MqttPublishMessage;
      final raw = MqttPublishPayload.bytesToStringAsString(
        message.payload.message,
      );
      Object? decoded;
      try {
        decoded = jsonDecode(raw);
      } catch (_) {
        decoded = {'raw': raw};
      }
      if (decoded is! Map) {
        decoded = {'value': decoded};
      }
      if (_updates.isClosed) return;
      _updates.add(
        EspMqttUpdate(
          topic: event.topic,
          payload: Map<String, Object?>.from(decoded),
          receivedAt: DateTime.now(),
        ),
      );
    }
  }

  void _markPacket() {
    _lastPacketAt = DateTime.now();
    _staleEmitted = false;
  }

  void _startWatchdog() {
    _watchdog?.cancel();
    _watchdog = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_updates.isClosed || !connected) return;
      final lastPacketAt = _lastPacketAt;
      if (lastPacketAt == null) return;
      final age = DateTime.now().difference(lastPacketAt);
      if (age < _staleTimeout || _staleEmitted) return;
      _staleEmitted = true;
      _updates.add(
        EspMqttUpdate(
          topic: 'runtime/stale',
          payload: {
            'online': false,
            'secondsWithoutPacket': age.inSeconds,
          },
          receivedAt: DateTime.now(),
        ),
      );
    });
  }

  bool _sameConfig(EspMqttConfig next) {
    final current = _config;
    return current != null &&
        current.enabled == next.enabled &&
        current.host == next.host &&
        current.port == next.port &&
        current.baseTopic == next.baseTopic &&
        current.deviceId == next.deviceId &&
        current.username == next.username &&
        current.password == next.password;
  }

  String _topic(EspMqttConfig config, String suffix) {
    final base = config.baseTopic.trim().replaceAll(RegExp(r'/+$'), '');
    final device = config.deviceId.trim().isEmpty
        ? 'SELETO-RELE-01'
        : config.deviceId.trim();
    return '$base/$device/$suffix';
  }
}
