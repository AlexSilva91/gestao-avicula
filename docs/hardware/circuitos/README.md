# Circuitos

Cada circuito agora tem seu proprio diretorio, com imagem realista dos componentes, esquema tecnico e observacoes de montagem.

> Atencao: confira sempre a serigrafia do seu modulo antes de energizar. Alguns fornecedores mudam nomes de pinos e cores dos fios.

## Indice

| Circuito | Diretorio | Conteudo |
| --- | --- | --- |
| Balanca | [balanca](balanca/README.md) | ESP32, HX711, celula 50 kg, botoes de tara/calibracao/taxa |
| Ambiente | [ambiente](ambiente/README.md) | ESP32 e DHT22/AM2302 |
| Reservatorio e agua | [reservatorio-agua](reservatorio-agua/README.md) | Nivel, temperatura, pH e TDS/EC |
| Iluminacao | [iluminacao](iluminacao/README.md) | ESP32, modulo rele 4 canais e lampadas |
| Ventiladores | [ventiladores](ventiladores/README.md) | ESP32, modulo rele 8 canais, contatores e ventiladores/exaustores |
| Cameras | [cameras](cameras/README.md) | Cameras IP, PoE, mini PC/NVR e eventos |
| Visao geral | [visao-geral](visao-geral/README.md) | Todos os sensores e circuitos juntos |

## Referencias usadas

- Sensor de Peso 50Kg Celula de Carga - MakerHero: https://www.makerhero.com/produto/sensor-de-peso-50kg-celula-de-carga/
- Manual tecnico de celula 50 kg meia ponte - ShillehTek: https://shillehtek.com/blogs/shillehtek-product-manuals/load-cell-50kg-half-bridge-strain-sensor-manual
- Guia HX711 / celulas de carga - Circuit Journal: https://circuitjournal.com/50kg-load-cells-with-HX711
