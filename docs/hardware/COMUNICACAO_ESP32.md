# Comunicacao com o ESP32

Este documento descreve como a comunicacao com o ESP32 esta implementada no projeto GRANJA SELETO.

## Resumo

Atualmente a comunicacao com o ESP32 e hibrida:

- HTTP local via Wi-Fi para configuracao, agenda, diagnostico e recuperacao.
- MQTT opcional, bidirecional e persistente em tempo de execucao para status, sensores e comandos rapidos de rele.

O ESP32 roda um servidor web na porta 80 e o app Flutter envia requisicoes para endpoints `/api/...`, usando o IP do controlador na rede local ou o IP do ponto de acesso de configuracao.

Fluxo principal:

```text
App GRANJA SELETO -> Wi-Fi local -> HTTP -> ESP32 -> rele/sensores/agenda
App GRANJA SELETO <-> Broker MQTT <-> ESP32 -> status/sensores/rele
```

Quando o ESP32 ainda nao esta configurado na rede da propriedade, ele cria um ponto de acesso proprio:

```text
SSID: GRANJA-SELETO-SETUP
Senha: seleto1234
IP: 192.168.4.1
```

Depois que o Wi-Fi e configurado, o app passa a falar com o ESP32 pelo IP recebido na rede local, por exemplo:

```text
http://192.168.0.50
```

## Estado atual da implementacao

O firmware atual esta em:

```text
docs/hardware/firmware/esp32-granja-seleto/granja_seleto_wifi_bluetooth.ino
```

Apesar do nome do arquivo e de partes antigas da documentacao citarem Bluetooth, o firmware atual informa que a comunicacao ativa e:

- HTTP local pelo IP do ESP32 na rede Wi-Fi.
- MQTT opcional e bidirecional quando broker, topico e credenciais forem configurados.
- AP local de recuperacao/configuracao.
- Sem Bluetooth ativo.
- Sem servidor remoto ativo.

No app, o cliente responsavel pela comunicacao direta com o ESP32 esta em:

```text
lib/features/operations/application/hardware_esp_client.dart
lib/features/operations/application/hardware_esp_client_io.dart
lib/features/operations/application/hardware_esp_client_stub.dart
```

## Descoberta do ESP32

O app tenta encontrar o ESP32 automaticamente.

Primeiro ele testa o endpoint padrao do AP:

```text
http://192.168.4.1/api/status
```

Se nao encontrar, ele identifica a sub-rede atual do Wi-Fi e varre os IPs de `.1` ate `.254`, testando o endpoint:

```text
http://IP_DA_REDE/api/status
```

Exemplo:

```text
http://192.168.0.1/api/status
http://192.168.0.2/api/status
...
http://192.168.0.254/api/status
```

O dispositivo so e aceito como ESP32 da Granja Seleto quando a resposta contem:

```json
{
  "app": "GRANJA_SELETO"
}
```

ou quando o `deviceId` contem:

```text
GRANJA-SELETO
```

## Handshake

O handshake e feito com `GET /api/status`.

Exemplo:

```text
GET http://IP_DO_ESP32/api/status
```

Resposta esperada:

```json
{
  "deviceId": "GRANJA-SELETO-RELE-01",
  "app": "GRANJA_SELETO",
  "role": "RELAY_CONTROLLER",
  "wifiConnected": true,
  "ip": "192.168.0.50",
  "setupApSsid": "GRANJA-SELETO-SETUP",
  "setupApIp": "192.168.4.1",
  "timeValid": true,
  "relays": [],
  "schedules": []
}
```

O app usa essa resposta para:

- Confirmar que o ESP32 esta online.
- Atualizar o endpoint/IP salvo.
- Ler o estado real dos canais de rele.
- Saber se o Wi-Fi esta conectado.
- Exibir o retorno no terminal visual da tela de integracoes.

## Configuracao de Wi-Fi

A configuracao do Wi-Fi pode ser feita pelo app enquanto o celular esta conectado ao AP do ESP32.

Endpoint:

```text
POST /api/wifi
```

Campos enviados como `application/x-www-form-urlencoded`:

```text
ssid=NomeDaRede
password=SenhaDaRede
```

Exemplo:

```bash
curl -X POST "http://192.168.4.1/api/wifi" \
  -d "ssid=MinhaRede" \
  -d "password=MinhaSenha"
```

Resposta esperada:

```json
{
  "ok": true,
  "wifiConnected": true,
  "ip": "192.168.0.50",
  "setupApIp": "192.168.4.1"
}
```

Se a conexao for confirmada, o app salva o endpoint:

```text
http://192.168.0.50
```

Tambem existe endpoint para desconectar e limpar as credenciais:

```text
POST /api/wifi/disconnect
```

Campo:

```text
clear=1
```

## Controle dos reles

O controle dos reles pode ser feito por MQTT, quando configurado, ou por HTTP como fallback.

Via MQTT, o app publica em:

```text
granja/esp32/GRANJA-SELETO-RELE-01/relay/command
```

Payload:

```json
{
  "channel": 1,
  "state": "on",
  "source": "app"
}
```

O ESP32 publica o estado em:

```text
granja/esp32/GRANJA-SELETO-RELE-01/relay/state
```

Se MQTT estiver desativado ou falhar, o app usa HTTP por `POST /api/relay`.

Endpoint:

```text
POST /api/relay
```

Campos:

```text
channel=1
state=on
```

Estados aceitos:

```text
on
off
pulse
```

Exemplos:

```bash
curl -X POST "http://IP_DO_ESP32/api/relay" \
  -d "channel=1" \
  -d "state=on"
```

```bash
curl -X POST "http://IP_DO_ESP32/api/relay" \
  -d "channel=1" \
  -d "state=off"
```

```bash
curl -X POST "http://IP_DO_ESP32/api/relay" \
  -d "channel=1" \
  -d "state=pulse"
```

Resposta esperada:

```json
{
  "ok": true,
  "channel": 1,
  "on": true
}
```

Tambem e possivel consultar um canal:

```text
GET /api/relay?channel=1
```

## Canais usados

O firmware possui 12 canais de rele.

| Canal ESP | Uso | GPIO padrao |
| --- | --- | --- |
| 1 | Iluminacao 1 | 23 |
| 2 | Iluminacao 2 | 22 |
| 3 | Iluminacao 3 | 21 |
| 4 | Iluminacao 4 | 19 |
| 5 | Ventilacao 1 | 18 |
| 6 | Ventilacao 2 | 5 |
| 7 | Ventilacao 3 | 17 |
| 8 | Ventilacao 4 | 16 |
| 9 | Ventilacao 5 | 4 |
| 10 | Ventilacao 6 | 25 |
| 11 | Ventilacao 7 | 2 |
| 12 | Ventilacao 8 | 15 |

Os canais 1 a 4 sao usados pela tela de integracoes de iluminacao.

Os canais 5 a 12 ficam reservados para ventilacao.

## Agenda de iluminacao

O app envia a agenda para o ESP32, e o ESP32 salva essa agenda em cache local na flash.

Antes de sincronizar a agenda, o app envia a hora atual:

```text
POST /api/time
```

Campo:

```text
epoch=1735689600
```

Depois envia a agenda por canal:

```text
POST /api/channel_schedule
```

Campos:

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

Exemplo:

```bash
curl -X POST "http://IP_DO_ESP32/api/channel_schedule" \
  -d "channel=1" \
  -d "enabled=1" \
  -d "en1=1" \
  -d "on1=04:30" \
  -d "off1=06:10" \
  -d "en2=1" \
  -d "on2=17:40" \
  -d "off2=20:00" \
  -d "days=127"
```

Resposta esperada:

```json
{
  "ok": true,
  "cached": true,
  "schedule": {}
}
```

Tambem existe envio em lote:

```text
POST /api/group_schedule
```

Campos principais:

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

Se o envio em lote falhar, o app usa fallback e envia a agenda canal por canal.

## Leitura de sensores

O firmware disponibiliza endpoints para sensores de ambiente e agua.

Ambiente:

```text
GET /api/environment
```

Agua:

```text
GET /api/water
```

Todos os sensores:

```text
GET /api/sensors
```

O app espera dados como:

```json
{
  "airTemperatureC": 28.5,
  "airHumidityPercent": 72
}
```

Para agua, o app trata:

```json
{
  "levelPercent": 80,
  "temperatureC": 25.4,
  "ph": 7.1,
  "tdsPpm": 350,
  "chlorineOrpMv": 650
}
```

Com MQTT ativado, o ESP32 tambem publica periodicamente em:

```text
granja/esp32/GRANJA-SELETO-RELE-01/sensors
```

## MQTT

O MQTT e configurado no app e enviado ao ESP32 pelo endpoint HTTP. Quando configurado, o app mantem uma conexao MQTT persistente enquanto a tela de integracoes esta aberta, assinando `status`, `sensors` e `relay/state`, e publicando comandos em `relay/command` sem reconectar a cada acao.

```text
POST /api/mqtt
```

Campos:

```text
enabled=1
host=192.168.0.10
port=1883
baseTopic=granja/esp32
deviceId=GRANJA-SELETO-RELE-01
username=
password=
```

Topicos padrao:

| Topico | Direcao | Funcao |
| --- | --- | --- |
| `granja/esp32/GRANJA-SELETO-RELE-01/status` | ESP32 -> broker | Online, IP e uptime |
| `granja/esp32/GRANJA-SELETO-RELE-01/sensors` | ESP32 -> broker | Ambiente e agua |
| `granja/esp32/GRANJA-SELETO-RELE-01/relay/state` | ESP32 -> broker | Estado dos reles |
| `granja/esp32/GRANJA-SELETO-RELE-01/relay/command` | app/broker -> ESP32 | Comandos `on`, `off` e `pulse` |
| `granja/esp32/GRANJA-SELETO-RELE-01/ping` | app/broker -> ESP32 | Solicita publicacao de status |

O ESP32 usa Last Will no topico `status` para sinalizar queda:

```json
{
  "online": false
}
```

## Comunicacao no Android

No Android, quando o endpoint e local, o app usa uma rotina de HTTP mais direta por socket TCP.

Isso existe para melhorar a comunicacao com IPs locais como:

```text
192.168.4.1
192.168.0.x
10.x.x.x
172.16.x.x
```

A requisicao ainda e HTTP, mas o envio e montado manualmente com:

```text
GET /api/status HTTP/1.0
Host: IP_DO_ESP32
Connection: close
Accept: application/json
```

Para `POST`, o app envia:

```text
Content-Type: application/x-www-form-urlencoded; charset=utf-8
```

## Timeouts e tentativas

O app usa os seguintes tempos principais:

| Acao | Timeout |
| --- | --- |
| Probe/varredura | 1,5 s |
| Requisicao geral | 12 s |
| Comando de rele | 3 s |
| Configuracao de Wi-Fi | 35 s |

O `ping` tenta ate 3 vezes antes de falhar.

Comandos `on` e `pulse` do rele tambem podem tentar novamente.

O comando `off` faz uma tentativa mais direta, depois pode tentar redescobrir o ESP32 se necessario.

## Armazenamento local

No ESP32:

- Credenciais Wi-Fi sao salvas em `Preferences`.
- Configuracao MQTT e salva em `Preferences`.
- Agendas dos canais sao salvas em `Preferences`.
- A agenda continua salva mesmo apos reiniciar o ESP32.

No app:

- Endpoint do ESP32 e salvo nas configuracoes da aplicacao.
- Broker, porta, topico, device ID e credenciais MQTT sao salvos nas configuracoes da aplicacao.
- SSID e senha informados na tela de configuracao tambem sao salvos nas configuracoes locais do app.
- Estados de ultimo teste dos canais sao armazenados para exibicao na interface.

## Limitacoes atuais

- A comunicacao depende do ESP32 e do celular/app estarem acessiveis pela mesma rede local, ou do celular estar conectado ao AP `GRANJA-SELETO-SETUP`.
- MQTT depende de um broker acessivel pela rede local, como Mosquitto.
- Nao ha LoRa implementado no estado atual.
- Nao ha Bluetooth ativo no firmware atual, apesar de existirem referencias antigas em documentacao.
- Nao ha servidor remoto ativo; o endpoint `/api/remote` responde como desativado/local.
- Sem modulo RTC com bateria, o horario depende de NTP quando ha internet ou da sincronizacao enviada pelo app.

## Endpoints implementados

| Metodo | Endpoint | Funcao |
| --- | --- | --- |
| `GET` | `/api/ping` | Teste simples de vida do ESP32 |
| `GET` | `/api/status` | Handshake completo, status, reles e agenda |
| `GET` | `/api/environment` | Leitura dos sensores de ambiente |
| `GET` | `/api/water` | Leitura dos sensores de agua |
| `GET` | `/api/sensors` | Leitura consolidada de ambiente e agua |
| `GET` | `/api/remote` | Estado da sincronizacao remota, atualmente local/desativada |
| `POST` | `/api/remote` | Mantido por compatibilidade, atualmente local/desativado |
| `GET` | `/api/relay?channel=N` | Consulta estado de um canal |
| `POST` | `/api/relay` | Liga, desliga ou pulsa um canal |
| `POST` | `/api/channel_schedule` | Salva agenda de um canal |
| `POST` | `/api/group_schedule` | Salva agenda em varios canais |
| `GET` | `/api/schedule` | Consulta agendas salvas |
| `POST` | `/api/time` | Sincroniza horario por epoch |
| `POST` | `/api/wifi` | Salva SSID/senha e tenta conectar |
| `POST` | `/api/wifi/disconnect` | Desconecta e pode limpar credenciais |
| `GET` | `/api/mqtt` | Consulta configuracao e conexao MQTT |
| `POST` | `/api/mqtt` | Salva broker MQTT, topico e credenciais |

## Conclusao

A comunicacao atual e hibrida: o ESP32 continua funcionando como servidor HTTP local para configuracao e recuperacao, e tambem pode atuar como cliente MQTT para operacao rapida.

Essa solucao e boa para testes, configuracao e controle local dentro da mesma rede Wi-Fi. Para cenarios em que o ESP32 fique muito longe do roteador, a arquitetura ainda pode receber uma camada fisica diferente, como RS485, LoRa ou um gateway intermediario.
