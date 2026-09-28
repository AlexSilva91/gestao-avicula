# Prompt mestre para implementar as integracoes de sensores e animacoes do GRANJA SELETO

Este documento deve ser usado como prompt/roteiro tecnico para replicar, em outro sistema, as integracoes de sensores, camera, automacoes de rele e animacoes atualmente existentes no GRANJA SELETO.

Objetivo: permitir que outro desenvolvedor implemente a mesma experiencia com o menor numero possivel de decisoes abertas.

## 1. Escopo que deve ser replicado

Implemente uma aplicacao Flutter com:

1. Integracao com ESP32 via Wi-Fi local.
2. Preparacao de configuracao Bluetooth/identificador do ESP32.
3. Descoberta automatica do ESP32 na rede local.
4. Configuracao de Wi-Fi do ESP32 pelo endpoint de setup.
5. Controle de reles para iluminacao.
6. Controle de reles para ventilacao.
7. Leitura de balanca com HX711/celula de carga.
8. Tara, calibracao e taxa de leitura da balanca.
9. Leitura de temperatura e umidade do ar.
10. Leitura de dados de agua/reservatorio: nivel, temperatura, pH e TDS.
11. Cadastro e exibicao de cameras IP/ONVIF/RTSP.
12. Grade de liveview com abertura/fechamento por camera.
13. Controle de audio por camera.
14. Estado visual de carregamento, online, offline, erro e pronto.
15. Animacoes para ventiladores, reservatorio, ambiente, balanca, iluminacao e dashboard.
16. Persistencia local das configuracoes.
17. Logs visuais para debug de conexao do ESP32.

## 2. Stack tecnica recomendada

Use:

- Flutter.
- Riverpod para estado.
- GoRouter para navegacao.
- Drift/SQLite para persistencia local.
- SharedPreferences apenas para preferencias simples, se o projeto ja usar.
- `http` para ONVIF/SOAP.
- `dart:io` `HttpClient` para chamadas ao ESP32 em plataformas nativas.
- `media_kit`, `media_kit_video` e `media_kit_libs_video` para RTSP.
- `xml` para parse de resposta ONVIF.
- `uuid` para ids de cameras.
- `crypto` para cabecalho WS-Security quando necessario.
- Material 3.

No `pubspec.yaml`, inclua no minimo:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^3.3.1
  go_router: ^17.1.0
  drift: ^2.32.0
  drift_flutter: ^0.3.0
  sqlite3_flutter_libs: ^0.6.0+eol
  shared_preferences: ^2.5.3
  http: ^1.6.0
  media_kit: ^1.2.6
  media_kit_video: ^2.0.1
  media_kit_libs_video: ^1.0.7
  xml: ^6.6.1
  uuid: ^4.5.2
  crypto: ^3.0.7
  intl: ^0.20.2
```

## 3. Arquitetura de pastas recomendada

Crie uma organizacao equivalente:

```text
lib/
  core/
    database/
      app_database.dart
      operations_repository.dart
      operations_tables.dart
    routing/
      app_router.dart
    theme/
      app_theme.dart
    widgets/
      app_shell.dart
      app_widgets.dart
    utils/
      formatters.dart
  features/
    operations/
      application/
        hardware_esp_client.dart
        hardware_esp_client_io.dart
        hardware_esp_client_stub.dart
        camera_monitoring.dart
        operations_controller.dart
      presentation/
        pages/
          hardware_integrations_page.dart
          hardware_sensor_pages.dart
          camera_monitor_page.dart
          settings_page.dart
          dashboard_page.dart
docs/
  hardware/
    circuitos/
    firmware/
    sensores/
```

## 4. Modelo de persistencia das configuracoes

Crie uma tabela simples de configuracoes:

```sql
app_settings(
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL,
  updated_at TEXT NOT NULL
)
```

Implemente no repositorio:

- `Future<List<AppSetting>> watchSettings()` ou stream equivalente.
- `Future<void> saveSetting(String key, String value)`.
- `Future<void> deleteSetting(String key)`.

Use sempre chaves estaveis. Nao altere nomes depois que estiver em producao.

### 4.1. Chaves de balanca

```text
hardware_scale_enabled=true|false
hardware_scale_connection=WIFI|BLUETOOTH
hardware_scale_mode=BOTH|INGREDIENT_PURCHASE|FEEDING
hardware_scale_device=<nome ou identificador>
hardware_scale_endpoint=<ip ou endpoint http do ESP32>
hardware_scale_last_weight_kg=<decimal>
hardware_scale_rate_hz=10|80
```

### 4.2. Chaves de iluminacao

```text
hardware_lighting_enabled=true|false
hardware_lighting_connection=WIFI|BLUETOOTH
hardware_lighting_endpoint=<ip ou endpoint http do ESP32>
hardware_lighting_relay_pin=23
hardware_lighting_channel_1_name=Canal 1
hardware_lighting_channel_1_pin=23
hardware_lighting_channel_1_enabled=true
hardware_lighting_channel_1_morning_enabled=true
hardware_lighting_channel_1_morning_on=04:30
hardware_lighting_channel_1_morning_off=06:10
hardware_lighting_channel_1_evening_enabled=true
hardware_lighting_channel_1_evening_on=17:40
hardware_lighting_channel_1_evening_off=20:00
```

Repita para canais `1` a `4`.

### 4.3. Chaves de ventilacao

```text
hardware_ventilation_enabled=true|false
hardware_ventilation_endpoint=<ip ou endpoint http do ESP32>
hardware_ventilation_channel_1_name=Ventilador 1
hardware_ventilation_channel_1_pin=18
hardware_ventilation_channel_1_enabled=true
hardware_ventilation_channel_1_last_test_state=ON|OFF
```

Repita para canais `1` a `8`.

### 4.4. Chaves de sensores independentes

```text
hardware_environment_endpoint=<endpoint do ESP32>
hardware_water_endpoint=<endpoint do ESP32>
```

Se preferir, reutilize o mesmo endpoint salvo em `hardware_scale_endpoint` ou `hardware_lighting_endpoint`, desde que o app deixe claro ao usuario.

### 4.5. Chaves de camera

Use uma unica chave JSON:

```text
hardware_onvif_cameras=[
  {
    "id": "uuid",
    "name": "Galpao 1",
    "host": "192.168.0.80",
    "username": "admin",
    "password": "senha",
    "port": 80,
    "snapshotUrl": "opcional",
    "enabled": true
  }
]
```

## 5. Contrato HTTP do ESP32

O aplicativo deve tratar o ESP32 como uma API HTTP local.

### 5.1. Endpoint base

O usuario pode informar:

```text
192.168.0.50
http://192.168.0.50
http://192.168.4.1
```

Normalize internamente:

1. Remova espacos.
2. Se nao tiver `http://` ou `https://`, prefixe `http://`.
3. Remova barra final.
4. Se vazio, use `http://192.168.4.1`.

### 5.2. Endpoints obrigatorios

```http
GET  /api/ping
GET  /api/status
GET  /api/scale
POST /api/scale/tare
POST /api/scale/calibrate
POST /api/scale/rate
GET  /api/environment
GET  /api/water
GET  /api/sensors
POST /api/wifi
GET  /api/relay?channel=1
POST /api/relay
POST /api/time
POST /api/channel_schedule
POST /api/group_schedule
```

### 5.3. Resposta de status

Exija JSON em formato de mapa.

Exemplo:

```json
{
  "ok": true,
  "app": "GRANJA_SELETO",
  "deviceId": "GRANJA-SELETO-ESP32",
  "ip": "192.168.0.50",
  "setupApIp": "192.168.4.1",
  "relayActiveLow": true
}
```

### 5.4. Descoberta automatica

Implemente:

1. Tentar primeiro `http://192.168.4.1/api/status`.
2. Se responder com `app=GRANJA_SELETO` ou `deviceId` contendo `GRANJA-SELETO`, usar esse endpoint.
3. Se nao responder, obter interfaces IPv4 locais.
4. Para cada rede local, varrer `base.1` ate `base.254`.
5. Usar lotes de 24 hosts por vez para nao travar a UI.
6. Timeout curto de probe: 850 ms.
7. Timeout de requisicao normal: 3 s.
8. Registrar logs visuais:
   - `SYS> iniciando descoberta automatica do ESP32`
   - `SCAN> varrendo 192.168.0.1 ate 192.168.0.254`
   - `ESP> handshake OK em http://192.168.0.50`
   - `SYS> fallback: Wi-Fi GRANJA-SELETO-SETUP / seleto1234`

### 5.5. Android: vinculo de rede Wi-Fi

Em Android, quando o endpoint for local (`192.168.x.x`, `10.x.x.x`, `172.16-31.x.x` ou `192.168.4.1`), implemente um MethodChannel:

```dart
const MethodChannel('seleto/network');
```

Metodos:

```text
bindProcessToWifi
clearNetworkBinding
```

Use antes/depois de cada chamada local, para evitar que o Android tente usar dados moveis quando o Wi-Fi do ESP nao tem internet.

## 6. Mapeamento de pinos e canais

### 6.1. Iluminacao

| Canal ESP | Uso | GPIO |
| --- | --- | --- |
| 1 | Iluminacao 1 | GPIO23 |
| 2 | Iluminacao 2 | GPIO22 |
| 3 | Iluminacao 3 | GPIO21 |
| 4 | Iluminacao 4 | GPIO19 |

### 6.2. Ventilacao

| Canal ESP | Uso | GPIO |
| --- | --- | --- |
| 5 | Ventilacao 1 | GPIO18 |
| 6 | Ventilacao 2 | GPIO5 |
| 7 | Ventilacao 3 | GPIO17 |
| 8 | Ventilacao 4 | GPIO16 |
| 9 | Ventilacao 5 | GPIO4 |
| 10 | Ventilacao 6 | GPIO25 |
| 11 | Ventilacao 7 | GPIO2 |
| 12 | Ventilacao 8 | GPIO15 |

No app, mostre ventilacao como canais visuais `1` a `8`, mas envie ao ESP os canais reais `5` a `12`.

Formula:

```dart
const ventilationRelayOffset = 4;
final espChannel = ventilationRelayOffset + visualIndex + 1;
```

### 6.3. Balanca

| Funcao | GPIO |
| --- | --- |
| HX711 DT/DOUT | GPIO32 |
| HX711 SCK/CLK | GPIO33 |
| Botao tara | GPIO13 |
| Botao calibracao | GPIO14 |
| Botao taxa | GPIO26 |

### 6.4. Ambiente

| Funcao | GPIO |
| --- | --- |
| DHT22/AM2302 DATA | GPIO27 |

### 6.5. Agua

| Funcao | GPIO |
| --- | --- |
| Nivel da agua analogico | GPIO34 |
| Temperatura da agua analogica | GPIO35 |
| pH analogico | GPIO36 |
| TDS/EC analogico | GPIO39 |

Observacao: no firmware futuro, prefira DS18B20 digital para temperatura da agua, ADS1115 para pH/TDS/nivel analogico e SHT31 I2C para ambiente.

## 7. Cliente ESP32 no app

Crie uma classe `HardwareEspClient`.

### 7.1. Modelos

```dart
class EspDeviceProbe {
  final String endpoint;
  final String deviceId;
  final String message;
  final Map<String, Object?> payload;
}

class EspScaleReading {
  final double weightKg;
  final String message;
  final Map<String, Object?> payload;
}

class EspEnvironmentReading {
  final double airTemperatureC;
  final double airHumidityPercent;
  final String message;
  final Map<String, Object?> payload;
}

class EspWaterReading {
  final double levelPercent;
  final double temperatureC;
  final double ph;
  final double tdsPpm;
  final String message;
  final Map<String, Object?> payload;
}

class EspRelayResult {
  final int channel;
  final bool on;
  final String message;
  final Map<String, Object?> payload;
}

class EspChannelSchedule {
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
```

### 7.2. Metodos obrigatorios

```dart
Future<EspDeviceProbe?> discover({void Function(String message)? onLog});
Future<EspDeviceProbe> ping(String endpoint);
Future<EspScaleReading> readScale(String endpoint);
Future<EspEnvironmentReading> readEnvironment(String endpoint);
Future<EspWaterReading> readWater(String endpoint);
Future<Map<String, Object?>> readSensors(String endpoint);
Future<Map<String, Object?>> tareScale(String endpoint);
Future<Map<String, Object?>> calibrateScale({required String endpoint, required double knownWeightKg});
Future<Map<String, Object?>> setScaleRate({required String endpoint, required int rateHz});
Future<Map<String, Object?>> configureWifi({required String endpoint, required String ssid, required String password});
Future<EspRelayResult> setRelay({required String endpoint, required int channel, required bool turnOn});
Future<EspRelayResult> pulseRelay({required String endpoint, required int channel});
Future<Map<String, Object?>> syncTime(String endpoint, DateTime now);
Future<Map<String, Object?>> setChannelSchedule({required String endpoint, required EspChannelSchedule schedule});
Future<Map<String, Object?>> setGroupSchedule({required String endpoint, required List<int> channels, required EspChannelSchedule schedule});
```

### 7.3. Formato dos posts

Use `application/x-www-form-urlencoded`.

Relay:

```text
channel=1&state=on
channel=1&state=off
channel=1&state=pulse
```

Agenda individual:

```text
channel=1
enabled=1
en1=1
on1=04:30
off1=06:10
en2=1
on2=17:40
off2=20:00
days=127
```

Agenda em grupo:

```text
channels=1,2,3,4
enabled=1
en1=1
on1=04:30
off1=06:10
en2=1
on2=17:40
off2=20:00
days=127
```

## 8. Firmware ESP32 esperado

Implemente no firmware:

1. Modo Wi-Fi STA com credenciais salvas.
2. Fallback AP:
   - SSID: `GRANJA-SELETO-SETUP`
   - Senha: `seleto1234`
   - IP: `192.168.4.1`
3. Servidor HTTP na porta 80.
4. JSON em todas as respostas.
5. `relayActiveLow` configuravel.
6. Array de pinos:

```cpp
constexpr uint8_t relayPins[] = {23, 22, 21, 19, 18, 5, 17, 16, 4, 25, 2, 15};
```

7. Canais 1-4: iluminacao.
8. Canais 5-12: ventilacao.
9. NTP quando conectado a Wi-Fi.
10. Cache local de agendas.
11. Endpoint de ajuste manual de hora.
12. Endpoints de sensores mesmo que inicialmente retornem valores mockados; isso permite evolucao sem quebrar o app.

## 9. Telas que devem existir

### 9.1. Tela de integracoes de hardware

Crie uma tela chamada `HardwareIntegrationsPage`.

Ela deve permitir:

- Ativar/desativar balanca.
- Escolher conexao da balanca: Wi-Fi ou Bluetooth.
- Informar endpoint/IP da balanca/ESP32.
- Testar Wi-Fi.
- Testar Bluetooth.
- Ler peso.
- Tara.
- Calibrar com peso conhecido.
- Definir taxa de leitura `10 Hz` ou `80 Hz`.
- Ativar/desativar iluminacao.
- Escolher conexao da iluminacao: Wi-Fi ou Bluetooth.
- Informar endpoint/IP do ESP32.
- Configurar os quatro canais de iluminacao.
- Nomear canal.
- Definir GPIO.
- Definir agenda manha e tarde/noite por canal.
- Sincronizar agenda geral.
- Testar canal individual: ligar/desligar/pulso.
- Configurar Wi-Fi do ESP32 pelo AP.
- Exibir terminal visual de logs.

### 9.2. Paginas dedicadas de sensores

Crie `hardware_sensor_pages.dart` com:

- `ScaleSensorPage`.
- `EnvironmentSensorPage`.
- `WaterSystemSensorPage`.
- `VentilationSensorPage`.

Todas devem usar o mesmo layout-base `_SensorExperience`.

### 9.3. Pagina de cameras

Crie `CameraMonitorPage`.

Ela deve:

- Ler cameras de `hardware_onvif_cameras`.
- Mostrar grade responsiva.
- Abrir stream RTSP quando `visible=true`.
- Fechar stream e liberar player quando `visible=false`.
- Controlar audio por `ValueNotifier<String?> audioEnabledId`.
- Permitir popup/ampliar camera.
- Mostrar estado vazio quando nao houver camera.

### 9.4. Configuracoes de cameras

Na tela de configuracoes:

- Formulario de camera:
  - Nome.
  - IP/host.
  - Usuario.
  - Senha.
  - Porta.
  - Snapshot URL opcional.
  - Ativo/inativo.
- Botao para copiar RTSP.
- Botao para testar snapshot ONVIF.
- Salvar tudo em JSON na chave `hardware_onvif_cameras`.

## 10. ONVIF e RTSP

### 10.1. Modelo de camera

```dart
class OnvifCameraConfig {
  final String id;
  final String name;
  final String host;
  final String username;
  final String password;
  final int? port;
  final String? snapshotUrl;
  final bool enabled;
}
```

### 10.2. RTSP

Monte:

```dart
rtsp://usuario:senha@host:porta
```

Se nao houver porta, omita.

Exiba versao mascarada:

```dart
rtsp://admin:****@192.168.0.80
```

### 10.3. ONVIF snapshot

Fluxo:

1. Se `snapshotUrl` manual existir, usar direto.
2. Caso contrario, POST SOAP em:

```text
http://host:porta/onvif/device_service
```

3. Chamar `GetCapabilities` com categoria `Media`.
4. Obter `XAddr`.
5. Chamar `GetProfiles`.
6. Ler primeiro token de `Profiles`.
7. Chamar `GetSnapshotUri`.
8. Retornar a URI.

### 10.4. Autenticacao

Para imagem simples, use Basic Auth quando a camera exigir:

```dart
Authorization: Basic base64(username:password)
```

Para SOAP ONVIF, implemente WS-Security UsernameToken se a camera nao aceitar Basic.

## 11. Animacoes e componentes visuais

### 11.1. Principio visual geral

Todos os instrumentos devem:

- Usar `Container` com `borderRadius: 8`.
- Usar `CustomPaint` para ilustracoes leves.
- Usar icones Material.
- Evitar hero grande.
- Evitar cartoes dentro de cartoes.
- Mostrar status textual e visual.
- Ser responsivos.
- Manter altura fixa para nao saltar layout.

### 11.2. `_SensorExperience`

Crie um widget-base com:

- Icone tecnico.
- Titulo.
- Subtitulo.
- Pílula de status.
- Faixa de status.
- Visual animado.
- Trilho de metricas.
- Acoes.
- Portas/GPIOs.
- Payload JSON expandivel ou exibivel.
- Cards de configuracao.

Entradas:

```dart
icon
title
subtitle
status
visual
metrics
actions
ports
config
payload
```

### 11.3. Balanca animada

Widget: `_ScaleInstrument`.

Elementos:

- Altura: `184`.
- Desenho com `CustomPainter`.
- Plataforma da balanca.
- Base trapezoidal.
- Texto `LOAD CELL / HX711`.
- Peso grande no rodape.
- Taxa de leitura no canto.

Regras:

- Se `weightKg == null`, mostrar `--,-- kg`.
- Se houver leitura, formatar com `kg()`.
- `active = weightKg != null`.
- `working` deve ativar brilho mesmo sem leitura.

### 11.4. Ambiente animado

Widget: `_EnvironmentHouseInstrument`.

Elementos:

- Altura: `190`.
- Casa simples em `CustomPainter`.
- Circulo de temperatura muda de turquesa para vermelho conforme temperatura.
- Gota/bolha de umidade cresce conforme percentual.
- Badge de temperatura no topo esquerdo.
- Badge de umidade no topo direito.

Formula:

```dart
final temp = ((temperatureC ?? 25) - 15).clamp(0, 25) / 25;
final humidity = ((humidityPercent ?? 50).clamp(0, 100)) / 100;
```

### 11.5. Reservatorio animado

Widget: `_WaterReservoirInstrument`.

Elementos:

- Altura: `218`.
- `TweenAnimationBuilder<double>` para nivel.
- Duracao: `700 ms`.
- Curva: `Curves.easeOutCubic`.
- Tanque arredondado.
- Agua preenchendo de baixo para cima.
- Linha de onda na superficie.
- Badges:
  - Nivel.
  - pH.
  - Temperatura.
  - TDS.

Formula:

```dart
final level = ((levelPercent ?? 0) / 100).clamp(0.0, 1.0);
```

### 11.6. Ventilacao animada

Widget: `_VentilationInstrument`.

Elementos:

- Altura: `230`.
- Fundo com linhas de fluxo de ar.
- 8 ventiladores desenhados.
- Cada ventilador tem label `1` a `8`.
- Ventiladores ativos giram.
- Pílula inferior esquerda: `N girando` ou `parado`.
- Pílula inferior direita: `8 canais`.

Use:

```dart
AnimationController(
  vsync: this,
  duration: Duration(milliseconds: 760),
)
```

Se ativo:

```dart
controller.repeat();
```

Se inativo:

```dart
controller.stop();
```

Rotacao:

```dart
Transform.rotate(
  angle: controller.value * math.pi * 2,
  child: CustomPaint(painter: _FanPainter(...)),
)
```

Fluxo de ar:

- `CustomPainter` com 5 curvas cubicas horizontais.
- Alpha maior quando ativo.
- Alpha menor quando parado.

### 11.7. Iluminacao animada

Widget: `_LightingControlInstrument`.

Elementos:

- Painel visual com placa/rele.
- 4 nos de lampada.
- Cada no mostra:
  - Icone de lampada ligada/desligada.
  - Nome do canal.
  - GPIO.
  - Indicador manha.
  - Indicador noite.
- Trilho de metricas:
  - Modo.
  - Canais.
  - Ligados.
  - Conexao.

Painter:

- Barramento horizontal.
- 4 descidas ate lampadas.
- Quando canal estiver ligado, desenhar brilho circular.

### 11.8. Dashboard

Crie previews compactos:

- Agua: `TweenAnimationBuilder` de nivel.
- Ventilacao: 8 mini fans girando quando ativo.
- Iluminacao: 4 lampadas com brilho quando ligadas.
- Balanca: desenho compacto de plataforma.
- Ambiente: casa com bolhas de temperatura/umidade.

No dashboard, nao use botoes de configuracao; apenas leitura/status.

### 11.9. Camera liveview

Widget: `_LiveCameraTile`.

Comportamento:

- Ao criar, instanciar `Player()` e `VideoController(player)`.
- Se `visible=true`, abrir RTSP.
- Se `visible=false`, mostrar `_ClosedCameraBackdrop`.
- Ao mudar camera ou RTSP, reabrir stream.
- Ao fechar, `player.stop()`.
- Ao destruir, `player.dispose()`.
- Durante abertura, mostrar overlay preto com `CircularProgressIndicator`.

Topo:

- Gradiente preto para leitura do nome.
- `_CameraLiveDot`:
  - Amarelo e `...` abrindo.
  - Vermelho e `LIVE` quando aberto.

Rodape:

- Botoes redondos:
  - Mostrar/ocultar video.
  - Ativar/desativar audio.
  - Ampliar.

## 12. Validacoes obrigatorias

### 12.1. Ventilacao

Pinos reservados:

```dart
const reservedPins = {
  '23', '22', '21', '19',
  '32', '33', '13', '14', '26',
  '27', '34', '35', '36', '39',
};
```

Regras:

1. Canal ativo deve ter GPIO.
2. GPIO nao pode estar em `reservedPins`.
3. GPIO nao pode repetir em outro canal de ventilacao.
4. Se ventilacao desativada, nao permitir teste.
5. Se endpoint vazio, nao permitir teste.

### 12.2. Iluminacao

Regras:

1. Canal ativo deve ter GPIO.
2. Canal 1 padrao `23`.
3. Canal 2 padrao `22`.
4. Canal 3 padrao `21`.
5. Canal 4 padrao `19`.
6. Horarios devem estar em `HH:mm`.
7. Agenda geral so sincroniza via Wi-Fi.

### 12.3. Balanca

Regras:

1. Tara exige endpoint.
2. Calibracao exige peso conhecido > 0.
3. Taxa aceita apenas `10` ou `80`.
4. Ao iniciar leitura ao vivo, usar timer.
5. Ao sair da tela, cancelar timer.
6. Guardar amostras:
   - total.
   - minima.
   - maxima.
   - ultima.

### 12.4. Agua

Regras:

1. Nivel deve ser limitado entre `0` e `100`.
2. pH deve ser exibido com duas casas.
3. TDS em ppm sem casas ou com uma casa.
4. Temperatura com uma casa.
5. Se JSON vier sem campo, usar `0` internamente mas mostrar status de falha ou sem leitura conforme contexto.

### 12.5. Camera

Regras:

1. Host nao pode ser vazio.
2. Nome nao pode ser vazio.
3. Usuario padrao: `admin`.
4. Porta padrao ONVIF: `80`.
5. Nao exibir senha aberta fora do formulario.
6. Nao abrir stream de camera desativada.

## 13. Firmware: respostas JSON esperadas

### 13.1. Balanca

```json
{
  "ok": true,
  "weightKg": 12.345,
  "rateHz": 10
}
```

### 13.2. Ambiente

```json
{
  "ok": true,
  "airTemperatureC": 28.4,
  "airHumidityPercent": 66.2
}
```

### 13.3. Agua

```json
{
  "ok": true,
  "levelPercent": 72,
  "temperatureC": 25.8,
  "ph": 6.85,
  "tdsPpm": 420
}
```

### 13.4. Rele

```json
{
  "ok": true,
  "channel": 5,
  "on": true
}
```

### 13.5. Sensores agregados

```json
{
  "ok": true,
  "scale": {"weightKg": 12.345},
  "environment": {"airTemperatureC": 28.4, "airHumidityPercent": 66.2},
  "water": {"levelPercent": 72, "temperatureC": 25.8, "ph": 6.85, "tdsPpm": 420},
  "relays": [
    {"channel": 1, "pin": 23, "on": false},
    {"channel": 5, "pin": 18, "on": true}
  ]
}
```

## 14. Telas e rotas sugeridas

```text
/hardware/integracoes
/hardware/balanca
/hardware/ambiente
/hardware/agua
/hardware/ventilacao
/cameras
/configuracoes
/dashboard
```

## 15. Sequencia de implementacao sem margem para erro

1. Criar dependencias no `pubspec.yaml`.
2. Criar tabela `app_settings`.
3. Criar provider/repository de configuracoes.
4. Criar `HardwareEspClient` com normalizacao de endpoint.
5. Implementar `GET` e `POST form-urlencoded`.
6. Implementar `ping`.
7. Implementar `discover`.
8. Implementar `readScale`.
9. Implementar `tareScale`.
10. Implementar `calibrateScale`.
11. Implementar `setScaleRate`.
12. Implementar `readEnvironment`.
13. Implementar `readWater`.
14. Implementar `readSensors`.
15. Implementar `setRelay`.
16. Implementar `pulseRelay`.
17. Implementar `syncTime`.
18. Implementar `setChannelSchedule`.
19. Implementar `setGroupSchedule`.
20. Criar tela de integracoes com terminal visual.
21. Criar card de configuracao Wi-Fi do ESP32.
22. Criar card de balanca.
23. Criar card de iluminacao.
24. Criar pagina de balanca.
25. Criar pagina de ambiente.
26. Criar pagina de agua.
27. Criar pagina de ventilacao.
28. Criar `_SensorExperience`.
29. Criar `_ScaleInstrument`.
30. Criar `_EnvironmentHouseInstrument`.
31. Criar `_WaterReservoirInstrument`.
32. Criar `_VentilationInstrument`.
33. Criar `_AnimatedFan`.
34. Criar `_FanPainter`.
35. Criar `_VentilationAirflowPainter`.
36. Criar `_LightingControlInstrument`.
37. Criar `_LightingInstrumentPainter`.
38. Criar modelos ONVIF.
39. Criar encode/decode JSON de cameras.
40. Criar cliente ONVIF.
41. Criar tela de configuracao de cameras.
42. Criar live tile RTSP com `media_kit`.
43. Criar grade responsiva de cameras.
44. Criar popup/ampliacao de camera.
45. Criar dashboard com previews.
46. Testar app sem hardware usando endpoints vazios e estados mock.
47. Testar ESP32 no AP `192.168.4.1`.
48. Testar configuracao de Wi-Fi.
49. Testar descoberta na rede local.
50. Testar relay canal 1 a 4.
51. Testar relay canal 5 a 12.
52. Testar leitura da balanca.
53. Testar tara.
54. Testar calibracao.
55. Testar ambiente.
56. Testar agua.
57. Testar cadastro de camera.
58. Testar snapshot ONVIF.
59. Testar RTSP.
60. Testar audio.
61. Testar responsividade mobile/desktop.
62. Testar navegacao e descarte de players/timers.

## 16. Checklist de aceite

Considere concluido somente quando:

- O app encontra o ESP32 automaticamente em rede local.
- O app funciona conectado no AP do ESP32.
- O endpoint manual funciona com e sem `http://`.
- A balanca le peso e salva ultima leitura.
- Tara responde sem travar a UI.
- Calibracao envia `knownWeightKg`.
- Ambiente exibe temperatura e umidade.
- Agua exibe nivel, temperatura, pH e TDS.
- Iluminacao controla 4 canais.
- Iluminacao sincroniza agenda individual e geral.
- Ventilacao controla 8 canais usando ESP 5-12.
- Pinos duplicados sao bloqueados.
- Pinos reservados sao bloqueados.
- Camera ONVIF resolve snapshot ou aceita URL manual.
- RTSP abre e fecha sem vazamento de player.
- Audio so fica ativo em uma camera por vez.
- Animacao de ventilador para quando canal desliga.
- Animacao de reservatorio transiciona suavemente.
- Dashboard reflete estados salvos.
- Nenhuma tela quebra em largura mobile.
- Nenhum texto estoura botoes ou cards.

## 17. Prompt resumido para colar em outra IA

```text
Implemente em Flutter uma experiencia de integracao de hardware rural igual ao GRANJA SELETO. Use Riverpod, Drift/SQLite, GoRouter, media_kit para RTSP e http/xml/crypto/uuid para ONVIF. Crie um cliente ESP32 que normalize endpoint, descubra automaticamente o ESP em 192.168.4.1 e na sub-rede local, e consuma endpoints /api/status, /api/scale, /api/environment, /api/water, /api/sensors, /api/relay, /api/channel_schedule, /api/group_schedule, /api/wifi e /api/time. Persistir configuracoes em app_settings key/value.

Mapeie iluminacao nos canais ESP 1-4 com GPIO23, GPIO22, GPIO21, GPIO19. Mapeie ventilacao nos canais ESP 5-12 com GPIO18, GPIO5, GPIO17, GPIO16, GPIO4, GPIO25, GPIO2, GPIO15. Mapeie balanca HX711 em GPIO32/33 e botoes em GPIO13/14/26. Mapeie ambiente DHT22 em GPIO27. Mapeie agua em GPIO34 nivel, GPIO35 temperatura, GPIO36 pH, GPIO39 TDS.

Crie telas: integracoes de hardware, balanca, ambiente, agua, ventilacao, cameras, configuracoes e dashboard. Crie animacoes com CustomPainter: balanca, casa/ambiente, reservatorio com TweenAnimationBuilder, ventiladores com AnimationController e Transform.rotate, iluminacao com lampadas e brilho, camera live tile com Video do media_kit, overlay de carregamento e botoes redondos.

Implemente validacoes de pinos reservados, endpoint vazio, horarios HH:mm, peso conhecido > 0, uma camera com audio por vez, stop/dispose de players e cancelamento de timers. Entregar UI responsiva e logs visuais do ESP32.
```
