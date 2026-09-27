# Lista de Sensores para Comprar

Esta lista considera a integracao criada no app GRANJA SELETO e no firmware do ESP32, mantendo o fluxo atual de iluminacao/reles.

## Lista principal

| Uso | Comprar | Quantidade |
| --- | --- | ---: |
| Temperatura e umidade do ar | Sensor DHT22 / AM2302 ou, preferencialmente, SHT31 I2C | 1 |
| Balanca de racao | Modulo HX711 amplificador para celula de carga | 1 |
| Balanca de racao | Celula de carga conforme capacidade desejada: 50 kg, 100 kg ou 200 kg | 1 |
| Botoes da balanca | Botao push momentaneo para tara, calibracao e taxa | 3 |
| Nivel do reservatorio | Sensor de nivel de agua analogico ou sensor ultrassonico de nivel | 1 |
| Temperatura da agua | Sensor DS18B20 a prova d'agua | 1 |
| pH da agua | Kit sensor de pH com placa condicionadora | 1 |
| TDS/condutividade | Kit sensor TDS/EC com placa condicionadora | 1 |
| Leitura analogica mais estavel | Modulo ADS1115 16-bit ADC I2C | 1 |
| Protecao e montagem | Caixa plastica IP65, prensa-cabos, conectores, fios e bornes | 1 kit |

## Recomendacao de compra

1. Preferir SHT31 em vez de DHT22, se o custo permitir. O SHT31 costuma ser mais estavel e usa barramento I2C.
2. Para a balanca, comprar HX711 junto com uma celula de carga compativel com o peso maximo real da racao ou insumo.
3. Para temperatura da agua, usar DS18B20 inox a prova d'agua.
4. Para pH, comprar kit completo com sonda e placa condicionadora, nao apenas a sonda.
5. Para TDS/EC, comprar kit completo com placa condicionadora.
6. Para pH, TDS e nivel analogico, usar ADS1115 para leitura mais estavel que o ADC interno do ESP32.

## Pinos previstos no firmware atual

| Funcao | GPIO |
| --- | --- |
| HX711 DT | GPIO32 |
| HX711 SCK | GPIO33 |
| Botao tara | GPIO13 |
| Botao calibracao | GPIO14 |
| Botao taxa | GPIO26 |
| DHT22 ar | GPIO27 |
| Nivel da agua analogico | GPIO34 |
| Temperatura da agua analogica | GPIO35 |
| pH analogico | GPIO36 |
| TDS analogico | GPIO39 |

Os reles atuais continuam nos GPIOs `23`, `22`, `21` e `19`.

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
