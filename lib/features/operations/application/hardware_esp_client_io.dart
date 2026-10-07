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

class EspEnvironmentReading {
  const EspEnvironmentReading({
    required this.airTemperatureC,
    required this.airHumidityPercent,
    required this.zones,
    required this.message,
    required this.payload,
  });

  final double airTemperatureC;
  final double airHumidityPercent;
  final List<EspEnvironmentZoneReading> zones;
  final String message;
  final Map<String, Object?> payload;
}

class EspEnvironmentZoneReading {
  const EspEnvironmentZoneReading({
    required this.id,
    required this.label,
    required this.temperatureC,
    required this.humidityPercent,
  });

  final String id;
  final String label;
  final double temperatureC;
  final double humidityPercent;
}

class EspWaterReading {
  const EspWaterReading({
    required this.levelPercent,
    required this.temperatureC,
    required this.ph,
    required this.tdsPpm,
    required this.chlorineOrpMv,
    required this.message,
    required this.payload,
  });

  final double levelPercent;
  final double temperatureC;
  final double ph;
  final double tdsPpm;
  final double? chlorineOrpMv;
  final String message;
  final Map<String, Object?> payload;
}

class EspRelayResult {
  const EspRelayResult({
    required this.endpoint,
    required this.channel,
    required this.on,
    required this.message,
    required this.payload,
  });

  final String endpoint;
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

  static const _probeTimeout = Duration(milliseconds: 1500);
  static const _requestTimeout = Duration(seconds: 12);
  static const _relayTimeout = Duration(seconds: 3);
  static const _wifiConfigTimeout = Duration(seconds: 35);
  static const _knownSetupEndpoint = 'http://192.168.4.1';
  static const _networkChannel = MethodChannel('seleto/network');

  Future<EspDeviceProbe?> discover({
    void Function(String message)? onLog,
  }) async {
    onLog?.call('SYS> testando AP do ESP e Wi-Fi atual');

    final directProbe = await _tryProbe(_knownSetupEndpoint);
    if (directProbe != null) {
      onLog?.call('ESP> encontrado no AP padrao ${directProbe.endpoint}');
      return directProbe;
    }

    final baseHosts = await _localSubnetBaseHosts();
    if (baseHosts.isEmpty) {
      onLog?.call('SYS> Wi-Fi atual nao identificado');
      onLog?.call('SYS> conecte no Wi-Fi SELETO-SETUP e tente de novo');
      return null;
    }

    for (final baseHost in baseHosts) {
      onLog?.call(
        'SCAN> varrendo somente Wi-Fi atual $baseHost.1 ate $baseHost.254',
      );
      final probe = await _scanSubnet(baseHost, onLog: onLog);
      if (probe != null) return probe;
    }

    onLog?.call('SYS> ESP32 nao respondeu nesta rede');
    onLog?.call('SYS> fallback: Wi-Fi SELETO-SETUP / seleto1234');
    return null;
  }

  Future<EspDeviceProbe> ping(String endpoint) async {
    final normalized = _normalizeEndpoint(endpoint);
    Object? lastError;
    for (var attempt = 1; attempt <= 3; attempt++) {
      try {
        return await _pingOnce(normalized);
      } catch (error) {
        lastError = error;
        if (attempt == 3) break;
        await Future<void>.delayed(Duration(milliseconds: 220 * attempt));
      }
    }
    throw HttpException(
      'ESP nao confirmou handshake em $normalized apos nova tentativa: $lastError',
    );
  }

  Future<EspDeviceProbe> _pingOnce(String normalized) async {
    final payload = await _getJson('$normalized/api/status');
    final deviceId = (payload['deviceId'] ?? payload['id'] ?? 'SELETO-ESP32')
        .toString();
    final reportedIp = (payload['ip'] ?? '').toString().trim();
    final setupIp = (payload['setupApIp'] ?? '').toString().trim();
    final endpointHost = Uri.parse(normalized).host;
    final ip = reportedIp.isNotEmpty
        ? reportedIp
        : setupIp.isNotEmpty
        ? setupIp
        : endpointHost;
    final resolvedEndpoint = reportedIp.isNotEmpty
        ? _normalizeEndpoint(reportedIp)
        : normalized;
    return EspDeviceProbe(
      endpoint: resolvedEndpoint,
      deviceId: deviceId,
      message: 'ESP conectado: $deviceId em $ip',
      payload: payload,
    );
  }

  Future<EspEnvironmentReading> readEnvironment(String endpoint) async {
    final normalized = _normalizeEndpoint(endpoint);
    final payload = await _getJson('$normalized/api/environment');
    final temperature = _doubleValue(payload['airTemperatureC']);
    final humidity = _doubleValue(payload['airHumidityPercent']);
    final zones = _environmentZones(payload, temperature, humidity);
    return EspEnvironmentReading(
      airTemperatureC: temperature,
      airHumidityPercent: humidity,
      zones: zones,
      message:
          'Ambiente: ${zones.length} ponto(s) / ${temperature.toStringAsFixed(1)} °C / ${humidity.toStringAsFixed(1)}%',
      payload: payload,
    );
  }

  Future<EspWaterReading> readWater(String endpoint) async {
    final normalized = _normalizeEndpoint(endpoint);
    final payload = await _getJson('$normalized/api/water');
    final level = _doubleValue(payload['levelPercent']);
    final temperature = _doubleValue(payload['temperatureC']);
    final ph = _doubleValue(payload['ph']);
    final tds = _doubleValue(payload['tdsPpm']);
    final chlorineOrp = _optionalDoubleValue(
      payload['chlorineOrpMv'] ??
          payload['orpMv'] ??
          payload['chlorineMv'] ??
          payload['cloroOrpMv'],
    );
    return EspWaterReading(
      levelPercent: level,
      temperatureC: temperature,
      ph: ph,
      tdsPpm: tds,
      chlorineOrpMv: chlorineOrp,
      message:
          'Água: ${level.toStringAsFixed(0)}% / ${temperature.toStringAsFixed(1)} °C / pH ${ph.toStringAsFixed(2)} / ${tds.toStringAsFixed(0)} ppm${chlorineOrp == null ? '' : ' / ORP ${chlorineOrp.toStringAsFixed(0)} mV'}',
      payload: payload,
    );
  }

  Future<Map<String, Object?>> readSensors(String endpoint) {
    final normalized = _normalizeEndpoint(endpoint);
    return _getJson('$normalized/api/sensors');
  }

  Future<Map<String, Object?>> readRemoteSync(String endpoint) {
    final normalized = _normalizeEndpoint(endpoint);
    return _getJson('$normalized/api/remote');
  }

  Future<Map<String, Object?>> configureRemoteSync({
    required String endpoint,
    required bool enabled,
    required String url,
    required String token,
    required String priority,
  }) {
    final normalized = _normalizeEndpoint(endpoint);
    return _postForm('$normalized/api/remote', {
      'enabled': enabled ? '1' : '0',
      'url': url,
      'token': token,
      'priority': priority,
    });
  }

  Future<Map<String, Object?>> configureMqtt({
    required String endpoint,
    required bool enabled,
    required String host,
    required int port,
    required String baseTopic,
    required String deviceId,
    required String username,
    required String password,
  }) {
    final normalized = _normalizeEndpoint(endpoint);
    return _postForm('$normalized/api/mqtt', {
      'enabled': enabled ? '1' : '0',
      'host': host,
      'port': '$port',
      'baseTopic': baseTopic,
      'deviceId': deviceId,
      'username': username,
      'password': password,
    });
  }

  Future<Map<String, Object?>> configureWifi({
    required String endpoint,
    required String ssid,
    required String password,
  }) {
    final normalized = _normalizeEndpoint(endpoint);
    return _postForm('$normalized/api/wifi', {
      'ssid': ssid,
      'password': password,
    }, timeout: _wifiConfigTimeout);
  }

  Future<Map<String, Object?>> disconnectWifi({
    required String endpoint,
    bool clearCredentials = true,
  }) {
    final normalized = _normalizeEndpoint(endpoint);
    return _postForm('$normalized/api/wifi/disconnect', {
      'clear': clearCredentials ? '1' : '0',
    });
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
      ..._scheduleFields(schedule),
    });
  }

  Future<Map<String, Object?>> setGroupSchedule({
    required String endpoint,
    required List<int> channels,
    required EspChannelSchedule schedule,
  }) {
    final normalized = _normalizeEndpoint(endpoint);
    return _postForm('$normalized/api/group_schedule', {
      'channels': channels.join(','),
      ..._scheduleFields(schedule),
    });
  }

  Map<String, String> _scheduleFields(EspChannelSchedule schedule) => {
    'enabled': schedule.enabled ? '1' : '0',
    'en1': schedule.morningEnabled ? '1' : '0',
    'on1': schedule.morningOnTime,
    'off1': schedule.morningOffTime,
    'en2': schedule.eveningEnabled ? '1' : '0',
    'on2': schedule.eveningOnTime,
    'off2': schedule.eveningOffTime,
    'days': '${schedule.daysMask}',
  };

  Future<EspRelayResult> _sendRelay({
    required String endpoint,
    required int channel,
    required String state,
  }) async {
    Object? lastError;
    final candidates = <String>[
      _normalizeEndpoint(endpoint),
      _knownSetupEndpoint,
    ];

    final probe = await _tryProbe(candidates.first);
    if (probe != null) {
      candidates.insert(0, probe.endpoint);
    }

    for (final commandEndpoint in candidates.toSet()) {
      final maxAttempts = commandEndpoint == _knownSetupEndpoint ? 1 : 2;
      for (var attempt = 1; attempt <= maxAttempts; attempt++) {
        try {
          return await _sendRelayOnce(
            endpoint: commandEndpoint,
            channel: channel,
            state: state,
          );
        } catch (error) {
          lastError = error;
          if (attempt == maxAttempts) break;
          await Future<void>.delayed(Duration(milliseconds: 120 * attempt));
        }
      }
    }

    final discovered = await discover(onLog: (_) {});
    if (discovered != null &&
        !candidates.toSet().contains(discovered.endpoint)) {
      try {
        return await _sendRelayOnce(
          endpoint: discovered.endpoint,
          channel: channel,
          state: state,
        );
      } catch (error) {
        lastError = error;
      }
    }

    throw HttpException(
      'ESP nao confirmou o canal $channel apos nova tentativa: $lastError',
    );
  }

  Future<EspRelayResult> _sendRelayOnce({
    required String endpoint,
    required int channel,
    required String state,
  }) async {
    final normalized = _normalizeEndpoint(endpoint);
    final payload = await _postForm('$normalized/api/relay', {
      'channel': '$channel',
      'state': state,
    }, timeout: _relayTimeout);
    if (payload['ok'] == false) {
      throw HttpException('ESP recusou comando do canal $channel: $payload');
    }
    final on = payload['on'] == true;
    return EspRelayResult(
      endpoint: normalized,
      channel: channel,
      on: on,
      message: state == 'pulse'
          ? 'Pulso do canal $channel confirmado pelo ESP'
          : 'Canal $channel confirmado pelo ESP: ${on ? 'ON' : 'OFF'}',
      payload: payload,
    );
  }

  double _doubleValue(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  double? _optionalDoubleValue(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  List<EspEnvironmentZoneReading> _environmentZones(
    Map<String, Object?> payload,
    double fallbackTemperature,
    double fallbackHumidity,
  ) {
    final explicitZones = payload['zones'] ?? payload['points'];
    if (explicitZones is List) {
      final zones = [
        for (final item in explicitZones)
          if (item is Map)
            _environmentZoneFromMap(Map<String, Object?>.from(item)),
      ].whereType<EspEnvironmentZoneReading>().toList();
      if (zones.isNotEmpty) return zones;
    }

    final aliases = {
      'galpaoCentro': ('galpao_centro', 'Galpão centro'),
      'galpao': ('galpao_centro', 'Galpão centro'),
      'pinteiroPiso1': ('pinteiro_piso_1', 'Pinteiro piso 1'),
      'pinteiro1': ('pinteiro_piso_1', 'Pinteiro piso 1'),
      'pinteiroPiso2': ('pinteiro_piso_2', 'Pinteiro piso 2'),
      'pinteiro2': ('pinteiro_piso_2', 'Pinteiro piso 2'),
    };
    final zones = <EspEnvironmentZoneReading>[];
    for (final entry in aliases.entries) {
      final value = payload[entry.key];
      if (value is Map) {
        final mapped = _environmentZoneFromMap(
          Map<String, Object?>.from(value),
          id: entry.value.$1,
          label: entry.value.$2,
        );
        if (mapped != null) zones.add(mapped);
      }
    }
    if (zones.isNotEmpty) return zones;

    return [
      EspEnvironmentZoneReading(
        id: 'galpao_centro',
        label: 'Galpão centro',
        temperatureC: fallbackTemperature,
        humidityPercent: fallbackHumidity,
      ),
    ];
  }

  EspEnvironmentZoneReading? _environmentZoneFromMap(
    Map<String, Object?> data, {
    String? id,
    String? label,
  }) {
    final temperature = _optionalDoubleValue(
      data['temperatureC'] ?? data['airTemperatureC'] ?? data['tempC'],
    );
    final humidity = _optionalDoubleValue(
      data['humidityPercent'] ?? data['airHumidityPercent'] ?? data['humidity'],
    );
    if (temperature == null || humidity == null) return null;
    return EspEnvironmentZoneReading(
      id: id ?? (data['id'] ?? data['key'] ?? '').toString(),
      label: label ?? (data['label'] ?? data['name'] ?? 'Ambiente').toString(),
      temperatureC: temperature,
      humidityPercent: humidity,
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
      final normalizedApp = app?.trim().toUpperCase();
      final isSeletoEsp =
          normalizedApp == 'SELETO' ||
          normalizedApp == 'GRANJA_SELETO' ||
          deviceId.contains('SELETO');
      return isSeletoEsp ? probe : null;
    } catch (_) {
      return null;
    }
  }

  Future<List<String>> _localSubnetBaseHosts() async {
    if (Platform.isAndroid) {
      try {
        final wifiIp = await _networkChannel.invokeMethod<String>(
          'wifiIpv4Address',
        );
        final base = _baseHostFromIpv4(wifiIp);
        return base == null ? const [] : [base];
      } catch (_) {
        return const [];
      }
    }

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

  String? _baseHostFromIpv4(String? address) {
    final parts = address?.split('.') ?? const [];
    if (parts.length != 4) return null;
    if (parts.first == '127' || parts.first == '169') return null;
    return '${parts[0]}.${parts[1]}.${parts[2]}';
  }

  Future<Map<String, Object?>> _getJson(String url) async {
    if (Platform.isAndroid && _isLocalEndpoint(url)) {
      return _rawHttpJson(method: 'GET', url: url);
    }
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
    Map<String, String> fields, {
    Duration timeout = _requestTimeout,
  }) async {
    if (Platform.isAndroid && _isLocalEndpoint(url)) {
      final body = fields.entries
          .map(
            (entry) =>
                '${Uri.encodeQueryComponent(entry.key)}='
                '${Uri.encodeQueryComponent(entry.value)}',
          )
          .join('&');
      return _rawHttpJson(
        method: 'POST',
        url: url,
        body: body,
        contentType: 'application/x-www-form-urlencoded; charset=utf-8',
        timeout: timeout,
      );
    }
    final client = HttpClient();
    final boundToWifi = await _bindWifiIfLocalEndpoint(url);
    client.connectionTimeout = timeout;
    try {
      final body = fields.entries
          .map(
            (entry) =>
                '${Uri.encodeQueryComponent(entry.key)}='
                '${Uri.encodeQueryComponent(entry.value)}',
          )
          .join('&');
      final encodedBody = utf8.encode(body);
      final request = await client.postUrl(Uri.parse(url)).timeout(timeout);
      request.headers.contentType = ContentType(
        'application',
        'x-www-form-urlencoded',
        charset: 'utf-8',
      );
      request.contentLength = encodedBody.length;
      request.add(encodedBody);
      final response = await request.close().timeout(timeout);
      return _decodeResponse(response, timeout: timeout);
    } finally {
      client.close(force: true);
      if (boundToWifi) await _clearNetworkBinding();
    }
  }

  Future<Map<String, Object?>> _decodeResponse(
    HttpClientResponse response, {
    Duration timeout = _requestTimeout,
  }) async {
    final body = await utf8.decodeStream(response).timeout(timeout);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException('ESP respondeu ${response.statusCode}: $body');
    }
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('Resposta do ESP nao veio em JSON.');
    }
    return decoded;
  }

  Future<Map<String, Object?>> _rawHttpJson({
    required String method,
    required String url,
    String body = '',
    String contentType = 'application/json',
    Duration timeout = _requestTimeout,
  }) async {
    final uri = Uri.parse(url);
    final port = uri.hasPort ? uri.port : 80;
    final basePath = uri.path.isEmpty ? '/' : uri.path;
    final path = uri.hasQuery && uri.query.isNotEmpty
        ? '$basePath?${uri.query}'
        : basePath;
    final boundToWifi = await _bindWifiIfLocalEndpoint(url);
    Socket? socket;
    try {
      socket = await Socket.connect(uri.host, port, timeout: timeout);
      final bodyBytes = utf8.encode(body);
      final request = StringBuffer()
        ..write('$method $path HTTP/1.0\r\n')
        ..write('Host: ${uri.host}\r\n')
        ..write('Connection: close\r\n')
        ..write('Accept: application/json\r\n');
      if (method == 'POST') {
        request
          ..write('Content-Type: $contentType\r\n')
          ..write('Content-Length: ${bodyBytes.length}\r\n');
      }
      request.write('\r\n');
      socket.add(utf8.encode(request.toString()));
      if (bodyBytes.isNotEmpty) socket.add(bodyBytes);
      await socket.flush().timeout(timeout);

      final responseBytes = <int>[];
      await for (final chunk in socket.timeout(timeout)) {
        responseBytes.addAll(chunk);
      }
      final response = utf8.decode(responseBytes);
      final splitIndex = response.indexOf('\r\n\r\n');
      if (splitIndex < 0) {
        throw const FormatException('Resposta HTTP do ESP incompleta.');
      }
      final header = response.substring(0, splitIndex);
      final responseBody = response.substring(splitIndex + 4);
      final statusLine = header.split('\r\n').first;
      final statusParts = statusLine.split(' ');
      final statusCode = statusParts.length > 1
          ? int.tryParse(statusParts[1]) ?? 0
          : 0;
      if (statusCode < 200 || statusCode >= 300) {
        throw HttpException('ESP respondeu $statusCode: $responseBody');
      }
      final decoded = jsonDecode(responseBody);
      if (decoded is! Map<String, Object?>) {
        throw const FormatException('Resposta do ESP nao veio em JSON.');
      }
      return decoded;
    } finally {
      socket?.destroy();
      if (boundToWifi) await _clearNetworkBinding();
    }
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
