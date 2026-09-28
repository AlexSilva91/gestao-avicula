# Lista de Sensores para Comprar

Esta lista considera a integracao criada no app GRANJA SELETO e no firmware do ESP32, mantendo o fluxo atual de iluminacao/reles.

## Lista principal

| Uso | Comprar | Quantidade |
| --- | --- | ---: |
| Temperatura e umidade do ar | Sensor DHT22 / AM2302 ou, preferencialmente, SHT31 I2C | 1 |
| Balanca de racao | Modulo HX711 amplificador para celula de carga | 1 |
| Balanca de racao | Celula de carga conforme capacidade desejada: 50 kg, 100 kg ou 200 kg | 1 |
| Botoes da balanca | Botao push momentaneo para tara, calibracao e taxa | 3 |
| Nivel simples do reservatorio | Sensor de nivel tipo boia horizontal/vertical | 1 a 3 |
| Nivel percentual do reservatorio | Sensor ultrassonico JSN-SR04T a prova d'agua | 1 |
| Nivel apenas para bancada/teste | Sensor ultrassonico HC-SR04 comum | 1 |
| Temperatura da agua | Sensor DS18B20 a prova d'agua | 1 |
| pH da agua | Kit sensor de pH com placa condicionadora | 1 |
| TDS/condutividade | Kit sensor TDS/EC com placa condicionadora | 1 |
| Leitura analogica mais estavel | Modulo ADS1115 16-bit ADC I2C | 1 |
| Protecao e montagem | Caixa plastica IP65, prensa-cabos, conectores, fios e bornes | 1 kit |

## Recomendacao direta para sensor de nivel

Para o projeto atual, a recomendacao mais equilibrada e:

1. **Mais barato e funcional para caixa d'agua:** sensor de nivel tipo boia.
2. **Melhor custo-beneficio para mostrar porcentagem:** sensor ultrassonico JSN-SR04T.
3. **Nao recomendado para instalacao definitiva em ambiente umido:** HC-SR04 comum.

### Opcao 1: boia de nivel

Use quando voce precisa saber se o reservatorio esta:

- vazio;
- baixo;
- medio;
- cheio.

Como funciona:

- A boia funciona como uma chave liga/desliga.
- Pode ser ligada diretamente em um GPIO do ESP32 ou Arduino.
- No firmware, use o pino como `INPUT_PULLUP`.
- Quando a boia fecha contato com o GND, o ESP32 interpreta como nivel atingido.

Ligacao recomendada:

```text
GPIO do ESP32 ---- boia ---- GND
```

Leitura esperada:

```text
HIGH = boia aberta / nivel nao atingido
LOW  = boia fechada / nivel atingido
```

Vantagens:

- E a opcao mais barata.
- E simples de instalar.
- Nao precisa calibrar distancia.
- Funciona bem para agua.
- E mais confiavel que fio exposto dentro da agua.

Limitacoes:

- Nao informa porcentagem exata.
- Cada ponto de nivel precisa de uma boia.
- Para saber baixo, medio e cheio, use 3 boias.

Compra recomendada:

- `Sensor de nivel de agua tipo boia horizontal`
- Comprar 1 unidade para alerta simples ou 3 unidades para baixo/medio/cheio.

### Opcao 2: JSN-SR04T

Use quando voce quer mostrar o nivel em porcentagem no app.

Como funciona:

- O sensor fica na tampa ou parte superior do reservatorio.
- Ele mede a distancia ate a agua.
- O ESP32 converte a distancia em percentual.

Formula:

```text
nivel_percentual = (distancia_vazia - distancia_atual) / (distancia_vazia - distancia_cheia) * 100
```

Exemplo:

```text
distancia_vazia = 100 cm
distancia_cheia = 20 cm
distancia_atual = 40 cm

nivel = (100 - 40) / (100 - 20) * 100
nivel = 60 / 80 * 100
nivel = 75%
```

Vantagens:

- Nao encosta na agua.
- Nao oxida como fio exposto.
- Permite mostrar porcentagem no app.
- A ponta do sensor e resistente a umidade.
- E mais adequado para reservatorio que o HC-SR04 comum.

Limitacoes:

- Nao deve ficar submerso.
- O modulo eletronico deve ficar protegido em caixa.
- Pode errar se houver muita espuma, respingo, vapor ou parede estreita.
- Precisa divisor de tensao ou conversor de nivel no pino `ECHO` quando usado com ESP32.

Ligacao recomendada no ESP32:

```text
JSN-SR04T VCC  -> 5V
JSN-SR04T GND  -> GND
JSN-SR04T TRIG -> GPIO livre do ESP32
JSN-SR04T ECHO -> divisor de tensao -> GPIO livre do ESP32
```

Divisor de tensao simples para proteger o ESP32:

```text
ECHO ---- resistor 1k ---- GPIO ESP32
GPIO ---- resistor 2k ---- GND
```

### Opcao 3: HC-SR04

Use somente para:

- prototipo;
- teste de bancada;
- ambiente seco;
- demonstracao rapida.

Nao e a melhor compra para caixa d'agua real, porque a placa e os transdutores ficam expostos. Em ambiente umido, a chance de oxidar e dar leitura ruim e maior.

Vantagens:

- Muito barato.
- Facil de achar.
- Facil de testar com Arduino ou ESP32.

Limitacoes:

- Nao e a prova d'agua.
- Trabalha com 5V.
- O `ECHO` tambem precisa ser reduzido para 3,3V no ESP32.
- Deve ficar protegido de umidade e respingos.

### Qual comprar afinal?

Para o GRANJA SELETO:

| Necessidade | Sensor indicado | Motivo |
| --- | --- | --- |
| Apenas saber se chegou no nivel minimo ou maximo | Boia de nivel | Mais barato, simples e confiavel |
| Saber baixo/medio/cheio | 3 boias de nivel | Barato e sem calibracao complexa |
| Mostrar porcentagem no app | JSN-SR04T | Mede distancia sem tocar na agua |
| Testar rapidamente em bancada | HC-SR04 | Barato, mas nao ideal para campo |
| Medir racao/grao dentro de reservatorio | JSN-SR04T ou celula de carga | Ultrassom estima; celula de carga pesa melhor |

Recomendacao final:

- Para venda acessivel: entregar com **1 boia de nivel minimo** no plano basico.
- Para plano melhor: entregar com **JSN-SR04T** para mostrar porcentagem.
- Para maior seguranca: usar **JSN-SR04T + boia de nivel minimo**, assim o sistema tem medicao percentual e tambem um alerta fisico simples.

## Recomendacao de compra

1. Preferir SHT31 em vez de DHT22, se o custo permitir. O SHT31 costuma ser mais estavel e usa barramento I2C.
2. Para a balanca, comprar HX711 junto com uma celula de carga compativel com o peso maximo real da racao ou insumo.
3. Para temperatura da agua, usar DS18B20 inox a prova d'agua.
4. Para pH, comprar kit completo com sonda e placa condicionadora, nao apenas a sonda.
5. Para TDS/EC, comprar kit completo com placa condicionadora.
6. Para nivel simples de agua, usar boia em GPIO digital com `INPUT_PULLUP`.
7. Para nivel percentual de agua, usar JSN-SR04T com divisor de tensao no `ECHO`.
8. Para pH, TDS e nivel analogico, usar ADS1115 para leitura mais estavel que o ADC interno do ESP32.

## Pinos previstos no firmware atual

| Funcao | GPIO |
| --- | --- |
| HX711 DT | GPIO32 |
| HX711 SCK | GPIO33 |
| DHT22 ar | GPIO27 |
| Nivel da agua analogico | GPIO34 |
| Nivel por boia | Qualquer GPIO digital livre |
| Ultrassonico TRIG | Qualquer GPIO digital livre |

Tara, calibracao e taxa da balanca sao controladas pelo app; nao compre botoes
dedicados para a balanca nesta versao.
| Ultrassonico ECHO | Qualquer GPIO digital livre com protecao 3.3 V |
| Temperatura da agua analogica | GPIO35 |
| pH analogico | GPIO36 |
| TDS analogico | GPIO39 |

Os reles atuais continuam nos GPIOs `23`, `22`, `21` e `19`.

Para usar boia ou ultrassonico no lugar do nivel analogico, o firmware deve ser ajustado. O firmware atual ainda lista `GPIO34` como entrada analogica de nivel.

## Observacao importante

O firmware atual ja tem endpoints para:

- `GET /api/scale`
- `POST /api/scale/tare`
- `POST /api/scale/calibrate`
- `POST /api/scale/rate`
- `GET /api/environment`
- `GET /api/water`
- `GET /api/sensors`

Se forem comprados SHT31, DS18B20 digital e ADS1115, o firmware deve ser ajustado para usar I2C e 1-Wire nesses sensores. Isso e recomendado para uma instalacao mais confiavel.

## Referencias tecnicas

- SparkFun HX711 Load Cell Amplifier: https://learn.sparkfun.com/tutorials/load-cell-amplifier-hx711-breakout-hookup-guide
- Adafruit SHT31-D: https://learn.adafruit.com/adafruit-sht31-d-temperature-and-humidity-sensor-breakout
- Analog Devices DS18B20: https://www.analog.com/en/products/ds18b20.html
- Adafruit ADS1115: https://learn.adafruit.com/adafruit-4-channel-adc-breakouts
- DFRobot sensores de agua: https://wiki.dfrobot.com/category-68/
- Sensor de nivel de agua tipo boia horizontal - Bit Maker: https://www.bitmaker.com.br/sensor-de-nivel-de-agua-horizontal
- Sensor ultrassonico JSN-SR04T a prova d'agua - Achei Componentes: https://www.acheicomponentes.com.br/sensor/sensor-ultrassonico-jsn-sr04t-a-prova-d-agua
- Sensor ultrassonico HC-SR04 - Proesi: https://www.proesi.com.br/sensor-de-distancia-ultrassonico-hc-sr04
