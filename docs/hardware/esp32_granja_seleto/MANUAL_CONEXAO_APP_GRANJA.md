# Manual de conexão do ESP32 com o app GRANJA SELETO

Este manual usa o firmware:

`docs/hardware/esp32_granja_seleto/granja_seleto_wifi_bluetooth.ino`

O firmware permite testar o ESP32 de duas formas:

- Wi-Fi: o app informa o IP/endpoint do ESP32.
- Bluetooth: o app informa o identificador Bluetooth do ESP32.

> Observação importante: na conexão Wi-Fi, a tela de Integrações do app GRANJA SELETO procura o ESP32 automaticamente, testa `/api/status`, exibe a resposta em um terminal visual e usa `/api/scale` e `/api/relay` para leitura/acionamento real. Se não encontrar na rede da granja, conecte o celular na rede padrão do ESP32 e toque em `Detectar ESP`.

## 1. Materiais

- ESP32 com Bluetooth Classic, de preferência ESP32 DevKit V1.
- Cabo USB de dados.
- IDE do Arduino.
- Celular Android com o app GRANJA SELETO instalado.
- Rede Wi-Fi 2.4 GHz.
- Opcional: módulo relé 5 V/3.3 V compatível.
- Opcional: HX711 e células de carga, se quiser leitura real de balança.

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
GRANJA SELETO - ESP32 Wi-Fi + Bluetooth
AP de configuracao: GRANJA-SELETO-SETUP / IP 192.168.4.1
Wi-Fi conectado. IP: 192.168.x.x
Bluetooth: GRANJA_SELETO_ESP32
```

Se o Wi-Fi ainda não foi configurado, a mensagem esperada será:

```text
Wi-Fi nao conectado. Use o AP ou Bluetooth para configurar.
Bluetooth: GRANJA_SELETO_ESP32
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
{"ok":true,"deviceId":"GRANJA-SELETO-ESP32-01"}
```

Teste a balança:

```text
http://IP_DO_ESP32/api/scale
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
10. Na seção `Balança`, ative `Ativar balança` se ainda não estiver ativo.
11. Selecione `Wi-Fi`.
12. Em `Nome/ID do dispositivo`, o app deve preencher:

```text
GRANJA-SELETO-ESP32-01
```

13. Em `Endpoint ou IP do ESP32`, o app deve preencher:

```text
http://IP_DO_ESP32
```

Exemplo:

```text
http://192.168.0.50
```

14. Toque em `Testar Wi-Fi`.
15. Toque em `Ler em tempo real` para receber `/api/scale` do ESP32.

Para iluminação:

1. Na seção `Iluminação`, ative `Ativar automação de luz`.
2. Selecione `Wi-Fi`.
3. Em `Endpoint/IP do controlador`, use o mesmo endpoint detectado:

```text
http://IP_DO_ESP32
```

4. Preencha os GPIOs dos canais conforme o firmware:

| Canal | GPIO padrão |
| --- | --- |
| 1 | 23 |
| 2 | 22 |
| 3 | 21 |
| 4 | 19 |

5. Toque em `Salvar`.
6. Toque em `Testar Wi-Fi`.
7. Use `Ligar`, `Desligar` ou `Pulso` nos canais e confira a confirmação no terminal visual.

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

## 8. Configurar Bluetooth

O firmware usa Bluetooth Classic Serial SPP.

1. No Android, abra `Configurações > Bluetooth`.
2. Procure o dispositivo:

```text
GRANJA_SELETO_ESP32
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

1. Conecte ao dispositivo `GRANJA_SELETO_ESP32`.
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

4. Envie:

```text
SCALE
```

5. Teste o relé:

```text
RELAY 1 ON
RELAY 1 OFF
PULSE 1
```

6. Também é possível configurar Wi-Fi por Bluetooth:

```text
WIFI Nome da Rede|Senha da Rede
```

## 10. Configurar Bluetooth no app GRANJA SELETO

1. Abra o app GRANJA SELETO.
2. Entre em `Operações`.
3. Abra `Integrações`.
4. Na seção `Balança`, ative `Ativar balança`.
5. Selecione `Bluetooth`.
6. Em `Nome/ID do dispositivo`, informe:

```text
GRANJA-SELETO-ESP32-01
```

7. Em `Identificador Bluetooth`, informe:

```text
GRANJA_SELETO_ESP32
```

8. Toque em `Salvar`.
9. Toque em `Testar Bluetooth`.
10. Toque em `Ler em tempo real` para validar o fluxo da tela.

Para iluminação:

1. Ative `Ativar automação de luz`.
2. Selecione `Bluetooth`.
3. Em `Identificador Bluetooth`, informe:

```text
GRANJA_SELETO_ESP32
```

4. Configure os canais GPIO `23`, `22`, `21` e `19`.
5. Toque em `Salvar`.
6. Toque em `Testar Bluetooth`.
7. Teste os canais.

## 11. Usar balança real HX711

Por padrão, o firmware simula uma balança estável em torno de 25 kg. Isso permite testar o app mesmo sem módulo HX711.

Para usar HX711 real:

1. Na IDE do Arduino, instale a biblioteca `HX711`.
2. No firmware, altere:

```cpp
#define USE_HX711 0
```

para:

```cpp
#define USE_HX711 1
```

3. Confira os pinos:

```cpp
constexpr uint8_t hx711DataPin = 4;
constexpr uint8_t hx711ClockPin = 5;
```

4. Ajuste a calibração:

```cpp
constexpr float hx711CalibrationFactor = -7050.0f;
```

5. Suba novamente o firmware.

## 12. Problemas comuns

| Sintoma | Causa provável | Solução |
| --- | --- | --- |
| A IDE não envia o sketch | Cabo USB só carrega energia | Use cabo USB de dados |
| Não aparece porta serial | Driver USB ausente | Instale o driver CH340 ou CP210x |
| Wi-Fi não conecta | Rede 5 GHz | Use rede 2.4 GHz |
| `api/ping` não abre | Celular em outra rede | Coloque celular e ESP32 no mesmo Wi-Fi |
| Bluetooth não aparece | Placa sem Bluetooth Classic | Use ESP32 DevKit comum |
| Relé liga invertido | Módulo ativo em nível baixo/alto | Altere `relayActiveLow` no firmware |
| Peso fica simulado | `USE_HX711` está 0 | Mude para 1 e instale a biblioteca HX711 |

## 13. Resumo dos valores padrão

| Item | Valor |
| --- | --- |
| Device ID | `GRANJA-SELETO-ESP32-01` |
| Bluetooth | `GRANJA_SELETO_ESP32` |
| AP de configuração | `GRANJA-SELETO-SETUP` |
| Senha do AP | `seleto1234` |
| IP do AP | `192.168.4.1` |
| Canal 1 | GPIO 23 |
| Canal 2 | GPIO 22 |
| Canal 3 | GPIO 21 |
| Canal 4 | GPIO 19 |
