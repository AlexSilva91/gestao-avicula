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

class HardwareMqttClient {
  const HardwareMqttClient();

  Future<EspMqttProbe> test(EspMqttConfig config) async {
    throw UnsupportedError('MQTT indisponivel nesta plataforma.');
  }

  Future<void> publishRelayCommand({
    required EspMqttConfig config,
    required int channel,
    required String state,
  }) async {
    throw UnsupportedError('MQTT indisponivel nesta plataforma.');
  }

  Future<void> publishScheduleCommand({
    required EspMqttConfig config,
    required List<int> channels,
    required List<Map<String, Object?>> schedules,
    required DateTime now,
  }) async {
    throw UnsupportedError('MQTT indisponivel nesta plataforma.');
  }
}

class HardwareMqttRuntime {
  HardwareMqttRuntime();

  Stream<EspMqttUpdate> get updates => const Stream.empty();

  bool get connected => false;

  Future<void> connect(EspMqttConfig config) async {
    throw UnsupportedError('MQTT indisponivel nesta plataforma.');
  }

  Future<void> disconnect() async {}

  Future<void> dispose() async {}

  void publishRelayCommand({required int channel, required String state}) {
    throw UnsupportedError('MQTT indisponivel nesta plataforma.');
  }

  void publishScheduleCommand({
    required List<int> channels,
    required List<Map<String, Object?>> schedules,
    required DateTime now,
  }) {
    throw UnsupportedError('MQTT indisponivel nesta plataforma.');
  }
}
