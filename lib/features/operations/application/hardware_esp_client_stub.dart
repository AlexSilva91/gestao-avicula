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

  Future<EspDeviceProbe?> discover({
    void Function(String message)? onLog,
  }) async {
    onLog?.call(
      'Varredura automatica indisponivel nesta plataforma. Informe o IP manualmente.',
    );
    return null;
  }

  Future<EspDeviceProbe> ping(String endpoint) async {
    throw UnsupportedError(
      'Conexao direta com ESP indisponivel nesta plataforma.',
    );
  }

  Future<EspEnvironmentReading> readEnvironment(String endpoint) async {
    throw UnsupportedError(
      'Leitura direta do ESP indisponivel nesta plataforma.',
    );
  }

  Future<EspWaterReading> readWater(String endpoint) async {
    throw UnsupportedError(
      'Leitura direta do ESP indisponivel nesta plataforma.',
    );
  }

  Future<Map<String, Object?>> readSensors(String endpoint) async {
    throw UnsupportedError(
      'Leitura direta do ESP indisponivel nesta plataforma.',
    );
  }

  Future<Map<String, Object?>> readRemoteSync(String endpoint) async {
    throw UnsupportedError(
      'Configuracao remota do ESP indisponivel nesta plataforma.',
    );
  }

  Future<Map<String, Object?>> configureRemoteSync({
    required String endpoint,
    required bool enabled,
    required String url,
    required String token,
    required String priority,
  }) async {
    throw UnsupportedError(
      'Configuracao remota do ESP indisponivel nesta plataforma.',
    );
  }

  Future<Map<String, Object?>> configureWifi({
    required String endpoint,
    required String ssid,
    required String password,
  }) async {
    throw UnsupportedError(
      'Configuracao de Wi-Fi do ESP indisponivel nesta plataforma.',
    );
  }

  Future<EspRelayResult> setRelay({
    required String endpoint,
    required int channel,
    required bool turnOn,
  }) async {
    throw UnsupportedError(
      'Controle direto do ESP indisponivel nesta plataforma.',
    );
  }

  Future<EspRelayResult> pulseRelay({
    required String endpoint,
    required int channel,
  }) async {
    throw UnsupportedError(
      'Controle direto do ESP indisponivel nesta plataforma.',
    );
  }

  Future<Map<String, Object?>> syncTime(String endpoint, DateTime now) async {
    throw UnsupportedError(
      'Sincronizacao direta do ESP indisponivel nesta plataforma.',
    );
  }

  Future<Map<String, Object?>> setChannelSchedule({
    required String endpoint,
    required EspChannelSchedule schedule,
  }) async {
    throw UnsupportedError(
      'Agenda direta do ESP indisponivel nesta plataforma.',
    );
  }

  Future<Map<String, Object?>> setGroupSchedule({
    required String endpoint,
    required List<int> channels,
    required EspChannelSchedule schedule,
  }) async {
    throw UnsupportedError(
      'Agenda geral direta do ESP indisponivel nesta plataforma.',
    );
  }
}
