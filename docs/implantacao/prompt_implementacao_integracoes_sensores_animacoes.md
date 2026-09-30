# Prompt mestre atualizado para implementar integracoes, sensores e animacoes do GRANJA SELETO

Este documento deve ser usado como prompt/roteiro tecnico para replicar, em outro sistema, as integracoes de hardware e a experiencia visual existentes hoje no GRANJA SELETO.

O foco e reproduzir o estado atual do projeto, nao uma lista idealizada. Quando houver diferenca entre documentacao de circuito e codigo ja integrado ao app, trate esta especificacao como fonte principal e consulte os arquivos indicados.

## 1. Referencias reais do projeto atual

Use estes arquivos como base de implementacao:

- `lib/features/operations/application/hardware_esp_client.dart`
- `lib/features/operations/application/hardware_esp_client_io.dart`
- `lib/features/operations/application/hardware_esp_client_stub.dart`
- `lib/features/operations/application/camera_monitoring.dart`
- `lib/features/operations/presentation/pages/hardware_integrations_page.dart`
- `lib/features/operations/presentation/pages/hardware_sensor_pages.dart`
- `lib/features/operations/presentation/pages/camera_monitor_page.dart`
- `lib/features/operations/presentation/pages/settings_page.dart`
- `lib/core/database/operations_tables.dart`
- `lib/core/database/operations_repository.dart`
- `lib/core/routing/app_router.dart`
- `android/app/src/main/kotlin/com/seleto/seleto/MainActivity.kt`
- `docs/hardware/firmware/esp32-granja-seleto/granja_seleto_wifi_bluetooth.ino`
- `docs/hardware/firmware/esp32-granja-seleto/MANUAL_CONEXAO_APP_GRANJA.md`
- `docs/hardware/circuitos/ambiente/`
- `docs/hardware/circuitos/reservatorio-agua/`
- `docs/hardware/circuitos/iluminacao/`
- `docs/hardware/circuitos/ventiladores/`
- `docs/hardware/circuitos/cameras/`

## 2. Escopo que deve ser replicado

Implemente uma aplicacao Flutter com:

1. Integracao com ESP32 via HTTP em rede local.
2. Descoberta automatica do ESP32 no AP padrao `192.168.4.1` e na sub-rede Wi-Fi atual.
3. Configuracao de Wi-Fi do ESP32 pelo app.
4. Terminal visual de logs da descoberta, handshake, configuracao Wi-Fi, sincronizacao remota e comandos.
5. Controle de 4 canais de iluminacao nos reles ESP32 1 a 4.
6. Agenda de iluminacao com dois periodos diarios: manha e noite.
7. Sincronizacao individual de agenda por canal.
8. Sincronizacao em grupo de agenda para canais selecionados.
9. Sincronizacao de hora do app para o ESP32.
10. Controle de 8 canais de ventilacao nos reles ESP32 5 a 12.
11. Leitura de temperatura e umidade do ambiente.
12. Leitura de agua/reservatorio: nivel, temperatura, pH, TDS e ORP/cloro opcional.
13. Leitura agregada de sensores por `/api/sensors`.
14. Configuracao de sincronizacao remota do ESP32 por `/api/remote`.
15. Cadastro de cameras IP/ONVIF com credenciais, porta e snapshot opcional.
16. Resolucao de snapshot ONVIF via SOAP.
17. Grade de cameras RTSP ao vivo com media_kit.
18. Abertura/fechamento de cada camera na grade.
19. Popup fullscreen por camera.
20. Controle de audio por camera.
21. Persistencia local de configuracoes em `app_settings`.
22. Estados visuais de carregamento, erro, ativo, inativo, online e ultima leitura.
23. Animacoes/instrumentos visuais para iluminacao, ambiente, agua, ventilacao e cameras.

## 3. Stack tecnica usada hoje

Use Flutter com:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  flutter_riverpod: ^3.3.1
  go_router: ^17.1.0
  drift: ^2.32.0
  drift_flutter: ^0.3.0
  sqlite3_flutter_libs: ^0.6.0+eol
  path_provider: ^2.1.5
  path: ^1.9.1
  crypto: ^3.0.7
  uuid: ^4.5.2
  intl: ^0.20.2
  fl_chart: ^1.1.1
  table_calendar: ^3.2.0
  flutter_local_notifications: ^20.0.0
  shared_preferences: ^2.5.3
  timezone: ^0.10.1
  cupertino_icons: ^1.0.8
  file_picker: ^12.2.0
  share_plus: ^13.3.0
  csv: ^8.0.0
  xml: ^6.6.1
  excel: ^4.0.6
  connectivity_plus: ^7.3.1
  http: ^1.6.0
  media_kit: ^1.2.6
  media_kit_video: ^2.0.1
  media_kit_libs_video: ^1.0.7
```

## 4. Arquitetura minima

Crie uma estrutura equivalente:

```text
lib/
  core/
    database/
      app_database.dart
      operations_repository.dart
      operations_tables.dart
    routing/
      app_router.dart
    widgets/
      app_shell.dart
      seleto_widgets.dart
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
android/
  app/src/main/kotlin/.../MainActivity.kt
docs/
  hardware/
```

Rotas esperadas:

- `/integrations`
- `/hardware-environment`
- `/hardware-ventilation`
- `/hardware-water`
- `/hardware-water-quality`
- `/cameras`
- `/settings`

## 5. Persistencia local

Use Drift/SQLite e crie a tabela:

```sql
app_settings(
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL,
  updated_at DATETIME NOT NULL,
  updated_by TEXT NULL
)
```

Implemente:

- `Stream<List<AppSetting>> watchAppSettings()`
- `Future<void> saveAppSetting(String key, String value, String actorId)`
- no controller: `Future<void> saveSetting(String key, String value)`

As configuracoes de hardware sao simples pares chave/valor. Nao renomeie chaves depois de uso em producao.

## 6. Chaves de configuracao usadas hoje

### 6.1. ESP32 e Wi-Fi

```text
hardware_esp_setup_endpoint=192.168.4.1
hardware_esp_wifi_ssid=<ssid>
hardware_esp_wifi_password=<senha>
hardware_esp_remote_sync_enabled=true|false
hardware_esp_remote_sync_url=http://solveontecnology.com.br:5005/iot/v1/esp/sync
hardware_esp_remote_sync_token=<token opcional>
hardware_esp_control_priority=local|remote
```

### 6.2. Iluminacao

```text
hardware_lighting_enabled=true|false
hardware_lighting_connection=WIFI|BLUETOOTH
hardware_lighting_endpoint=<ip ou endpoint http do ESP32>
hardware_lighting_relay_pin=23
hardware_lighting_general_morning_enabled=true|false
hardware_lighting_general_morning_on_time=04:30
hardware_lighting_general_morning_off_time=06:10
hardware_lighting_general_evening_enabled=true|false
hardware_lighting_general_evening_on_time=17:40
hardware_lighting_general_evening_off_time=20:00
hardware_lighting_general_channel_1_selected=true|false
hardware_lighting_general_channel_2_selected=true|false
hardware_lighting_general_channel_3_selected=true|false
hardware_lighting_general_channel_4_selected=true|false
```

Para canais `1` a `4`, persista:

```text
hardware_lighting_channel_<n>_name=<nome>
hardware_lighting_channel_<n>_pin=<gpio>
hardware_lighting_channel_<n>_enabled=true|false
hardware_lighting_channel_<n>_on_time=04:30
hardware_lighting_channel_<n>_off_time=06:10
hardware_lighting_channel_<n>_morning_enabled=true|false
hardware_lighting_channel_<n>_morning_on_time=04:30
hardware_lighting_channel_<n>_morning_off_time=06:10
hardware_lighting_channel_<n>_evening_enabled=true|false
hardware_lighting_channel_<n>_evening_on_time=17:40
hardware_lighting_channel_<n>_evening_off_time=20:00
hardware_lighting_channel_<n>_last_test_state=ON|OFF
```

Pins padrao da iluminacao no firmware:

```text
Canal ESP 1 = GPIO23
Canal ESP 2 = GPIO22
Canal ESP 3 = GPIO21
Canal ESP 4 = GPIO19
```

### 6.3. Ventilacao

```text
hardware_ventilation_enabled=true|false
hardware_ventilation_endpoint=<ip ou endpoint http do ESP32>
```

Para canais de ventilacao `1` a `8`, persista:

```text
hardware_ventilation_channel_<n>_name=Ventilador <n>
hardware_ventilation_channel_<n>_pin=<gpio>
hardware_ventilation_channel_<n>_enabled=true|false
hardware_ventilation_channel_<n>_last_test_state=ON|OFF
```

Mapeamento atual:

```text
Ventilacao 1 = canal ESP 5  = GPIO18
Ventilacao 2 = canal ESP 6  = GPIO5
Ventilacao 3 = canal ESP 7  = GPIO17
Ventilacao 4 = canal ESP 8  = GPIO16
Ventilacao 5 = canal ESP 9  = GPIO4
Ventilacao 6 = canal ESP 10 = GPIO25
Ventilacao 7 = canal ESP 11 = GPIO2
Ventilacao 8 = canal ESP 12 = GPIO15
```

Valide para ventilacao que o GPIO nao esteja vazio, nao esteja repetido e nao use os pinos reservados:

```text
23, 22, 21, 19, 27, 34, 35, 36, 39
```

### 6.4. Ambiente

```text
hardware_environment_endpoint=<ip ou endpoint http do ESP32>
hardware_environment_last_temperature_c=<decimal>
hardware_environment_last_humidity_percent=<decimal>
```

Pontos esperados na UI:

```text
T/U galpao       = GPIO27
T/U pinteiro 1   = I2C/exp.
T/U pinteiro 2   = I2C/exp.
```

### 6.5. Agua e reservatorio

```text
hardware_water_endpoint=<ip ou endpoint http do ESP32>
hardware_water_quality_endpoint=<ip ou endpoint http do ESP32>
hardware_water_last_level_percent=<decimal>
hardware_water_last_temperature_c=<decimal>
hardware_water_last_ph=<decimal>
hardware_water_last_tds_ppm=<decimal>
hardware_water_last_chlorine_orp_mv=<decimal opcional>
```

Pontos esperados:

```text
Nivel da agua = GPIO34
Temperatura   = GPIO35
pH            = GPIO36
TDS           = GPIO39
Cloro/ORP     = ADS1115/I2C
```

### 6.6. Cameras

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

## 7. Cliente ESP32

Exporte `hardware_esp_client.dart` assim:

```dart
export 'hardware_esp_client_stub.dart'
    if (dart.library.io) 'hardware_esp_client_io.dart';
```

No stub web, todos os metodos diretos do ESP32 devem retornar `UnsupportedError`, exceto `discover`, que deve avisar que a varredura automatica nao esta disponivel na plataforma.

No cliente nativo, use `dart:io` `HttpClient`. Em Android, para endpoints locais, use tambem um `MethodChannel('seleto/network')` com:

- `wifiIpv4Address`
- `bindProcessToWifi`
- `clearNetworkBinding`

Isso evita que o Android tente enviar chamadas locais pelo link errado quando ha Wi-Fi sem internet ou dados moveis ativos.

## 8. Normalizacao de endpoint

Normalize qualquer endpoint informado pelo usuario:

1. `trim()`.
2. Se vazio, use `http://192.168.4.1`.
3. Se nao comecar com `http://` ou `https://`, prefixe `http://`.
4. Remova barra final.

Exemplos aceitos:

```text
192.168.0.50
http://192.168.0.50
http://192.168.4.1
```

## 9. Descoberta do ESP32

Fluxo atual:

1. Testar primeiro `http://192.168.4.1/api/status`.
2. Se nao encontrar, obter o IPv4 Wi-Fi local.
3. Montar a base da sub-rede, por exemplo `192.168.0`.
4. Varrer hosts `.1` a `.254` em lotes de 24.
5. Para cada host, chamar `ping()` com timeout de 1500 ms.
6. Aceitar somente resposta com `app == "GRANJA_SELETO"` ou `deviceId` contendo `GRANJA-SELETO`.
7. Registrar logs visuais como `SYS>`, `SCAN>`, `ESP>` e `ERR>`.

## 10. Contrato HTTP do firmware atual

O firmware atual expoe:

```http
GET  /api/ping
GET  /api/status
GET  /api/environment
GET  /api/water
GET  /api/sensors
GET  /api/remote
POST /api/remote
GET  /api/relay?channel=1
POST /api/relay
POST /api/channel_schedule
POST /api/group_schedule
GET  /api/schedule
POST /api/time
POST /api/wifi
```

### 10.1. Ping/status

`GET /api/status` deve retornar JSON com, no minimo:

```json
{
  "ok": true,
  "app": "GRANJA_SELETO",
  "deviceId": "GRANJA-SELETO-RELE-01",
  "ip": "192.168.0.50",
  "setupApIp": "192.168.4.1",
  "relayActiveLow": true,
  "relays": [
    {"channel": 1, "pin": 23, "on": false}
  ],
  "sensorEndpoints": ["/api/environment", "/api/water", "/api/sensors"]
}
```

O app usa `ip` para atualizar o endpoint resolvido quando disponivel.

### 10.2. Ambiente

`GET /api/environment` deve retornar:

```json
{
  "ok": true,
  "airTemperatureC": 28.4,
  "airHumidityPercent": 71.2,
  "zones": [
    {
      "id": "galpao_centro",
      "label": "Galpao centro",
      "temperatureC": 28.4,
      "humidityPercent": 71.2
    }
  ]
}
```

O app tambem aceita aliases:

- `points` no lugar de `zones`
- `galpaoCentro` ou `galpao`
- `pinteiroPiso1` ou `pinteiro1`
- `pinteiroPiso2` ou `pinteiro2`
- `tempC`, `airTemperatureC`, `temperatureC`
- `humidity`, `airHumidityPercent`, `humidityPercent`

Se nao vier lista de zonas, o app cria uma zona fallback `galpao_centro`.

### 10.3. Agua

`GET /api/water` deve retornar:

```json
{
  "ok": true,
  "levelPercent": 82.0,
  "temperatureC": 25.1,
  "ph": 7.2,
  "tdsPpm": 320,
  "chlorineOrpMv": 650
}
```

Aliases aceitos para ORP/cloro:

- `chlorineOrpMv`
- `orpMv`
- `chlorineMv`
- `cloroOrpMv`

### 10.4. Sensores agregados

`GET /api/sensors` deve retornar:

```json
{
  "ok": true,
  "environment": {},
  "water": {}
}
```

### 10.5. Rele

Leitura:

```http
GET /api/relay?channel=1
```

Resposta:

```json
{
  "ok": true,
  "channel": 1,
  "on": true
}
```

Comando:

```http
POST /api/relay
Content-Type: application/x-www-form-urlencoded

channel=1&state=on
```

Estados aceitos:

- `on` ou `1`
- `off` ou `0`
- `pulse`

Resposta:

```json
{
  "ok": true,
  "channel": 1,
  "on": true
}
```

No app, `off` tenta confirmar o endpoint com status antes do envio. Para `on` e `pulse`, tente ate 3 vezes; se falhar, rode descoberta automatica e tente no endpoint descoberto.

### 10.6. Agenda de canal

```http
POST /api/channel_schedule
Content-Type: application/x-www-form-urlencoded

channel=1&enabled=1&en1=1&on1=04:30&off1=06:10&en2=1&on2=17:40&off2=20:00&days=127
```

Campos:

- `channel`: canal ESP.
- `enabled`: agenda ativa no canal.
- `en1`: periodo da manha ativo.
- `on1`: hora de ligar no periodo 1.
- `off1`: hora de desligar no periodo 1.
- `en2`: periodo da noite ativo.
- `on2`: hora de ligar no periodo 2.
- `off2`: hora de desligar no periodo 2.
- `days`: mascara de dias. Use `127` para todos os dias.

Resposta esperada:

```json
{
  "ok": true,
  "cached": true,
  "schedule": {}
}
```

### 10.7. Agenda em grupo

```http
POST /api/group_schedule
Content-Type: application/x-www-form-urlencoded

channels=1,2,4&enabled=1&en1=1&on1=04:30&off1=06:10&en2=1&on2=17:40&off2=20:00&days=127
```

Resposta:

```json
{
  "ok": true,
  "cached": true,
  "channels": [1, 2, 4],
  "schedules": []
}
```

### 10.8. Hora

```http
POST /api/time
Content-Type: application/x-www-form-urlencoded

epoch=1735689600
```

O app envia `DateTime.now().millisecondsSinceEpoch ~/ 1000` antes de sincronizar agenda.

### 10.9. Wi-Fi

```http
POST /api/wifi
Content-Type: application/x-www-form-urlencoded

ssid=NomeDaRede&password=SenhaDaRede
```

Timeout do app: 35 segundos. Apos configurar, o app deve tentar pingar o endpoint retornado ou o endpoint informado por ate 12 tentativas, esperando o ESP reconectar.

Quando o firmware retornar `ip`, salve este endpoint em:

```text
hardware_lighting_endpoint
```

e habilite:

```text
hardware_lighting_connection=WIFI
hardware_lighting_enabled=true
```

### 10.10. Sincronizacao remota do ESP

Leitura:

```http
GET /api/remote
```

Configuracao:

```http
POST /api/remote
Content-Type: application/x-www-form-urlencoded

enabled=1&url=http://servidor/iot/v1/esp/sync&token=TOKEN&priority=local
```

Campos:

- `enabled`: `1`/`0`.
- `url`: endpoint remoto de sincronizacao.
- `token`: opcional.
- `priority`: `local` ou `remote`.

O firmware atual usa como padrao:

```text
http://solveontecnology.com.br:5005/iot/v1/esp/sync
```

## 11. Bluetooth

O firmware atual tambem expoe Bluetooth Serial com nome:

```text
GRANJA_SELETO_RELE
```

Comandos documentados:

```text
PING
STATUS
RELAY 1 ON
RELAY 1 OFF
PULSE 1
SCHEDULE 1 1 04:30 06:10 17:40 20:00 127
TIME 1735689600
WIFI Nome da Rede|Senha da Rede
```

No app atual, Bluetooth aparece como opcao/identificador visual, mas a integracao operacional implementada no cliente e HTTP/Wi-Fi. Nao implemente pareamento Bluetooth completo sem tratar isso como expansao.

## 12. Cameras ONVIF/RTSP

Implemente `OnvifCameraConfig` com:

- `id`
- `name`
- `host`
- `username`
- `password`
- `port`
- `snapshotUrl`
- `enabled`

Limpeza de host:

1. Remover scheme (`http://`, `rtsp://`, etc.).
2. Remover credenciais antes de `@`.
3. Remover path depois de `/`.
4. Remover porta depois de `:`.

RTSP gerado:

```text
rtsp://usuario:senha@host:porta
```

Se `username` estiver vazio, nao inclua credenciais.

Servico ONVIF:

```text
http://host:porta/onvif/device_service
```

Resolucao de snapshot:

1. Se `snapshotUrl` manual existir, use diretamente.
2. Caso contrario, envie SOAP `GetCapabilities`.
3. Obtenha o `XAddr` do Media service.
4. Envie `GetProfiles`.
5. Use o primeiro profile token.
6. Envie `GetSnapshotUri`.
7. Use o primeiro `Uri` retornado.

Autenticacao ONVIF:

- Use WS-Security UsernameToken com nonce aleatorio.
- Gere digest com SHA1 de `nonce + created + password`.
- Para imagem/snapshot direto, use Basic Auth quando houver usuario.

Liveview:

- Use `media_kit`, `media_kit_video` e `media_kit_libs_video`.
- Inicialize `MediaKit.ensureInitialized()` no bootstrap do app.
- Mostre grade responsiva de cameras ativas.
- Permita fechar/reabrir cada camera sem excluir cadastro.
- Permita popup fullscreen.
- Permita audio ligado somente para uma camera por vez.

## 13. Experiencia visual e animacoes

Replicar a experiencia visual atual com Material 3, `AppShell`, `Seleto` widgets e instrumentos compactos.

Estados comuns:

- carregando com `CircularProgressIndicator`;
- erro com componente de erro padrao;
- configuracao ausente;
- lendo/testando;
- ativo/inativo;
- ultima leitura carregada;
- falha de ESP com mensagem exibida na propria tela.

Use animacoes e pintura customizada onde fizer sentido:

- Iluminacao: painel com canais, chips de manha/noite, status de ativo/off e indicador de canais ligados.
- Ventilacao: instrumento com fluxo de ar animado/pintado, contagem de canais ligados e canais ativos.
- Ambiente: instrumento visual de galpao/casa com temperatura e umidade.
- Agua/reservatorio: tanque/nivel de agua e metricas de qualidade.
- Cameras: toolbar colapsavel com `AnimatedCrossFade`, grade responsiva e tiles de video.
- Terminal ESP: linhas em janela visual com ultimas mensagens, truncando para cerca de 12 linhas.

Nao use paginas explicativas no lugar da ferramenta. A primeira tela de cada modulo deve permitir operar, ler, salvar ou testar.

## 14. Firmware ESP32 atual

O firmware atual e o arquivo:

```text
docs/hardware/firmware/esp32-granja-seleto/granja_seleto_wifi_bluetooth.ino
```

Constantes principais:

```text
deviceId = GRANJA-SELETO-RELE-01
bluetoothName = GRANJA_SELETO_RELE
setupApSsid = GRANJA-SELETO-SETUP
setupApPassword = seleto1234
gmtOffsetSeconds = -3 * 60 * 60
relayActiveLow = true
remoteSyncIntervalMs = 180000
manualOverrideMs = 300000
```

Pinos:

```text
Reles: 23, 22, 21, 19, 18, 5, 17, 16, 4, 25, 2, 15
DHT: GPIO27
Agua nivel: GPIO34
Agua temperatura: GPIO35
Agua pH: GPIO36
Agua TDS: GPIO39
```

Comportamentos:

- AP de setup fica em `192.168.4.1`.
- O firmware serve uma pagina HTML simples de recuperacao para configurar Wi-Fi.
- Agenda e configuracoes ficam em cache local via `Preferences`.
- Manual override de rele segura alteracao por 5 minutos.
- Agenda e reles usam ate 12 canais.
- Canais 1 a 4 sao iluminacao.
- Canais 5 a 12 sao ventilacao.
- Sensores de agua usam leitura analogica.
- Sincronizacao remota pode receber comandos de rele no retorno HTTP.

## 15. Checklist de aceite

Considere a implementacao pronta quando:

1. `/integrations` encontra o ESP no AP `192.168.4.1` ou na sub-rede local.
2. O app mostra logs de descoberta e handshake.
3. Configuracao Wi-Fi salva SSID/senha e tenta reconectar ao IP final.
4. Canal de iluminacao liga/desliga e persiste `last_test_state`.
5. Agenda individual envia `/api/time` e `/api/channel_schedule`.
6. Agenda geral envia `/api/time` e `/api/group_schedule`.
7. Tela de ventilacao usa canais ESP 5 a 12 e valida GPIOs reservados.
8. Ambiente le `/api/environment` e salva ultima temperatura/umidade.
9. Agua le `/api/water` e salva nivel, temperatura, pH, TDS e ORP quando houver.
10. Remote sync le e salva `/api/remote`.
11. Cameras sao persistidas em `hardware_onvif_cameras`.
12. Snapshot ONVIF e URL manual funcionam.
13. RTSP abre com media_kit, grade, popup e audio exclusivo por camera.
14. Web usa stub para ESP local; nativo usa cliente real.
15. Android usa MethodChannel para IP Wi-Fi e binding em chamadas locais.
16. Todas as configuracoes ficam em `app_settings`.
17. A UI tem estados claros de loading, erro, ativo, inativo e ultima leitura.

## 16. Resumo de prompt para outro desenvolvedor

Implemente as integracoes atuais do GRANJA SELETO em Flutter. Use Riverpod, GoRouter, Drift/SQLite, Material 3, http/xml/crypto/uuid para ONVIF e media_kit para RTSP. Persista configuracoes em `app_settings`.

Crie um cliente ESP32 por HTTP local com descoberta automatica, normalizacao de endpoint, logs visuais, configuracao Wi-Fi, controle de reles, agenda de iluminacao, sensores de ambiente/agua e configuracao de sincronizacao remota. Em Android, use MethodChannel para descobrir IP Wi-Fi e prender chamadas locais ao Wi-Fi.

Use o firmware ESP32 atual como contrato: 12 reles, canais 1-4 para iluminacao, canais 5-12 para ventilacao, DHT em GPIO27, agua em GPIO34/35/36/39, AP `GRANJA-SELETO-SETUP` com senha `seleto1234`, Bluetooth Serial `GRANJA_SELETO_RELE` apenas documentado/visual no app atual.

Implemente cameras com cadastro ONVIF/RTSP persistido em `hardware_onvif_cameras`, resolucao de snapshot por SOAP e liveview com media_kit. Replique a experiencia visual com instrumentos animados/pintados, toolbar colapsavel, terminal ESP e estados operacionais claros.
