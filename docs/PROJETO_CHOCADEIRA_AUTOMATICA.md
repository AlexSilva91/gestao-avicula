# Projeto de chocadeira automatica integrada ao app SELETO

Data de referencia: 09/10/2026.

Este documento descreve um projeto de chocadeira de baixo custo, mas com base
tecnica suficiente para controle preciso de temperatura, umidade, ventilacao,
rolagem automatica dos ovos e visualizacao por camera dentro da chocadeira.

O objetivo e permitir integracao com o app SELETO via MQTT, exibindo status em
tempo real, alarmes, historico, configuracoes e camera.

## Objetivos do projeto

- Controlar temperatura com precisao.
- Controlar umidade para aumentar ou reduzir conforme necessidade.
- Controlar ventilacao interna.
- Controlar rolagem automatica dos ovos com agenda programavel.
- Permitir parada automatica da rolagem no periodo final de incubacao.
- Permitir visualizacao interna por camera.
- Integrar tudo ao app via MQTT.
- Registrar historico de temperatura, umidade, eventos, falhas e comandos.
- Manter baixo custo, sem abrir mao de seguranca eletrica e estabilidade.

## Parametros alvo para ovos de galinha

Valores comuns de referencia para incubacao de ovos de galinha:

- Temperatura de incubacao: `37,5 °C`.
- Faixa aceitavel operacional: `37,2 °C` a `37,8 °C`.
- Umidade fase inicial: `45%` a `55%`.
- Umidade na eclosao: `60%` a `70%`.
- Viragem dos ovos: a cada `2h` a `4h`, conforme configuracao.
- Parar viragem: normalmente nos ultimos `3 dias` antes da eclosao.

Esses valores devem ser configuraveis no app, pois podem mudar conforme especie,
tipo de ovo, regiao, material da chocadeira e experiencia de manejo.

## Arquitetura recomendada

### Visao geral

```text
App SELETO
  |
  | MQTT
  v
Broker MQTT remoto/local
  |
  | Topicos da chocadeira
  v
ESP32 controlador da chocadeira
  |-- Sensor principal temperatura/umidade
  |-- Sensor redundante temperatura
  |-- Aquecimento
  |-- Umidificador
  |-- Desumidificacao/exaustao
  |-- Ventilacao/circulacao
  |-- Motor de rolagem
  |-- Fim de curso/posicao
  |-- Camera interna
```

## Versao MVP de baixo custo

Esta e a versao mais barata que ainda considero aceitavel.

### Componentes principais

| Item | Funcao | Recomendacao |
| --- | --- | --- |
| ESP32 DevKit | Controle principal | Pode usar ESP32 comum |
| SHT31 ou SHT30 | Temperatura e umidade principal | Melhor que DHT22 para precisao |
| DS18B20 a prova d'agua | Temperatura redundante | Validacao/backup de temperatura |
| Rele SSR AC ou modulo rele 10A | Aquecimento | Preferir SSR para ciclos frequentes |
| Lampada ceramica/incandescente ou resistencia PTC | Aquecimento | PTC e mais segura |
| Cooler 12V | Circulacao interna | Ventilacao continua ou PWM |
| Mini umidificador ultrassonico 5V/12V | Aumentar umidade | Controlado por MOSFET/rele |
| Cooler/exaustor 12V | Reduzir umidade | Retira ar umido ou aumenta troca de ar |
| Motor DC reduzido ou servo alto torque | Rolagem dos ovos | Bandeja inclinavel |
| Driver ponte H ou MOSFET | Acionar motor | Conforme tipo do motor |
| Fonte 12V 5A | Atuadores | Dimensionar conforme carga |
| Step-down 12V -> 5V | ESP32 e sensores | Buck DC-DC estavel |
| Fusivel + chave geral | Seguranca | Obrigatorio |
| Caixa termica/isopor/madeira isolada | Camara da chocadeira | Baixo custo |
| ESP32-CAM ou camera IP barata | Visualizacao | Ver secao de camera |

### Sensor principal recomendado

Para controle preciso, usar `SHT31` ou `SHT30` como sensor principal.

Motivo:

- melhor estabilidade que DHT11/DHT22;
- comunicacao I2C simples;
- boa precisao para temperatura e umidade;
- facil integracao com ESP32.

O `DHT22` pode funcionar em prototipo barato, mas eu nao recomendo como sensor
principal se a meta for precisao real.

### Sensor redundante

Use um `DS18B20` para medir temperatura em outro ponto da chocadeira.

Funcoes:

- validar se o SHT31 esta coerente;
- detectar ponto frio/quente;
- gerar alarme de divergencia;
- impedir superaquecimento se o sensor principal falhar.

## Versao mais profissional e escalavel

Para atender pequenas, medias e grandes granjas, o projeto deve evoluir para
modulos:

- `Modulo Chocadeira`: controle local com ESP32.
- `Modulo Camera`: ESP32-CAM ou camera IP/RTSP separada.
- `Modulo Energia`: fonte, fusivel, protecao e isolamento.
- `Modulo Sensores`: sensor principal, redundante e sensores opcionais.
- `Modulo Atuadores`: aquecimento, umidade, exaustao, ventilacao, rolagem.
- `Modulo App`: dashboard, historico, alertas, receitas/perfis.

Em granjas maiores, cada chocadeira deve ter:

- `deviceId` unico;
- topico MQTT proprio;
- parametros proprios;
- historico proprio;
- permissao por usuario/propriedade;
- alertas independentes.

Exemplo:

```text
seleto/incubator/CHOCADEIRA-01/status
seleto/incubator/CHOCADEIRA-01/telemetry
seleto/incubator/CHOCADEIRA-01/config/command
seleto/incubator/CHOCADEIRA-01/config/state
seleto/incubator/CHOCADEIRA-01/actuator/command
seleto/incubator/CHOCADEIRA-01/actuator/state
seleto/incubator/CHOCADEIRA-01/turner/command
seleto/incubator/CHOCADEIRA-01/turner/state
seleto/incubator/CHOCADEIRA-01/alarm
```

## Controle de temperatura

### Atuador

Opcoes:

- resistencia PTC;
- lampada ceramica;
- lampada incandescente protegida;
- resistencia tubular pequena.

Para baixo custo, uma lampada ou resistencia PTC funciona. Para versao
profissional, prefira PTC ou resistencia bem isolada com protecao termica.

### Algoritmo recomendado

Para controle preciso e simples:

1. Controle principal por histerese fina.
2. PWM lento/SSR para evitar liga/desliga agressivo.
3. Protecao por limite maximo absoluto.

Exemplo:

```text
targetTemp = 37.5
tempDeadband = 0.2
tempMaxSafety = 39.0

Se temperatura <= 37.3: liga aquecimento
Se temperatura >= 37.7: desliga aquecimento
Se temperatura >= 39.0: desliga aquecimento e dispara alarme critico
```

Para uma versao mais precisa:

- usar PID com janela de tempo;
- limitar potencia maxima;
- manter histerese de seguranca;
- registrar overshoot.

### Controle esperado no app

Campos:

- Temperatura alvo.
- Histerese.
- Temperatura maxima de seguranca.
- Modo de controle: automatico/manual.
- Estado atual do aquecedor.
- Grafico historico.
- Alarme de baixa/alta temperatura.

## Controle de umidade

### Aumentar umidade

Atuadores possiveis:

- mini umidificador ultrassonico;
- bomba peristaltica pingando agua em bandeja;
- resistencia pequena aquecendo agua;
- valvula/bomba para reabastecer reservatorio.

Baixo custo recomendado:

- mini umidificador ultrassonico 5V/12V controlado por MOSFET.

### Diminuir umidade

Atuadores possiveis:

- exaustor 12V;
- entrada/saida de ar com cooler;
- abrir damper motorizado;
- aumentar ventilacao por tempo limitado.

Baixo custo recomendado:

- cooler/exaustor 12V acionado por MOSFET.

### Algoritmo recomendado

```text
targetHumidity = 52
humidityDeadband = 4
humidityMaxSafety = 75

Se umidade <= 48: liga umidificador
Se umidade >= 52: desliga umidificador

Se umidade >= 56: liga exaustor/desumidificacao
Se umidade <= 52: desliga exaustor/desumidificacao

Se umidade >= 75: dispara alarme critico
```

Durante eclosao:

```text
targetHumidity = 65
deadband = 5
turnerDisabled = true
```

### Controle esperado no app

Campos:

- Umidade alvo.
- Faixa minima/maxima.
- Umidade da fase inicial.
- Umidade da fase final/eclosao.
- Ligar/desligar umidificador manualmente.
- Ligar/desligar exaustor manualmente.
- Grafico historico.
- Alarme de sensor sem leitura.
- Alarme de umidade fora da faixa.

## Controle de ventilacao

### Tipos de ventilacao

1. Circulacao interna:
   - mistura o ar;
   - evita pontos quentes/frios;
   - normalmente fica sempre ligada em baixa velocidade.

2. Exaustao:
   - troca ar com ambiente externo;
   - ajuda a reduzir umidade;
   - pode ser acionada por tempo ou por limite.

### Atuadores

- cooler 12V interno;
- cooler 12V de exaustao;
- controle por PWM via MOSFET.

### Algoritmo recomendado

```text
Ventilador interno:
- ligado continuo em 30% a 50%
- aumenta para 80% quando temperatura passa do alvo

Exaustor:
- liga se umidade alta
- liga se temperatura alta
- trabalha por pulso para nao derrubar temperatura rapidamente
```

## Rolagem automatica dos ovos

### Mecanica recomendada

Modelo de baixo custo:

- bandeja inclinavel;
- motor DC reduzido;
- dois fins de curso;
- posicoes: esquerda, centro, direita.

Modelo simples:

```text
Inclina para esquerda -> espera X horas -> inclina para direita -> espera X horas.
```

Alternativas:

- servo MG996R para bandejas pequenas;
- motor de micro-ondas com temporizacao;
- motor DC com reducao e fim de curso;
- motor de passo para maior precisao.

Para precisao e robustez, prefira:

- motor DC reduzido;
- ponte H;
- fim de curso esquerda/direita;
- sensor de corrente opcional para detectar travamento.

### Parametros no app

- Ativar/desativar rolagem.
- Intervalo entre rolagens.
- Duracao maxima do movimento.
- Angulo/posicao alvo.
- Dia para parar rolagem.
- Modo manual: esquerda/centro/direita.
- Historico de viragens.
- Alarme de falha ao atingir fim de curso.

### Regras de seguranca

```text
Se motor acionado por mais de X segundos sem fim de curso:
  desligar motor
  marcar falha
  enviar alerta

Se periodo final de incubacao:
  bloquear viragem automatica
```

## Camera interna

### Opcao 1: ESP32-CAM

Mais barata e integrada.

Vantagens:

- custo baixo;
- Wi-Fi integrado;
- pode transmitir MJPEG;
- facil colocar dentro da chocadeira.

Limites:

- qualidade basica;
- pouca luz exige LED infravermelho ou iluminacao fraca;
- streaming via MQTT nao e adequado;
- melhor transmitir por HTTP/MJPEG local ou via servidor proxy.

Uso recomendado:

```text
ESP32 principal controla a chocadeira.
ESP32-CAM separado transmite video.
App exibe stream HTTP/MJPEG ou snapshot.
MQTT apenas informa status da camera e URL.
```

### Opcao 2: Camera IP Wi-Fi barata

Vantagens:

- melhor imagem;
- app pode acessar RTSP/HTTP se a camera suportar;
- menos carga no ESP32.

Desvantagens:

- integracao depende do modelo;
- alguns modelos dependem de nuvem proprietaria;
- nem sempre expõem RTSP.

### Opcao 3: Raspberry Pi Zero 2 W + camera

Mais profissional para video.

Vantagens:

- melhor controle sobre streaming;
- suporta WebRTC/RTSP/HLS;
- melhor qualidade que ESP32-CAM.

Desvantagens:

- custo maior;
- maior consumo;
- mais manutencao.

### Recomendacao para este projeto

Para baixo custo:

- usar `ESP32-CAM` como modulo de camera separado.

Para versao profissional:

- usar camera IP RTSP ou Raspberry Pi Zero 2 W.

### Como integrar camera no app

No app, criar tela `Chocadeira` com:

- card de video/snapshot;
- botao atualizar imagem;
- indicador camera online/offline;
- temperatura/umidade sobrepostos no video;
- historico de snapshots em eventos criticos;
- URL configuravel da camera;
- modo local/remoto.

O MQTT deve enviar apenas:

```json
{
  "cameraOnline": true,
  "streamUrl": "http://192.168.1.50:81/stream",
  "snapshotUrl": "http://192.168.1.50/capture"
}
```

O video em si nao deve passar por MQTT.

## Ligacoes sugeridas no ESP32

Pinagem proposta para ESP32 DevKit:

| Funcao | GPIO sugerido | Observacao |
| --- | --- | --- |
| SHT31 SDA | GPIO 21 | I2C |
| SHT31 SCL | GPIO 22 | I2C |
| DS18B20 | GPIO 4 | OneWire com resistor pull-up 4.7k |
| Aquecedor SSR/rele | GPIO 23 | Saida digital |
| Umidificador MOSFET/rele | GPIO 19 | Saida digital |
| Exaustor MOSFET | GPIO 18 | PWM opcional |
| Ventilador interno MOSFET | GPIO 5 | PWM opcional |
| Motor rolagem IN1 | GPIO 16 | Ponte H |
| Motor rolagem IN2 | GPIO 17 | Ponte H |
| Fim de curso esquerda | GPIO 32 | Entrada pull-up |
| Fim de curso direita | GPIO 33 | Entrada pull-up |
| Buzzer | GPIO 25 | Alarme local |
| LED status | GPIO 2 | Status |

Evitar GPIOs de boot sensiveis quando possivel. Se usar, testar inicializacao.

## Eletrica e seguranca

Obrigatorio:

- fonte dimensionada;
- fusivel na entrada;
- isolamento entre AC e ESP32;
- caixa fechada para reles/SSR;
- aterramento quando houver carga AC;
- protecao mecanica contra contato com resistencia;
- sensor de temperatura redundante;
- corte de seguranca por temperatura maxima;
- watchdog no firmware.

Para aquecimento em AC:

- preferir SSR de qualidade ou rele com margem;
- nunca deixar terminal AC exposto;
- usar cabo compativel com corrente;
- prever dissipacao do SSR.

## Firmware do ESP32

### Estados principais

```text
BOOT
CONFIGURANDO_WIFI
MQTT_CONECTANDO
CONTROLE_ATIVO
ALARME
MODO_MANUAL
FALHA_SENSOR
FALHA_ATUADOR
```

### Loop principal

```text
1. Ler sensores.
2. Validar leituras.
3. Atualizar controle de temperatura.
4. Atualizar controle de umidade.
5. Atualizar ventilacao.
6. Verificar agenda de rolagem.
7. Publicar telemetria MQTT.
8. Processar comandos MQTT.
9. Registrar alarmes.
```

### Payload de telemetria

Topico:

```text
seleto/incubator/CHOCADEIRA-01/telemetry
```

Payload:

```json
{
  "deviceId": "CHOCADEIRA-01",
  "online": true,
  "message": "Chocadeira operando em modo automatico",
  "temperatureC": 37.5,
  "temperatureBackupC": 37.4,
  "humidityPercent": 52.0,
  "heaterOn": true,
  "humidifierOn": false,
  "dehumidifierOn": false,
  "circulationFanPercent": 40,
  "exhaustFanOn": false,
  "turnerEnabled": true,
  "turnerPosition": "LEFT",
  "turnerLastRunAt": "2026-10-09T13:30:00-03:00",
  "turnerNextRunAt": "2026-10-09T15:30:00-03:00",
  "incubationDay": 8,
  "lockdown": false,
  "cameraOnline": true,
  "streamUrl": "http://192.168.1.50:81/stream",
  "uptimeMs": 1234567
}
```

### Comando de configuracao

Topico:

```text
seleto/incubator/CHOCADEIRA-01/config/command
```

Payload:

```json
{
  "commandId": "cfg-001",
  "temperatureTargetC": 37.5,
  "temperatureDeadbandC": 0.2,
  "temperatureMaxSafetyC": 39.0,
  "humidityTargetPercent": 52,
  "humidityDeadbandPercent": 4,
  "hatchHumidityTargetPercent": 65,
  "turnerEnabled": true,
  "turnerIntervalMinutes": 180,
  "turnerStopDay": 18,
  "incubationStartDate": "2026-10-09",
  "species": "galinha"
}
```

Resposta:

```text
seleto/incubator/CHOCADEIRA-01/config/ack
```

```json
{
  "ok": true,
  "commandId": "cfg-001",
  "message": "Configuracao salva na chocadeira"
}
```

### Comando manual de atuador

Topico:

```text
seleto/incubator/CHOCADEIRA-01/actuator/command
```

Payload:

```json
{
  "commandId": "manual-001",
  "mode": "manual",
  "heater": "off",
  "humidifier": "on",
  "exhaust": "off",
  "fanPercent": 50,
  "durationSeconds": 60
}
```

### Comando de rolagem

Topico:

```text
seleto/incubator/CHOCADEIRA-01/turner/command
```

Payload:

```json
{
  "commandId": "turn-001",
  "action": "move",
  "target": "RIGHT"
}
```

## Integracao no app SELETO

### Nova aba/tela

Criar modulo:

```text
Chocadeira
```

Secoes:

- Visao geral.
- Temperatura.
- Umidade.
- Ventilacao.
- Rolagem.
- Camera.
- Alertas.
- Historico.
- Configuracoes avancadas.

### Cards principais

- Temperatura atual.
- Umidade atual.
- Dia de incubacao.
- Proxima rolagem.
- Aquecedor ligado/desligado.
- Umidificador ligado/desligado.
- Exaustor ligado/desligado.
- Camera online/offline.
- Modo automatico/manual.

### Controles

- Temperatura alvo.
- Umidade alvo.
- Umidade de eclosao.
- Histerese de temperatura.
- Histerese de umidade.
- Velocidade de ventilacao.
- Intervalo de rolagem.
- Dia de parada de rolagem.
- Acionar rolagem manual.
- Pausar chocadeira.
- Resetar ciclo de incubacao.

### Alertas

- Temperatura alta.
- Temperatura baixa.
- Umidade alta.
- Umidade baixa.
- Sensor principal sem leitura.
- Divergencia entre sensores.
- Falha no aquecedor.
- Falha no umidificador.
- Falha na rolagem.
- Camera offline.
- ESP offline.
- Energia reiniciada.

## Banco local/app

Sugestao de entidades:

```text
incubators
incubator_settings
incubator_readings
incubator_events
incubator_turner_events
incubator_camera_snapshots
```

Campos essenciais:

```text
device_id
tenant_id
name
species
incubation_start_date
expected_hatch_date
temperature_target_c
humidity_target_percent
hatch_humidity_target_percent
turner_interval_minutes
turner_stop_day
last_seen_at
online
```

## Logica de controle preciso

### Temperatura

Controle simples:

```text
if temp <= target - deadband:
  heater = ON
if temp >= target + deadband:
  heater = OFF
```

Controle profissional:

```text
PID calcula potencia
SSR aplica potencia em janela de 2 a 10 segundos
limite maximo desliga tudo
```

### Umidade

```text
if humidity <= target - deadband:
  humidifier = ON
  exhaust = OFF

if humidity >= target:
  humidifier = OFF

if humidity >= target + deadband:
  exhaust = ON

if humidity <= target:
  exhaust = OFF
```

### Ventilacao

```text
fanPercent = baseFanPercent

if temp > target + 0.3:
  fanPercent = highFanPercent

if humidity > target + deadband:
  exhaust = ON
```

### Rolagem

```text
if turnerEnabled and incubationDay < turnerStopDay:
  if now >= nextTurnAt:
    moveToNextPosition()
    publishTurnerEvent()
```

## Calibracao

Antes de colocar ovos:

1. Rodar chocadeira vazia por 24 horas.
2. Comparar sensor principal com termometro confiavel.
3. Ajustar offset de temperatura.
4. Comparar umidade com higrometro confiavel.
5. Ajustar offset de umidade.
6. Validar estabilidade em 37,5 °C.
7. Validar resposta do umidificador.
8. Validar exaustao.
9. Validar rolagem por pelo menos 20 ciclos.
10. Validar alarme de sensor desconectado.

Offsets no app:

```text
temperatureOffsetC
humidityOffsetPercent
backupTemperatureOffsetC
```

## Custo estimado por versao

Valores variam muito por fornecedor, mas o projeto pode ser planejado assim:

### MVP baixo custo

- ESP32 DevKit.
- SHT31/SHT30.
- DS18B20.
- Modulo rele ou SSR.
- Cooler 12V.
- Umidificador pequeno.
- Motor DC reduzido.
- Ponte H.
- Fonte 12V.
- ESP32-CAM.
- Caixa/isolamento.

Faixa esperada: baixo custo, ideal para prototipo e pequena escala.

### Versao melhorada

- Sensores melhores.
- SSR de melhor qualidade.
- Motor com fim de curso.
- Camera IP/RTSP.
- Fonte industrial.
- Caixa eletrica.
- Display local.

Faixa esperada: custo medio, mais confiavel para uso diario.

### Versao profissional

- PCB propria.
- Fonte e protecoes industriais.
- Sensores redundantes.
- Camera RTSP dedicada.
- Firmware com OTA.
- Logs locais.
- Watchdog fisico.
- Certificacao eletrica se for vender.

Faixa esperada: maior custo, adequada para pequena/media producao.

## Minha recomendacao de implementacao

### Fase 1: Prototipo funcional

- ESP32 DevKit.
- SHT31.
- DS18B20.
- Rele/SSR do aquecedor.
- Cooler interno.
- Umidificador.
- Exaustor.
- Motor de rolagem com ponte H.
- MQTT basico.
- Tela no app com temperatura, umidade, botoes manuais e telemetria.

### Fase 2: Precisao e seguranca

- PID/histerese melhorado.
- Fim de curso na rolagem.
- Alarmes.
- Historico local.
- Offset de calibracao.
- Watchdog.
- Teste de falha de sensor.

### Fase 3: Camera

- ESP32-CAM separada.
- Snapshot no app.
- Stream local.
- Status da camera via MQTT.

### Fase 4: Escala

- Multichocadeiras.
- Perfis por especie.
- Relatorios.
- Comparativo de taxa de eclosao.
- Manutencao preventiva.
- Permissoes por usuario/propriedade.

## Referencias consultadas

- Projetos ESP32 com incubadora e MQTT mostram que ESP32 + sensores + MQTT e
  uma arquitetura viavel para chocadeiras conectadas:
  https://github.com/AdelSehic/esp32-incubator
- Projetos de chocadeira com DHT22, PID, aquecedor e viragem automatica
  confirmam o desenho basico de controle:
  https://projectech.in/projects/egg-incubator-temperature-humidity-monitor/
- Projetos de controlador automatico de chocadeira tambem usam controle de
  temperatura, umidade, ventilacao e parada de viragem no periodo final:
  https://projectech.in/projects/automatic-egg-incubator-controller-temperature-humidity-egg-turning/
- O sensor SHT31/SHT3x e uma opcao mais adequada que sensores muito simples
  para controle de temperatura/umidade:
  https://cdn-shop.adafruit.com/product-files/2857/Sensirion_Humidity_SHT3x_Datasheet_digital-767294.pdf
- ESP32-CAM com OV2640 e uma opcao comum e barata para camera embarcada, mas
  com limitacoes de qualidade e processamento:
  https://www.espboards.dev/blog/esp32-camera-modules-compared/

