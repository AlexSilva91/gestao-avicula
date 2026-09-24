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

  Future<EspScaleReading> readScale(String endpoint) async {
    throw UnsupportedError(
      'Leitura direta do ESP indisponivel nesta plataforma.',
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
}
