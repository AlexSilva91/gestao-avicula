# Manual de conexão do ESP32 com o app GRANJA SELETO

Este manual usa o firmware:

`docs/hardware/esp32_granja_seleto/granja_seleto_wifi_bluetooth.ino`

O firmware permite controlar o ESP32 de duas formas:

- Wi-Fi: o app informa o IP/endpoint do ESP32.
- Bluetooth: o app informa o identificador Bluetooth do ESP32.

> Observação importante: por enquanto o firmware está focado no módulo relé de 4 canais. A tela de Integrações do app GRANJA SELETO procura o ESP32 automaticamente, testa `/api/status`, exibe a resposta em um terminal visual, permite testar cada canal separadamente e envia a agenda diária para o ESP salvar em cache local.

## 1. Materiais

- ESP32 com Bluetooth Classic, de preferência ESP32 DevKit V1.
- Cabo USB de dados.
- IDE do Arduino.
- Celular Android com o app GRANJA SELETO instalado.
- Rede Wi-Fi 2.4 GHz.
- Módulo relé de 4 canais 5 V/3.3 V compatível.

## 2. Preparar a IDE do Arduino

1. Abra a IDE do Arduino.
2. Vá em `Arquivo > Preferências`.
3. Em `URLs adicionais para Gerenciadores de Placas`, adicione:

```text
https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json
```

4. Vá em `Ferramentas > Placa > Gerenciador de Placas`.
5. Instale `esp32 by Espressif Systems`.
6. Selecione a placa em `Ferramentas > Placa`, por exemplo `ESP32 Dev Module`.
7. Selecione a porta USB correta em `Ferramentas > Porta`.

## 3. Subir o script no ESP32

1. Abra a IDE do Arduino.
2. Vá em `Arquivo > Novo`.
3. Apague o conteúdo padrão do sketch.
4. Abra o arquivo `granja_seleto_wifi_bluetooth.ino`.
5. Copie todo o conteúdo do arquivo.
6. Cole o conteúdo no sketch novo da IDE do Arduino.
7. Conecte o ESP32 no computador usando um cabo USB de dados.
8. Vá em `Ferramentas > Placa` e selecione `ESP32 Dev Module`.
9. Vá em `Ferramentas > Porta` e selecione a porta do ESP32.
10. Se quiser gravar a rede Wi-Fi direto no código, edite:

```cpp
const char* defaultWifiSsid = "";
const char* defaultWifiPassword = "";
```

Exemplo:

```cpp
const char* defaultWifiSsid = "MinhaRede";
const char* defaultWifiPassword = "MinhaSenha";
```

11. Clique em `Verificar`.
12. Clique em `Carregar`.
13. Aguarde a mensagem de upload concluído.
14. Abra `Ferramentas > Monitor Serial`.
15. Configure a velocidade do Monitor Serial para `115200 baud`.
16. Aperte o botão `EN` ou `RESET` no ESP32.

No Monitor Serial, procure:

```text
GRANJA SELETO - ESP32 Rele 4 canais
AP de configuracao: GRANJA-SELETO-SETUP / IP 192.168.4.1
Wi-Fi conectado. IP: 192.168.x.x
Bluetooth: GRANJA_SELETO_RELE
```

Se o Wi-Fi ainda não foi configurado, a mensagem esperada será:

```text
Wi-Fi nao conectado. Use o AP ou Bluetooth para configurar.
Bluetooth: GRANJA_SELETO_RELE
```

Anote o IP mostrado quando o ESP32 conectar na rede da granja.

Se a IDE não conseguir enviar o sketch:

1. Clique em `Carregar`.
2. Quando aparecer `Connecting...`, segure o botão `BOOT` do ESP32.
3. Quando aparecer `Writing...`, solte o botão `BOOT`.
4. Aguarde o upload finalizar.

Se a porta serial não aparecer, troque o cabo USB. Muitos cabos só carregam energia e não transferem dados.

## 4. Configurar Wi-Fi sem editar o código

Se você deixou SSID e senha vazios, o ESP32 cria uma rede de configuração.

1. No celular, conecte na rede:

```text
GRANJA-SELETO-SETUP
```

2. Use a senha:

```text
seleto1234
```

3. Abra o navegador no celular e acesse:

```text
http://192.168.4.1
```

4. Preencha o nome da rede Wi-Fi da granja e a senha.
5. Toque em `Salvar e conectar`.
6. Veja o novo IP no Monitor Serial ou acesse:

```text
http://192.168.4.1/api/status
```

## 5. Testar por Wi-Fi no navegador

Com celular e ESP32 na mesma rede Wi-Fi, abra:

```text
http://IP_DO_ESP32/api/ping
```

Exemplo:

```text
http://192.168.0.50/api/ping
```

Resposta esperada:

```json
{"ok":true,"deviceId":"GRANJA-SELETO-RELE-01"}
```

Teste o estado do canal 1:

```text
http://IP_DO_ESP32/api/relay?channel=1
```

Teste o status geral:

```text
http://IP_DO_ESP32/api/status
```

## 6. Configurar Wi-Fi no app GRANJA SELETO

1. Abra o app GRANJA SELETO.
2. Entre em `Operações`.
3. Abra `Integrações`.
4. Aguarde a varredura automática do painel `AUTO SCAN`.
5. Se o ESP32 estiver na mesma rede Wi-Fi do celular, o app preenche o endpoint sozinho.
6. Confira se o terminal mostra:

```text
ESP> handshake OK
ESP> ESP conectado
JSON> {
```

7. Se a varredura automática não encontrar, conecte o celular na rede:

```text
GRANJA-SELETO-SETUP
```

8. Use a senha:

```text
seleto1234
```

9. Volte ao app e toque em `Detectar ESP`.
10. Na seção `Iluminação`, ative `Ativar automação de luz`.
11. Selecione `Wi-Fi`.
12. Em `Endpoint/IP do controlador`, confirme o endpoint detectado:

```text
http://IP_DO_ESP32
```

Exemplo:

```text
http://192.168.0.50
```

13. Preencha os GPIOs dos canais conforme o firmware:

| Canal | GPIO padrão |
| --- | --- |
| 1 | 23 |
| 2 | 22 |
| 3 | 21 |
| 4 | 19 |

14. Em cada canal, preencha `Liga às` e `Desliga às`.
15. Toque em `Salvar`.
16. Toque em `Testar Wi-Fi`.
17. Use `Ligar`, `Desligar` ou `Pulso` para testar cada canal de forma independente.
18. Toque em `Sincronizar agenda`.
19. Confira no terminal visual se aparece `agenda canal X salva em cache`.

Depois da sincronização, o ESP mantém a agenda na memória flash. Se reiniciar, a agenda continua salva. Como não há módulo RTC com bateria, o horário só fica confiável quando o ESP atualiza via NTP pela internet ou quando o app envia a hora atual ao tocar em `Sincronizar agenda`.

## 7. Testar relé por Wi-Fi

Para ligar o canal 1, envie um POST para:

```text
http://IP_DO_ESP32/api/relay
```

Com os campos:

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

Se quiser testar de um computador na mesma rede:

```bash
curl -X POST "http://IP_DO_ESP32/api/relay" -d "channel=1" -d "state=pulse"
```

Para enviar uma agenda diária para o canal 1:

```bash
curl -X POST "http://IP_DO_ESP32/api/channel_schedule" \
  -d "channel=1" \
  -d "enabled=1" \
  -d "on=06:00" \
  -d "off=18:00" \
  -d "days=127"
```

Para sincronizar a hora pelo app/computador quando o ESP estiver sem internet:

```bash
curl -X POST "http://IP_DO_ESP32/api/time" -d "epoch=1735689600"
```

O campo `days=127` significa todos os dias da semana.

## 8. Configurar Bluetooth

O firmware usa Bluetooth Classic Serial SPP.

1. No Android, abra `Configurações > Bluetooth`.
2. Procure o dispositivo:

```text
GRANJA_SELETO_RELE
```

3. Faça o pareamento.
4. Se o Android pedir PIN, tente:

```text
1234
```

ou:

```text
0000
```

## 9. Testar Bluetooth fora do app

Para validar o ESP32 antes do app, use um app de terminal Bluetooth Serial no Android.

1. Conecte ao dispositivo `GRANJA_SELETO_RELE`.
2. Envie:

```text
PING
```

Resposta esperada:

```json
{"ok":true,"transport":"bluetooth"}
```

3. Envie:

```text
STATUS
```

4. Teste o relé:

```text
RELAY 1 ON
RELAY 1 OFF
PULSE 1
```

5. Envie uma agenda para o canal 1:

```text
SCHEDULE 1 1 06:00 18:00 127
```

6. Envie a hora atual em epoch se o ESP estiver sem internet:

```text
TIME 1735689600
```

7. Também é possível configurar Wi-Fi por Bluetooth:

```text
WIFI Nome da Rede|Senha da Rede
```

## 10. Configurar Bluetooth no app GRANJA SELETO

1. Abra o app GRANJA SELETO.
2. Entre em `Operações`.
3. Abra `Integrações`.
4. Ative `Ativar automação de luz`.
5. Selecione `Bluetooth`.
6. Em `Identificador Bluetooth`, informe:

```text
GRANJA_SELETO_RELE
```

7. Configure os canais GPIO `23`, `22`, `21` e `19`.
8. Toque em `Salvar`.
9. Toque em `Testar Bluetooth`.
10. Teste os canais.

## 11. Problemas comuns

| Sintoma | Causa provável | Solução |
| --- | --- | --- |
| A IDE não envia o sketch | Cabo USB só carrega energia | Use cabo USB de dados |
| Não aparece porta serial | Driver USB ausente | Instale o driver CH340 ou CP210x |
| Wi-Fi não conecta | Rede 5 GHz | Use rede 2.4 GHz |
| `api/ping` não abre | Celular em outra rede | Coloque celular e ESP32 no mesmo Wi-Fi |
| Bluetooth não aparece | Placa sem Bluetooth Classic | Use ESP32 DevKit comum |
| Relé liga invertido | Módulo ativo em nível baixo/alto | Altere `relayActiveLow` no firmware |
| Agenda não executa após reiniciar | ESP sem hora válida | Conecte na internet para NTP ou toque em `Sincronizar agenda` no app |

## 12. Resumo dos valores padrão

| Item | Valor |
| --- | --- |
| Device ID | `GRANJA-SELETO-RELE-01` |
| Bluetooth | `GRANJA_SELETO_RELE` |
| AP de configuração | `GRANJA-SELETO-SETUP` |
| Senha do AP | `seleto1234` |
| IP do AP | `192.168.4.1` |
| Canal 1 | GPIO 23 |
| Canal 2 | GPIO 22 |
| Canal 3 | GPIO 21 |
| Canal 4 | GPIO 19 |
