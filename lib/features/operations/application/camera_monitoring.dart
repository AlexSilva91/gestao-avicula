import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';

import '../../../core/database/app_database.dart';

const onvifCamerasSettingKey = 'hardware_onvif_cameras';

class OnvifCameraConfig {
  const OnvifCameraConfig({
    required this.id,
    required this.name,
    required this.host,
    required this.username,
    required this.password,
    this.port,
    this.snapshotUrl,
    this.enabled = true,
  });

  final String id;
  final String name;
  final String host;
  final String username;
  final String password;
  final int? port;
  final String? snapshotUrl;
  final bool enabled;

  String get rtspUrl {
    final cleanHost = _cleanHost(host);
    final cleanUser = Uri.encodeComponent(username.trim());
    final cleanPassword = Uri.encodeComponent(password);
    final credentials = cleanUser.isEmpty
        ? ''
        : '$cleanUser${password.isEmpty ? '' : ':$cleanPassword'}@';
    final cleanPort = port == null ? '' : ':$port';
    return 'rtsp://$credentials$cleanHost$cleanPort';
  }

  String get maskedRtspUrl {
    final cleanHost = _cleanHost(host);
    final credentials = username.trim().isEmpty
        ? ''
        : '${username.trim()}:${password.isEmpty ? '' : '****'}@';
    final cleanPort = port == null ? '' : ':$port';
    return 'rtsp://$credentials$cleanHost$cleanPort';
  }

  Uri get deviceServiceUri {
    return Uri(
      scheme: 'http',
      host: _cleanHost(host),
      port: port ?? 80,
      path: '/onvif/device_service',
    );
  }

  OnvifCameraConfig copyWith({
    String? id,
    String? name,
    String? host,
    String? username,
    String? password,
    int? port,
    String? snapshotUrl,
    bool clearPort = false,
    bool clearSnapshotUrl = false,
    bool? enabled,
  }) => OnvifCameraConfig(
    id: id ?? this.id,
    name: name ?? this.name,
    host: host ?? this.host,
    username: username ?? this.username,
    password: password ?? this.password,
    port: clearPort ? null : port ?? this.port,
    snapshotUrl: clearSnapshotUrl ? null : snapshotUrl ?? this.snapshotUrl,
    enabled: enabled ?? this.enabled,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'host': host,
    'username': username,
    'password': password,
    if (port != null) 'port': port,
    if (snapshotUrl?.trim().isNotEmpty == true) 'snapshotUrl': snapshotUrl,
    'enabled': enabled,
  };

  factory OnvifCameraConfig.fromJson(Map<String, dynamic> json) =>
      OnvifCameraConfig(
        id: json['id']?.toString() ?? const Uuid().v4(),
        name: json['name']?.toString() ?? 'Câmera',
        host: json['host']?.toString() ?? '',
        username: json['username']?.toString() ?? 'admin',
        password: json['password']?.toString() ?? '',
        port: int.tryParse(json['port']?.toString() ?? ''),
        snapshotUrl: json['snapshotUrl']?.toString(),
        enabled: json['enabled'] != false,
      );
}

String _cleanHost(String value) => value
    .trim()
    .replaceFirst(RegExp(r'^[a-zA-Z][a-zA-Z0-9+.-]*://'), '')
    .split('@')
    .last
    .split('/')
    .first
    .split(':')
    .first;

List<OnvifCameraConfig> onvifCamerasFromSettings(List<AppSetting> settings) {
  final value = settings
      .where((setting) => setting.key == onvifCamerasSettingKey)
      .map((setting) => setting.value)
      .firstOrNull;
  if (value == null || value.trim().isEmpty) return const [];
  try {
    final decoded = jsonDecode(value);
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map>()
        .map((item) => OnvifCameraConfig.fromJson(item.cast<String, dynamic>()))
        .where((camera) => camera.host.trim().isNotEmpty)
        .toList(growable: false);
  } catch (_) {
    return const [];
  }
}

String encodeOnvifCameras(List<OnvifCameraConfig> cameras) =>
    jsonEncode(cameras.map((camera) => camera.toJson()).toList());

class OnvifProbeResult {
  const OnvifProbeResult({
    required this.ok,
    required this.message,
    this.snapshotUrl,
  });

  final bool ok;
  final String message;
  final String? snapshotUrl;
}

class OnvifClient {
  OnvifClient({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;
  static const _timeout = Duration(seconds: 8);

  Future<OnvifProbeResult> resolveSnapshot(OnvifCameraConfig camera) async {
    final direct = camera.snapshotUrl?.trim();
    if (direct != null && direct.isNotEmpty) {
      return OnvifProbeResult(
        ok: true,
        message: 'URL de snapshot configurada manualmente.',
        snapshotUrl: direct,
      );
    }
    try {
      final mediaXAddr = await _mediaServiceUrl(camera);
      final profileToken = await _firstProfileToken(camera, mediaXAddr);
      final snapshotUrl = await _snapshotUri(camera, mediaXAddr, profileToken);
      return OnvifProbeResult(
        ok: true,
        message: 'Snapshot ONVIF localizado.',
        snapshotUrl: snapshotUrl,
      );
    } catch (error) {
      return OnvifProbeResult(ok: false, message: 'Falha ONVIF: $error');
    }
  }

  Map<String, String> imageHeaders(OnvifCameraConfig camera) {
    if (camera.username.trim().isEmpty) return const {};
    final raw = '${camera.username}:${camera.password}';
    return {'Authorization': 'Basic ${base64Encode(utf8.encode(raw))}'};
  }

  Future<String> _mediaServiceUrl(OnvifCameraConfig camera) async {
    final response = await _postSoap(
      camera,
      camera.deviceServiceUri,
      'GetCapabilities',
      '<tds:GetCapabilities><tds:Category>Media</tds:Category></tds:GetCapabilities>',
    );
    final xaddr = _firstText(response, 'XAddr');
    if (xaddr == null || xaddr.trim().isEmpty) {
      throw StateError('serviço Media não retornou XAddr');
    }
    return xaddr.trim();
  }

  Future<String> _firstProfileToken(
    OnvifCameraConfig camera,
    String mediaXAddr,
  ) async {
    final response = await _postSoap(
      camera,
      Uri.parse(mediaXAddr),
      'GetProfiles',
      '<trt:GetProfiles/>',
    );
    final document = XmlDocument.parse(response);
    for (final element in document.descendants.whereType<XmlElement>()) {
      if (element.name.local == 'Profiles') {
        final token = element.getAttribute('token');
        if (token != null && token.trim().isNotEmpty) return token.trim();
      }
    }
    throw StateError('perfil de mídia não encontrado');
  }

  Future<String> _snapshotUri(
    OnvifCameraConfig camera,
    String mediaXAddr,
    String profileToken,
  ) async {
    final response = await _postSoap(
      camera,
      Uri.parse(mediaXAddr),
      'GetSnapshotUri',
      '<trt:GetSnapshotUri><trt:ProfileToken>$profileToken</trt:ProfileToken></trt:GetSnapshotUri>',
    );
    final uri = _firstText(response, 'Uri');
    if (uri == null || uri.trim().isEmpty) {
      throw StateError('URI de snapshot não retornada');
    }
    return uri.trim();
  }

  Future<String> _postSoap(
    OnvifCameraConfig camera,
    Uri uri,
    String action,
    String body,
  ) async {
    final envelope =
        '''
<?xml version="1.0" encoding="UTF-8"?>
<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope"
            xmlns:tds="http://www.onvif.org/ver10/device/wsdl"
            xmlns:trt="http://www.onvif.org/ver10/media/wsdl">
  <s:Header>${_securityHeader(camera)}</s:Header>
  <s:Body>$body</s:Body>
</s:Envelope>
''';
    final response = await _httpClient
        .post(
          uri,
          headers: {
            'Content-Type':
                'application/soap+xml; charset=utf-8; action="$action"',
          },
          body: envelope,
        )
        .timeout(_timeout);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('HTTP ${response.statusCode} em $uri');
    }
    return response.body;
  }

  String _securityHeader(OnvifCameraConfig camera) {
    if (camera.username.trim().isEmpty) return '';
    final created = DateTime.now().toUtc().toIso8601String();
    final nonceBytes = Uint8List.fromList(
      List<int>.generate(16, (_) => Random.secure().nextInt(256)),
    );
    final digestBytes = sha1.convert([
      ...nonceBytes,
      ...utf8.encode(created),
      ...utf8.encode(camera.password),
    ]).bytes;
    return '''
<wsse:Security s:mustUnderstand="1"
  xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"
  xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">
  <wsse:UsernameToken>
    <wsse:Username>${_xml(camera.username)}</wsse:Username>
    <wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordDigest">${base64Encode(digestBytes)}</wsse:Password>
    <wsse:Nonce EncodingType="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary">${base64Encode(nonceBytes)}</wsse:Nonce>
    <wsu:Created>$created</wsu:Created>
  </wsse:UsernameToken>
</wsse:Security>
''';
  }

  String? _firstText(String xml, String localName) {
    final document = XmlDocument.parse(xml);
    for (final element in document.descendants.whereType<XmlElement>()) {
      if (element.name.local == localName) return element.innerText;
    }
    return null;
  }

  String _xml(String value) => value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&apos;');
}
