import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/operations_repository.dart';
import '../../../core/platform/notification_service.dart';
import 'hardware_mqtt_client.dart';

final hardwareEspMonitorServiceProvider = Provider<HardwareEspMonitorService>((
  ref,
) {
  final service = HardwareEspMonitorService(ref.watch(databaseProvider));
  ref.onDispose(service.dispose);
  return service;
});

class HardwareEspMonitorService {
  HardwareEspMonitorService(this._db);

  static const _systemActor = 'system';
  static const _alertCooldown = Duration(minutes: 15);

  final AppDatabase _db;
  final HardwareMqttRuntime _runtime = HardwareMqttRuntime();
  final Map<String, DateTime> _lastAlerts = {};
  StreamSubscription<List<AppSetting>>? _settingsSubscription;
  StreamSubscription<EspMqttUpdate>? _mqttSubscription;
  EspMqttConfig? _config;
  Map<String, String> _settings = const {};
  bool _started = false;
  bool _connecting = false;

  bool get connected => _runtime.connected;

  Stream<EspMqttUpdate> get updates => _runtime.updates;

  Future<void> start() async {
    if (_started) return;
    _started = true;
    _mqttSubscription = _runtime.updates.listen(_handleMqttUpdate);
    _settingsSubscription = _db.watchAppSettings().listen((settings) {
      _settings = {for (final setting in settings) setting.key: setting.value};
      unawaited(_syncRuntime());
    });
  }

  Future<void> dispose() async {
    await _settingsSubscription?.cancel();
    await _mqttSubscription?.cancel();
    await _runtime.dispose();
  }

  Future<void> connectNow([EspMqttConfig? override]) async {
    if (override != null && override.isUsable) {
      _config = override;
      await _runtime.connect(override);
      await _saveSetting('hardware_esp_mqtt_runtime_status', 'CONNECTED');
      return;
    }
    await _syncRuntime();
  }

  Future<void> publishRelayCommand({
    required EspMqttConfig config,
    required int channel,
    required String state,
  }) async {
    await connectNow(config);
    _runtime.publishRelayCommand(channel: channel, state: state);
  }

  Future<EspMqttUpdate> publishScheduleCommand({
    required EspMqttConfig config,
    required List<int> channels,
    required List<Map<String, Object?>> schedules,
    required DateTime now,
  }) async {
    await connectNow(config);
    return _runtime.publishScheduleCommand(
      channels: channels,
      schedules: schedules,
      now: now,
    );
  }

  Future<EspMqttUpdate> publishWifiScanCommand({
    required EspMqttConfig config,
    required DateTime now,
  }) async {
    await connectNow(config);
    return _runtime.publishWifiScanCommand(now: now);
  }

  Future<void> _syncRuntime() async {
    if (_connecting) return;
    _connecting = true;
    try {
      final config = _configFromSettings(_settings);
      if (!config.isUsable) {
        _config = config;
        await _runtime.disconnect();
        return;
      }
      if (_sameConfig(_config, config) && _runtime.connected) return;
      _config = config;
      await _runtime.connect(config);
      await _saveSetting('hardware_esp_mqtt_runtime_status', 'CONNECTED');
      await _saveSetting(
        'hardware_esp_mqtt_runtime_message',
        'MQTT global conectado em ${config.host}:${config.port}',
      );
    } catch (error, stackTrace) {
      debugPrint('SELETO ESP monitor MQTT failed: $error');
      debugPrint('$stackTrace');
      await _saveSetting('hardware_esp_mqtt_runtime_status', 'FAILED');
      await _saveSetting('hardware_esp_mqtt_runtime_message', '$error');
    } finally {
      _connecting = false;
    }
  }

  EspMqttConfig _configFromSettings(Map<String, String> values) =>
      EspMqttConfig(
        enabled: values['hardware_esp_mqtt_enabled'] == 'true',
        host: values['hardware_esp_mqtt_host']?.trim() ?? '',
        port: int.tryParse(values['hardware_esp_mqtt_port'] ?? '') ?? 1883,
        baseTopic:
            (values['hardware_esp_mqtt_base_topic']?.trim().isNotEmpty ?? false)
            ? values['hardware_esp_mqtt_base_topic']!.trim()
            : 'seleto/esp32',
        deviceId:
            (values['hardware_esp_mqtt_device_id']?.trim().isNotEmpty ?? false)
            ? values['hardware_esp_mqtt_device_id']!.trim()
            : 'SELETO-RELE-01',
        username: values['hardware_esp_mqtt_username']?.trim() ?? '',
        password: values['hardware_esp_mqtt_password'] ?? '',
      );

  bool _sameConfig(EspMqttConfig? current, EspMqttConfig next) =>
      current != null &&
      current.enabled == next.enabled &&
      current.host == next.host &&
      current.port == next.port &&
      current.baseTopic == next.baseTopic &&
      current.deviceId == next.deviceId &&
      current.username == next.username &&
      current.password == next.password;

  Future<void> _handleMqttUpdate(EspMqttUpdate update) async {
    try {
      if (update.topic == 'runtime/connected') {
        await _saveSetting('hardware_esp_mqtt_runtime_status', 'CONNECTED');
        return;
      }
      if (update.topic == 'runtime/disconnected') {
        await _handleEspOffline('MQTT desconectado do ESP32.', update.payload);
        return;
      }
      if (update.topic == 'runtime/stale') {
        final seconds = update.payload['secondsWithoutPacket'] ?? '?';
        await _handleEspOffline(
          'ESP32 sem telemetria MQTT há ${seconds}s.',
          update.payload,
        );
        return;
      }

      await _saveSetting('hardware_esp_last_mqtt_topic', update.topic);
      if (update.retained) {
        await _saveSetting(
          'hardware_esp_mqtt_runtime_message',
          'Pacote MQTT retido recebido; aguardando telemetria viva do ESP32.',
        );
        return;
      }
      await _saveSetting(
        'hardware_esp_last_mqtt_packet_at',
        update.receivedAt.toIso8601String(),
      );

      if (update.topic.endsWith('/status')) {
        await _handleStatus(update);
      } else if (update.topic.endsWith('/relay/state')) {
        await _handleRelayState(update);
      } else if (update.topic.endsWith('/command/ack')) {
        await _handleCommandAck(update);
      } else if (update.topic.endsWith('/sensors')) {
        await _handleSensors(update);
      } else if (update.topic.endsWith('/schedule/ack') ||
          update.topic.endsWith('/schedule/state')) {
        await _saveSetting(
          'hardware_lighting_schedule_last_mqtt_message',
          _message(update.payload, 'Agenda atualizada via MQTT.'),
        );
      }
    } catch (error, stackTrace) {
      debugPrint('SELETO ESP monitor update failed: $error');
      debugPrint('$stackTrace');
    }
  }

  Future<void> _handleStatus(EspMqttUpdate update) async {
    final online = update.payload['online'] != false;
    final message = _message(update.payload, 'Status MQTT recebido do ESP32.');
    await _saveSetting('hardware_esp_last_status_message', message);
    if (!online) {
      await _handleEspOffline(message, update.payload);
      return;
    }
    await _saveSetting(
      'hardware_esp_last_seen_at',
      update.receivedAt.toIso8601String(),
    );
    await _saveSetting('hardware_esp_mqtt_runtime_status', 'ONLINE');
    final ip = update.payload['ip']?.toString().trim();
    if (ip != null && ip.isNotEmpty) {
      await _saveSetting('hardware_lighting_endpoint', ip);
      await _saveSetting('hardware_ventilation_endpoint', ip);
    }
  }

  Future<void> _handleRelayState(EspMqttUpdate update) async {
    final rawRelays = update.payload['relays'];
    if (rawRelays is! List) return;
    for (final relay in rawRelays) {
      if (relay is! Map) continue;
      final channel = int.tryParse((relay['channel'] ?? '').toString());
      if (channel == null) continue;
      final on = relay['on'] == true;
      await _db.recordRelayState(
        channel: channel,
        on: on,
        transport: 'MQTT',
        payload: update.payload,
        actorId: _systemActor,
      );
      if (channel >= 1 && channel <= 4) {
        await _saveSetting(
          'hardware_lighting_channel_${channel}_last_test_state',
          on ? 'ON' : 'OFF',
        );
        await _saveSetting(
          'hardware_lighting_channel_${channel}_last_seen_at',
          update.receivedAt.toIso8601String(),
        );
      } else if (channel >= 5 && channel <= 12) {
        final ventilationChannel = channel - 4;
        await _saveSetting(
          'hardware_ventilation_channel_${ventilationChannel}_last_test_state',
          on ? 'ON' : 'OFF',
        );
        await _saveSetting(
          'hardware_ventilation_channel_${ventilationChannel}_last_seen_at',
          update.receivedAt.toIso8601String(),
        );
      }
    }
  }

  Future<void> _handleCommandAck(EspMqttUpdate update) async {
    if ((update.payload['command'] ?? '').toString() != 'relay') return;
    final channel = int.tryParse((update.payload['channel'] ?? '').toString());
    final on = update.payload['on'];
    if (channel == null || on is! bool) return;
    await _handleRelayState(
      EspMqttUpdate(
        topic: update.topic.replaceFirst('/command/ack', '/relay/state'),
        payload: {
          'relays': [
            {'channel': channel, 'on': on},
          ],
          'message': _message(update.payload, 'Comando confirmado pelo ESP.'),
        },
        receivedAt: update.receivedAt,
      ),
    );
  }

  Future<void> _handleSensors(EspMqttUpdate update) async {
    await _saveSetting(
      'hardware_sensors_last_seen_at',
      update.receivedAt.toIso8601String(),
    );
    final environment = update.payload['environment'];
    if (environment is Map) {
      final data = Map<String, Object?>.from(environment);
      await _maybeAlertSensorOffline(
        settingKey: 'hardware_alert_environment_sensor_enabled',
        type: 'environment_sensor_offline',
        title: 'Sensor de ambiente sem leitura',
        ok: data['ok'],
        payload: update.payload,
      );
      await _recordMetric(
        source: 'environment',
        metric: 'air_temperature_c',
        value: data['airTemperatureC'] ?? data['temperatureC'],
        unit: '°C',
        settingKey: 'hardware_environment_last_temperature_c',
        payload: update.payload,
      );
      await _recordMetric(
        source: 'environment',
        metric: 'air_humidity_percent',
        value: data['airHumidityPercent'] ?? data['humidityPercent'],
        unit: '%',
        settingKey: 'hardware_environment_last_humidity_percent',
        payload: update.payload,
      );
    }

    final water = update.payload['water'];
    if (water is Map) {
      final data = Map<String, Object?>.from(water);
      await _maybeAlertSensorOffline(
        settingKey: 'hardware_alert_water_sensor_enabled',
        type: 'water_sensor_offline',
        title: 'Sensor de água sem leitura',
        ok: data['ok'],
        payload: update.payload,
      );
      await _recordMetric(
        source: 'water',
        metric: 'water_level_percent',
        value: data['levelPercent'],
        unit: '%',
        settingKey: 'hardware_water_last_level_percent',
        payload: update.payload,
      );
      await _recordMetric(
        source: 'water',
        metric: 'water_temperature_c',
        value: data['temperatureC'],
        unit: '°C',
        settingKey: 'hardware_water_last_temperature_c',
        payload: update.payload,
      );
      await _recordMetric(
        source: 'water',
        metric: 'water_ph',
        value: data['ph'],
        unit: 'pH',
        settingKey: 'hardware_water_last_ph',
        payload: update.payload,
      );
      await _recordMetric(
        source: 'water',
        metric: 'water_tds_ppm',
        value: data['tdsPpm'],
        unit: 'ppm',
        settingKey: 'hardware_water_last_tds_ppm',
        payload: update.payload,
      );
    }
  }

  Future<void> _recordMetric({
    required String source,
    required String metric,
    required Object? value,
    required String unit,
    required String settingKey,
    required Map<String, Object?> payload,
  }) async {
    final number = _doublePayload(value);
    if (number == null) return;
    await _db.recordSensorReading(
      source: source,
      metric: metric,
      value: number,
      unit: unit,
      transport: 'MQTT',
      payload: payload,
      actorId: _systemActor,
    );
    await _saveSetting(settingKey, number.toString());
  }

  Future<void> _handleEspOffline(
    String message,
    Map<String, Object?> payload,
  ) async {
    await _saveSetting('hardware_esp_mqtt_runtime_status', 'OFFLINE');
    await _saveSetting('hardware_esp_mqtt_runtime_message', message);
    if (!_settingEnabled(
      'hardware_alert_esp_offline_enabled',
      fallback: true,
    )) {
      return;
    }
    await _alertOnce(
      key: 'esp_offline',
      severity: 'WARN',
      type: 'esp_offline',
      title: 'ESP32 offline',
      message: message,
      source: 'MQTT',
      payload: payload,
    );
  }

  Future<void> _maybeAlertSensorOffline({
    required String settingKey,
    required String type,
    required String title,
    required Object? ok,
    required Map<String, Object?> payload,
  }) async {
    if (ok != false || !_settingEnabled(settingKey)) return;
    await _alertOnce(
      key: type,
      severity: 'WARN',
      type: type,
      title: title,
      message: 'O ESP respondeu, mas este sensor não retornou leitura válida.',
      source: 'MQTT',
      payload: payload,
    );
  }

  Future<void> _alertOnce({
    required String key,
    required String severity,
    required String type,
    required String title,
    required String message,
    required String source,
    required Map<String, Object?> payload,
  }) async {
    final now = DateTime.now();
    final last = _lastAlerts[key];
    if (last != null && now.difference(last) < _alertCooldown) return;
    _lastAlerts[key] = now;
    await _db.recordAutomationEvent(
      severity: severity,
      type: type,
      title: title,
      message: message,
      source: source,
      payload: payload,
      actorId: _systemActor,
    );
    await _notify(title, message);
  }

  Future<void> _notify(String title, String body) async {
    try {
      final service = NotificationService();
      if (!service.nativeSupported) return;
      if (!await service.prepareMessages()) return;
      await service.scheduleMessage(
        id: DateTime.now().millisecondsSinceEpoch.remainder(2147483647),
        title: title,
        body: body,
        at: DateTime.now().add(const Duration(seconds: 1)),
      );
    } catch (error) {
      debugPrint('SELETO ESP monitor notification failed: $error');
    }
  }

  bool _settingEnabled(String key, {bool fallback = false}) {
    final value = _settings[key]?.trim().toLowerCase();
    if (value == null || value.isEmpty) return fallback;
    return value == 'true' || value == '1' || value == 'on';
  }

  Future<void> _saveSetting(String key, String value) =>
      _db.saveAppSetting(key, value, _systemActor);

  String _message(Map<String, Object?> payload, String fallback) {
    final message = payload['message']?.toString().trim();
    if (message != null && message.isNotEmpty) return message;
    final error = payload['error']?.toString().trim();
    if (error != null && error.isNotEmpty) return '$fallback: $error';
    return fallback;
  }

  double? _doublePayload(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString().replaceAll(',', '.') ?? '');
  }
}
