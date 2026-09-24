import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

class EspDeviceProbe {
  const EspDeviceProbe({
    required this.endpoint,
    required this.deviceId,
    required this.message,
    required this.payload,
  });

  final String endpoint;
  final String deviceId;
  final String message;
  final Map<String, Object?> payload;
}

class EspScaleReading {
  const EspScaleReading({
    required this.weightKg,
    required this.message,
    required this.payload,
  });

  final double weightKg;
  final String message;
  final Map<String, Object?> payload;
}

class EspRelayResult {
  const EspRelayResult({
    required this.channel,
    required this.on,
    required this.message,
    required this.payload,
  });

  final int channel;
  final bool on;
  final String message;
  final Map<String, Object?> payload;
}

class EspChannelSchedule {
  const EspChannelSchedule({
    required this.channel,
    required this.enabled,
    required this.morningEnabled,
    required this.morningOnTime,
    required this.morningOffTime,
    required this.eveningEnabled,
    required this.eveningOnTime,
    required this.eveningOffTime,
    this.daysMask = 127,
  });

  final int channel;
  final bool enabled;
  final bool morningEnabled;
  final String morningOnTime;
  final String morningOffTime;
  final bool eveningEnabled;
  final String eveningOnTime;
  final String eveningOffTime;
  final int daysMask;
}

class HardwareEspClient {
  const HardwareEspClient();

  static const _probeTimeout = Duration(milliseconds: 850);
  static const _requestTimeout = Duration(seconds: 3);
  static const _knownSetupEndpoint = 'http://192.168.4.1';
  static const _networkChannel = MethodChannel('seleto/network');

  Future<EspDeviceProbe?> discover({
    void Function(String message)? onLog,
  }) async {
    onLog?.call('SYS> iniciando descoberta automatica do ESP32');

    final directProbe = await _tryProbe(_knownSetupEndpoint);
    if (directProbe != null) {
      onLog?.call('ESP> encontrado no AP padrao ${directProbe.endpoint}');
      return directProbe;
    }

    final baseHosts = await _localSubnetBaseHosts();
    if (baseHosts.isEmpty) {
      onLog?.call('SYS> rede local nao identificada');
      onLog?.call('SYS> conecte no Wi-Fi GRANJA-SELETO-SETUP e tente de novo');
      return null;
    }

    for (final baseHost in baseHosts) {
      onLog?.call('SCAN> varrendo $baseHost.1 ate $baseHost.254');
      final probe = await _scanSubnet(baseHost, onLog: onLog);
      if (probe != null) return probe;
    }

    onLog?.call('SYS> ESP32 nao respondeu nesta rede');
    onLog?.call('SYS> fallback: Wi-Fi GRANJA-SELETO-SETUP / seleto1234');
    return null;
  }

  Future<EspDeviceProbe> ping(String endpoint) async {
    final normalized = _normalizeEndpoint(endpoint);
    final payload = await _getJson('$normalized/api/status');
    final deviceId =
        (payload['deviceId'] ?? payload['id'] ?? 'GRANJA-SELETO-ESP32')
            .toString();
    final ip = (payload['ip'] ?? normalized).toString();
    return EspDeviceProbe(
      endpoint: normalized,
      deviceId: deviceId,
      message: 'ESP conectado: $deviceId em $ip',
      payload: payload,
    );
  }

  Future<EspScaleReading> readScale(String endpoint) async {
    final normalized = _normalizeEndpoint(endpoint);
    final payload = await _getJson('$normalized/api/scale');
    final rawWeight = payload['weightKg'];
    final weight = rawWeight is num
        ? rawWeight.toDouble()
        : double.tryParse(rawWeight?.toString() ?? '') ?? 0;
    return EspScaleReading(
      weightKg: weight,
      message: 'Leitura recebida do ESP: ${weight.toStringAsFixed(3)} kg',
      payload: payload,
    );
  }

  Future<EspRelayResult> setRelay({
    required String endpoint,
    required int channel,
    required bool turnOn,
  }) async {
    return _sendRelay(
      endpoint: endpoint,
      channel: channel,
      state: turnOn ? 'on' : 'off',
    );
  }

  Future<EspRelayResult> pulseRelay({
    required String endpoint,
    required int channel,
  }) async {
    return _sendRelay(endpoint: endpoint, channel: channel, state: 'pulse');
  }

  Future<Map<String, Object?>> syncTime(String endpoint, DateTime now) {
    final normalized = _normalizeEndpoint(endpoint);
    final epoch = now.millisecondsSinceEpoch ~/ 1000;
    return _postForm('$normalized/api/time', {'epoch': '$epoch'});
  }

  Future<Map<String, Object?>> setChannelSchedule({
    required String endpoint,
    required EspChannelSchedule schedule,
  }) {
    final normalized = _normalizeEndpoint(endpoint);
    return _postForm('$normalized/api/channel_schedule', {
      'channel': '${schedule.channel}',
      'enabled': schedule.enabled ? '1' : '0',
      'en1': schedule.morningEnabled ? '1' : '0',
      'on1': schedule.morningOnTime,
      'off1': schedule.morningOffTime,
      'en2': schedule.eveningEnabled ? '1' : '0',
      'on2': schedule.eveningOnTime,
      'off2': schedule.eveningOffTime,
      'days': '${schedule.daysMask}',
    });
  }

  Future<EspRelayResult> _sendRelay({
    required String endpoint,
    required int channel,
    required String state,
  }) async {
    final normalized = _normalizeEndpoint(endpoint);
    final payload = await _postForm('$normalized/api/relay', {
      'channel': '$channel',
      'state': state,
    });
    if (payload['ok'] == false) {
      throw HttpException('ESP recusou comando do canal $channel: $payload');
    }
    final on = payload['on'] == true;
    return EspRelayResult(
      channel: channel,
      on: on,
      message: state == 'pulse'
          ? 'Pulso do canal $channel confirmado pelo ESP'
          : 'Canal $channel confirmado pelo ESP: ${on ? 'ON' : 'OFF'}',
      payload: payload,
    );
  }

  Future<EspDeviceProbe?> _scanSubnet(
    String baseHost, {
    void Function(String message)? onLog,
  }) async {
    const batchSize = 24;
    for (var start = 1; start <= 254; start += batchSize) {
      final end = (start + batchSize - 1).clamp(1, 254);
      final futures = [
        for (var host = start; host <= end; host++)
          _tryProbe('http://$baseHost.$host'),
      ];
      final probes = await Future.wait(futures);
      for (final probe in probes) {
        if (probe != null) {
          onLog?.call('ESP> handshake OK em ${probe.endpoint}');
          return probe;
        }
      }
    }
    return null;
  }

  Future<EspDeviceProbe?> _tryProbe(String endpoint) async {
    try {
      final probe = await ping(endpoint).timeout(_probeTimeout);
      final app = probe.payload['app']?.toString();
      final deviceId = probe.deviceId.toUpperCase();
      final isSeletoEsp =
          app == 'GRANJA_SELETO' || deviceId.contains('GRANJA-SELETO');
      return isSeletoEsp ? probe : null;
    } catch (_) {
      return null;
    }
  }

  Future<List<String>> _localSubnetBaseHosts() async {
    final interfaces = await NetworkInterface.list(
      includeLinkLocal: false,
      type: InternetAddressType.IPv4,
    );
    final bases = <String>{};
    for (final interface in interfaces) {
      for (final address in interface.addresses) {
        final parts = address.address.split('.');
        if (parts.length != 4) continue;
        if (parts.first == '127' || parts.first == '169') continue;
        bases.add('${parts[0]}.${parts[1]}.${parts[2]}');
      }
    }
    return bases.toList()..sort();
  }

  Future<Map<String, Object?>> _getJson(String url) async {
    final client = HttpClient();
    final boundToWifi = await _bindWifiIfLocalEndpoint(url);
    client.connectionTimeout = _requestTimeout;
    try {
      final request = await client
          .getUrl(Uri.parse(url))
          .timeout(_requestTimeout);
      final response = await request.close().timeout(_requestTimeout);
      return _decodeResponse(response);
    } finally {
      client.close(force: true);
      if (boundToWifi) await _clearNetworkBinding();
    }
  }

  Future<Map<String, Object?>> _postForm(
    String url,
    Map<String, String> fields,
  ) async {
    final client = HttpClient();
    final boundToWifi = await _bindWifiIfLocalEndpoint(url);
    client.connectionTimeout = _requestTimeout;
    try {
      final body = fields.entries
          .map(
            (entry) =>
                '${Uri.encodeQueryComponent(entry.key)}='
                '${Uri.encodeQueryComponent(entry.value)}',
          )
          .join('&');
      final encodedBody = utf8.encode(body);
      final request = await client
          .postUrl(Uri.parse(url))
          .timeout(_requestTimeout);
      request.headers.contentType = ContentType(
        'application',
        'x-www-form-urlencoded',
        charset: 'utf-8',
      );
      request.contentLength = encodedBody.length;
      request.add(encodedBody);
      final response = await request.close().timeout(_requestTimeout);
      return _decodeResponse(response);
    } finally {
      client.close(force: true);
      if (boundToWifi) await _clearNetworkBinding();
    }
  }

  Future<Map<String, Object?>> _decodeResponse(
    HttpClientResponse response,
  ) async {
    final body = await utf8.decodeStream(response).timeout(_requestTimeout);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException('ESP respondeu ${response.statusCode}: $body');
    }
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('Resposta do ESP nao veio em JSON.');
    }
    return decoded;
  }

  String _normalizeEndpoint(String endpoint) {
    final trimmed = endpoint.trim();
    if (trimmed.isEmpty) return _knownSetupEndpoint;
    final withScheme =
        trimmed.startsWith('http://') || trimmed.startsWith('https://')
        ? trimmed
        : 'http://$trimmed';
    return withScheme.endsWith('/')
        ? withScheme.substring(0, withScheme.length - 1)
        : withScheme;
  }

  Future<bool> _bindWifiIfLocalEndpoint(String url) async {
    if (!Platform.isAndroid || !_isLocalEndpoint(url)) return false;
    try {
      return await _networkChannel.invokeMethod<bool>('bindProcessToWifi') ??
          false;
    } catch (_) {
      return false;
    }
  }

  Future<void> _clearNetworkBinding() async {
    if (!Platform.isAndroid) return;
    try {
      await _networkChannel.invokeMethod<void>('clearNetworkBinding');
    } catch (_) {}
  }

  bool _isLocalEndpoint(String url) {
    final host = Uri.tryParse(url)?.host;
    if (host == null || host.isEmpty) return false;
    if (host == '192.168.4.1' || host.startsWith('192.168.')) return true;
    if (host.startsWith('10.')) return true;
    final parts = host.split('.');
    if (parts.length != 4 || parts.first != '172') return false;
    final second = int.tryParse(parts[1]);
    return second != null && second >= 16 && second <= 31;
  }
}
