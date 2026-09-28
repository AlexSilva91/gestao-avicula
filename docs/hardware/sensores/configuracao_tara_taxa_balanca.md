# Configuracao, Tara, Calibracao e Taxas da Balanca

Este documento explica, detalhe a detalhe, como configurar a balanca no sistema, o que significa cada campo, como executar tara, como calibrar com peso conhecido, como escolher a taxa de leitura e como interpretar a tolerancia de precisao usada nos testes.

Use este arquivo como guia de implantacao, manutencao e replicacao da balanca em outro ambiente.

## 1. Visao geral da balanca

A balanca do sistema usa:

- ESP32 como controlador.
- Modulo HX711 como conversor/leitor das celulas de carga.
- Celula ou conjunto de celulas de carga para medir o peso.
- App para configurar, testar, zerar, calibrar e acompanhar leituras.
- Firmware do ESP32 expondo endpoints HTTP para o app.

No sistema atual existem duas telas relacionadas a balanca:

- Tela de integracoes de hardware: usada para ativar a balanca, escolher conexao, informar endpoint/IP, definir modo de uso, testar leitura e validar precisao.
- Tela especifica da balanca: usada para leitura direta, tara, calibracao com peso conhecido e alteracao da taxa de leitura.

## 2. Arquivos de referencia no projeto

Consulte estes arquivos quando for replicar ou alterar a integracao:

- `docs/hardware/circuitos/balanca/README.md`
- `docs/hardware/firmware/esp32-granja-seleto/granja_seleto_wifi_bluetooth.ino`
- `lib/features/operations/presentation/pages/hardware_integrations_page.dart`
- `lib/features/operations/presentation/pages/hardware_sensor_pages.dart`
- `lib/core/services/esp_hardware_client.dart`

## 3. Ligacoes eletricas principais

### 3.1. HX711 no ESP32

Ligacao padrao da balanca:

| Modulo HX711 | ESP32 | Funcao |
|---|---:|---|
| DT ou DOUT | GPIO32 | Dados da balanca |
| SCK ou CLK | GPIO33 | Clock da leitura |
| VCC | 3V3 ou 5V conforme modulo | Alimentacao |
| GND | GND | Terra comum |

Observacao importante: celulas de carga de 50 kg com 3 fios normalmente sao meia ponte. Para uma leitura estavel, o ideal e usar 4 celulas com placa combinadora ou uma celula de carga de ponte completa adequada ao HX711.

### 3.2. Controle pelo app

Tara, calibracao e alteracao de taxa sao executadas pelo app por Wi-Fi usando
os endpoints do ESP32. Nesta versao nao ha botoes fisicos dedicados no ESP32
para a balanca.

## 4. Configuracao da balanca

Configuracao e o conjunto de dados que informa ao sistema como acessar e usar a balanca.

### 4.1. Ativar balanca

Campo no app:

- `Ativar balanca`

Chave salva:

- `hardware_scale_enabled`

O que faz:

- Quando ativado, o sistema passa a considerar a balanca como uma integracao disponivel.
- Quando desativado, a balanca pode continuar existindo fisicamente, mas o app nao deve usar essa leitura como parte do fluxo operacional.

Quando ativar:

- Depois que o ESP32 estiver ligado.
- Depois que o HX711 estiver conectado.
- Depois que o endpoint/IP estiver definido.
- Antes de testar leitura em tempo real.

### 4.2. Tipo de conexao

Campo no app:

- `Conexao`

Valores usados:

- `WIFI`
- `BLUETOOTH`

Chave salva:

- `hardware_scale_connection`

Uso recomendado:

- Use `WIFI` como padrao.
- Use `BLUETOOTH` somente se a implantacao realmente for feita por conexao local Bluetooth.

No fluxo Wi-Fi, o app conversa com o ESP32 por endpoints HTTP, por exemplo:

- `GET /api/scale`
- `POST /api/scale/tare`
- `POST /api/scale/calibrate`
- `POST /api/scale/rate`

### 4.3. Nome ou ID do dispositivo

Campo no app:

- `Nome/ID do dispositivo`

Chave salva:

- `hardware_scale_device`

O que colocar:

- Um nome facil de identificar no local.
- Exemplos:
  - `balanca-galpao-01`
  - `balanca-racao`
  - `balanca-entrada-insumos`

Boa pratica:

- Use nomes curtos.
- Inclua o local fisico.
- Nao use nomes genericos como `balanca` se houver mais de uma unidade.

### 4.4. Endpoint ou IP do ESP32

Campo no app:

- `Endpoint ou IP do ESP32`

Chave salva:

- `hardware_scale_endpoint`

Exemplos validos:

- `http://192.168.0.45`
- `http://192.168.1.120`
- `http://granja-seleto.local`

O que esse campo faz:

- Informa para o app onde o ESP32 da balanca esta na rede.
- Sem esse campo, o app nao consegue executar leitura, tara, calibracao ou alteracao de taxa por Wi-Fi.

Erro comum:

- Informar apenas `192.168.0.45` quando o app espera URL completa.

Padrao recomendado:

- Sempre cadastrar com `http://`.

### 4.5. Modo de uso da balanca

Campo no app:

- `Uso da balanca`

Chave salva:

- `hardware_scale_mode`

Modos existentes:

| Modo | Quando usar |
|---|---|
| `BOTH` | Quando a mesma balanca atende entrada de insumos e alimentacao por lote |
| `INGREDIENT_PURCHASE` | Quando a balanca mede entrada/compra de insumos |
| `FEEDING` | Quando a balanca mede racao ou alimentacao por lote |

Como escolher:

- Se o produtor so tem uma balanca, use `Entrada e alimentacao`.
- Se existe uma balanca na area de recebimento de insumos, use `Entrada de insumos`.
- Se existe uma balanca perto da preparacao ou distribuicao de racao, use `Alimentacao por lote`.

### 4.6. Ultima leitura salva

Campo tecnico:

- `hardware_scale_last_weight_kg`

O que representa:

- Ultimo peso lido com sucesso pelo app.
- E salvo em quilogramas.

Importante:

- Esse valor nao substitui a leitura em tempo real.
- Ele serve como referencia local para a interface e para testes.

## 5. Tara da balanca

Tara e o processo de zerar a balanca no estado atual.

Na pratica, tara significa dizer ao sistema:

> "Considere o peso que esta agora na plataforma como zero."

## 5.1. Quando fazer tara

Faca tara:

- Depois de ligar o ESP32 e estabilizar a balanca.
- Antes da primeira calibracao.
- Antes de pesar qualquer item.
- Sempre que trocar bandeja, caixa, recipiente ou suporte.
- Quando a balanca mostrar peso diferente de zero estando vazia.
- Depois de mover a balanca de lugar.
- Depois de manutencao mecanica ou troca de fios.

## 5.2. Quando nao fazer tara

Nao faca tara:

- Com produto em cima da balanca, a menos que esse produto seja um recipiente que deve ser descontado.
- Durante vibracao forte.
- Com a plataforma encostando em parede, estrutura, cabo ou qualquer obstaculo.
- Com leitura instavel.
- Enquanto alguem estiver apoiando a mao na estrutura.

## 5.3. Como executar tara pelo app

Passo a passo:

1. Ligue o ESP32.
2. Abra a tela da balanca.
3. Confira se o endpoint/IP esta preenchido.
4. Deixe a plataforma vazia ou apenas com o recipiente que sera descontado.
5. Aguarde a leitura parar de oscilar.
6. Clique em `Tara`.
7. Confirme se a leitura voltou para `0,000 kg` ou muito proxima disso.

Resultado esperado:

- O app mostra tara confirmada.
- A balanca passa a descontar o peso atual.

## 5.4. Como executar tara pelo endpoint

Endpoint:

```text
POST /api/scale/tare
```

Exemplo:

```bash
curl -X POST http://192.168.0.45/api/scale/tare
```

Resposta esperada:

```json
{
  "ok": true,
  "tare": true,
  "scale": {
    "weightKg": 0.0,
    "offset": 123456,
    "sampleRateHz": 10
  }
}
```

## 5.5. O que a tara salva no ESP32

O firmware salva o valor bruto atual do HX711 como `offset`.

No firmware:

- A leitura bruta vem do HX711.
- A tara grava essa leitura como ponto zero.
- Depois disso, o peso passa a ser calculado removendo esse offset.

Formula simplificada:

```text
peso_kg = (leitura_bruta - offset) / fator_calibracao
```

Onde:

- `leitura_bruta` e o valor atual do HX711.
- `offset` e o zero salvo na tara.
- `fator_calibracao` e o fator calculado na calibracao.

## 6. Calibracao da balanca

Calibracao e o processo de ensinar ao sistema quanto a leitura bruta representa em quilogramas.

Tara zera a balanca.

Calibracao define a proporcao correta entre sinal eletrico e peso real.

## 6.1. Peso conhecido

Campo no app:

- `Peso conhecido`

Valor padrao atual:

- `1,000 kg`

Endpoint:

```text
POST /api/scale/calibrate
```

Parametro:

- `knownWeightKg`

Exemplo:

```bash
curl -X POST "http://192.168.0.45/api/scale/calibrate?knownWeightKg=1.000"
```

O peso conhecido deve ser um peso real, confiavel e medido.

Exemplos bons:

- Peso padrao de 1 kg.
- Peso padrao de 5 kg.
- Saco ou objeto pesado em uma balanca confiavel.

Evite:

- Objeto com peso estimado.
- Recipiente com peso desconhecido.
- Peso leve demais em balanca de capacidade alta.

## 6.2. Melhor pratica para escolher o peso conhecido

Use um peso conhecido proximo da faixa de uso real.

Exemplos:

| Uso da balanca | Peso conhecido recomendado |
|---|---:|
| Pesagem pequena de ingredientes | 1 kg a 5 kg |
| Racao em baldes ou caixas | 5 kg a 20 kg |
| Plataforma de insumos maiores | 20 kg a 50 kg |

Se a balanca for de 50 kg e voce calibrar com apenas 200 g, a leitura pode ficar ruim na faixa mais alta.

## 6.3. Passo a passo correto de calibracao

1. Monte a balanca em local firme.
2. Confira se a plataforma nao encosta em nada.
3. Ligue o ESP32.
4. Aguarde alguns segundos para estabilizar.
5. Deixe a plataforma vazia.
6. Execute `Tara`.
7. Coloque o peso conhecido no centro da plataforma.
8. Informe no app o valor real do peso conhecido em kg.
9. Clique em `Calibrar`.
10. Aguarde a confirmacao.
11. Remova o peso.
12. Confira se a leitura volta para perto de zero.
13. Coloque o peso novamente.
14. Confira se a leitura fica proxima do peso real.

## 6.4. Como o firmware calcula a calibracao

O firmware faz:

```text
fator_calibracao = (leitura_bruta_com_peso - offset) / peso_conhecido_kg
```

Exemplo simplificado:

```text
offset = 100000
leitura com 5 kg = 350000
diferenca = 350000 - 100000 = 250000
peso conhecido = 5 kg
fator = 250000 / 5 = 50000
```

Depois disso:

```text
peso_kg = (leitura_atual - 100000) / 50000
```

Se a leitura atual for `200000`:

```text
peso_kg = (200000 - 100000) / 50000
peso_kg = 2 kg
```

## 6.5. Erros comuns na calibracao

### Peso conhecido igual a zero

Erro esperado:

```text
invalid_known_weight
```

Causa:

- O app ou endpoint recebeu peso conhecido menor ou igual a zero.

Correcao:

- Informar um valor maior que zero.
- Exemplo: `1.000`, `5.000`, `10.000`.

### Leitura bruta sem diferenca

Causa provavel:

- Peso nao foi colocado.
- Celula de carga nao esta conectada corretamente.
- HX711 nao esta lendo variacao.
- A plataforma esta travada mecanicamente.

Correcao:

- Fazer tara com plataforma vazia.
- Colocar peso conhecido real.
- Verificar fios da celula de carga.
- Verificar ligacoes do HX711.

### Peso final negativo

Causas provaveis:

- Tara feita com carga em cima.
- Fios da celula invertidos.
- Celula montada no sentido contrario.

Correcao:

- Retirar carga e fazer tara novamente.
- Revisar ligacao da celula.
- Recalibrar depois da tara.

## 7. Taxa de leitura da balanca

Taxa de leitura e a velocidade com que o HX711 atualiza as amostras.

No sistema atual existem duas opcoes:

- `10 Hz`
- `80 Hz`

Chave salva:

- `hardware_scale_rate_hz`

Endpoint:

```text
POST /api/scale/rate
```

Parametro:

- `rateHz`

Valores aceitos:

- `10`
- `80`

## 7.1. O que significa 10 Hz

`10 Hz` significa ate 10 atualizacoes por segundo no nivel do leitor.

Uso recomendado:

- Pesagem normal.
- Ambiente com vibracao.
- Balanca de racao.
- Entrada de insumos.
- Leitura mais estavel.

Vantagens:

- Menos ruido.
- Mais estabilidade.
- Melhor para validar precisao.
- Mais indicado para pequenos produtores.

Quando usar:

- Quase sempre.
- Principalmente em instalacoes definitivas.

## 7.2. O que significa 80 Hz

`80 Hz` significa ate 80 atualizacoes por segundo no nivel do leitor.

Uso recomendado:

- Testes rapidos.
- Situacoes em que o peso muda rapidamente.
- Diagnostico de resposta da celula de carga.

Pontos de atencao:

- Pode apresentar mais variacao.
- Pode parecer menos estavel.
- Pode exigir melhor montagem mecanica.
- Pode sofrer mais com ruido eletrico.

Quando usar:

- Apenas quando houver necessidade real de resposta mais rapida.
- Para diagnostico ou experimentos.

## 7.3. Taxa do HX711 nao e a mesma coisa que intervalo da tela

Importante:

- A taxa `10 Hz` ou `80 Hz` e a taxa de atualizacao do HX711/firmware.
- A leitura em tempo real do app pode buscar uma amostra em outro intervalo.
- No fluxo atual, a leitura ao vivo do app consulta a balanca periodicamente, por exemplo a cada 1 segundo.

Exemplo:

- HX711 em `10 Hz`: o firmware pode atualizar ate 10 vezes por segundo.
- App lendo a cada 1 segundo: o usuario ve uma atualizacao por segundo.

Isso nao e erro. Sao camadas diferentes:

- Taxa do sensor: velocidade interna da medicao.
- Intervalo do app: frequencia em que a interface consulta o ESP32.

## 7.4. Como alterar a taxa pelo app

Passo a passo:

1. Abra a tela da balanca.
2. Confira se o endpoint/IP do ESP32 esta correto.
3. Selecione `10 Hz` ou `80 Hz`.
4. Salve a configuracao.
5. Faca uma leitura de teste.
6. Se a leitura ficar instavel, volte para `10 Hz`.

## 7.5. Como alterar a taxa pelo endpoint

Para 10 Hz:

```bash
curl -X POST "http://192.168.0.45/api/scale/rate?rateHz=10"
```

Para 80 Hz:

```bash
curl -X POST "http://192.168.0.45/api/scale/rate?rateHz=80"
```

Resposta esperada:

```json
{
  "ok": true,
  "sampleRateHz": 10
}
```

Erro esperado quando o valor e invalido:

```json
{
  "ok": false,
  "error": "invalid_rate"
}
```

Valores invalidos:

- `1`
- `5`
- `20`
- `50`
- `100`

O firmware aceita somente `10` ou `80`.

## 8. Tolerancia de precisao da balanca

A tela de integracoes tambem tem um campo chamado:

- `Tolerancia para precisao`

Valor padrao:

- `0,05 kg`

Esse campo pode ser confundido com taxa, mas nao e a mesma coisa.

## 8.1. O que e tolerancia de precisao

Tolerancia de precisao e o limite maximo de variacao aceito entre leituras de teste.

Exemplo:

```text
tolerancia = 0,05 kg
menor leitura = 10,00 kg
maior leitura = 10,04 kg
variacao = 0,04 kg
resultado = OK
```

Outro exemplo:

```text
tolerancia = 0,05 kg
menor leitura = 10,00 kg
maior leitura = 10,09 kg
variacao = 0,09 kg
resultado = FALHA
```

## 8.2. O que a tolerancia nao faz

A tolerancia:

- Nao altera o HX711.
- Nao altera o ESP32.
- Nao altera a calibracao.
- Nao corrige peso errado.
- Nao substitui tara.

Ela serve para o app decidir se a leitura esta estavel o suficiente.

## 8.3. Valores recomendados de tolerancia

| Tipo de uso | Tolerancia recomendada |
|---|---:|
| Ingredientes pequenos | 0,02 kg a 0,05 kg |
| Racao por balde/caixa | 0,05 kg a 0,10 kg |
| Insumos maiores | 0,10 kg a 0,30 kg |

Para pequenos produtores, comece com:

```text
0,05 kg
```

Depois ajuste conforme:

- Qualidade da celula de carga.
- Tamanho da plataforma.
- Vibracao do local.
- Peso medio medido.
- Necessidade de precisao operacional.

## 9. Leitura atual da balanca

Endpoint:

```text
GET /api/scale
```

Exemplo:

```bash
curl http://192.168.0.45/api/scale
```

Resposta esperada:

```json
{
  "ok": true,
  "enabled": true,
  "weightKg": 12.345,
  "stable": true,
  "ready": true,
  "raw": 712345,
  "offset": 100000,
  "factor": 50000.0000,
  "sampleRateHz": 10,
  "calibrated": true
}
```

Significado dos campos:

| Campo | Significado |
|---|---|
| `ok` | Indica que o firmware respondeu corretamente |
| `enabled` | Indica que a balanca esta ativa no firmware |
| `weightKg` | Peso calculado em quilogramas |
| `stable` | Indicador de estabilidade retornado pelo firmware |
| `ready` | Indica se o HX711 esta pronto para leitura |
| `raw` | Valor bruto lido do HX711 |
| `offset` | Valor salvo pela tara |
| `factor` | Fator salvo pela calibracao |
| `sampleRateHz` | Taxa atual da balanca: 10 ou 80 |
| `calibrated` | Indica se existe fator de calibracao salvo |

## 10. Sequencia recomendada de implantacao

Siga esta ordem em campo:

1. Fixar a celula de carga corretamente.
2. Montar a plataforma sem pontos de atrito.
3. Conectar celula de carga ao HX711.
4. Conectar HX711 ao ESP32.
5. Conectar GND comum.
6. Gravar o firmware no ESP32.
7. Ligar o ESP32.
8. Confirmar que o ESP32 entrou na rede Wi-Fi.
9. Identificar o IP do ESP32.
10. Abrir o app.
11. Ativar a balanca.
12. Selecionar conexao `WIFI`.
13. Informar endpoint com `http://`.
14. Escolher o modo de uso.
15. Salvar.
16. Ler a balanca vazia.
17. Fazer tara.
18. Colocar peso conhecido.
19. Calibrar.
20. Escolher taxa `10 Hz`.
21. Fazer leitura de teste.
22. Rodar leitura em tempo real.
23. Validar tolerancia.
24. Registrar local, nome do dispositivo e peso usado na calibracao.

## 11. Ordem correta: tara, calibracao e taxa

Ordem ideal:

```text
1. Configurar endpoint
2. Salvar configuracao
3. Deixar balanca vazia
4. Fazer tara
5. Colocar peso conhecido
6. Calibrar
7. Definir taxa
8. Testar precisao
```

Nao calibre antes da tara.

Nao valide precisao antes da calibracao.

Nao use `80 Hz` para validar estabilidade inicial, a menos que exista motivo tecnico.

## 12. Checklist de aceitacao

Antes de entregar a balanca como pronta, confirme:

- ESP32 liga corretamente.
- HX711 esta alimentado.
- Plataforma nao encosta em nada.
- Endpoint responde `GET /api/scale`.
- App salva endpoint corretamente.
- Tara retorna leitura proxima de zero.
- Calibracao aceita peso conhecido.
- `calibrated` retorna `true`.
- Peso conhecido aparece corretamente depois da calibracao.
- Taxa esta em `10 Hz` para uso normal.
- Tolerancia esta adequada ao uso.
- Leitura em tempo real nao oscila alem do limite aceito.
- Nome do dispositivo identifica o local fisico.

## 13. Diagnostico rapido

| Sintoma | Causa provavel | Correcao |
|---|---|---|
| App pede endpoint | Endpoint vazio | Informar `http://IP_DO_ESP32` |
| `GET /api/scale` nao responde | ESP32 fora da rede | Conferir Wi-Fi, IP e energia |
| Peso fica sempre zero | Balanca sem calibracao ou fator zero | Fazer tara e calibracao |
| Peso negativo | Tara feita com carga ou fios invertidos | Refazer tara e revisar ligacao |
| Peso oscila muito | Vibracao, montagem ruim ou 80 Hz | Usar 10 Hz e revisar mecanica |
| Calibracao falha | Peso conhecido invalido ou sem variacao bruta | Informar peso correto e verificar celula |
| Leitura nao volta para zero | Drift mecanico ou tara incorreta | Esvaziar plataforma e refazer tara |
| Precisao falha no app | Variacao maior que tolerancia | Aumentar tolerancia ou melhorar montagem |
| Funciona no curl mas nao no app | Endpoint salvo diferente | Conferir URL cadastrada no app |

## 14. Regras praticas para campo

Use estas regras para evitar erro na instalacao:

- Sempre fazer tara com a plataforma vazia.
- Sempre calibrar com peso conhecido real.
- Sempre usar `10 Hz` no inicio.
- Sempre testar peso zero depois de remover a carga.
- Sempre testar o peso conhecido pelo menos duas vezes.
- Sempre registrar qual peso foi usado na calibracao.
- Nunca deixar cabo tensionando a plataforma.
- Nunca apoiar a plataforma em estrutura lateral.
- Nunca calibrar durante vibracao.
- Nunca usar estimativa como peso conhecido.

## 15. Prompt pronto para replicar em outro sistema

Use o texto abaixo quando precisar pedir para implementar a balanca em outro sistema:

```text
Implemente uma integracao de balanca com ESP32 + HX711.

A balanca deve possuir configuracao com:
- ativar/desativar balanca;
- tipo de conexao Wi-Fi ou Bluetooth;
- nome/ID do dispositivo;
- endpoint/IP do ESP32;
- modo de uso: entrada de insumos, alimentacao por lote ou ambos;
- ultima leitura em kg;
- taxa de leitura em 10 Hz ou 80 Hz;
- tolerancia de precisao em kg.

No ESP32, exponha:
- GET /api/scale para retornar peso, valor bruto, offset, fator, taxa, ready e calibrated;
- POST /api/scale/tare para salvar o offset atual como zero;
- POST /api/scale/calibrate?knownWeightKg=VALOR para calibrar com peso conhecido;
- POST /api/scale/rate?rateHz=10 ou 80 para alterar a taxa.

A tara deve gravar o valor bruto atual como offset.
A calibracao deve calcular o fator usando:
fator = (leitura_bruta_com_peso - offset) / peso_conhecido_kg

A leitura final deve usar:
peso_kg = (leitura_bruta - offset) / fator

O app deve permitir:
- salvar configuracao;
- testar conexao;
- ler peso atual;
- executar tara;
- calibrar com peso conhecido;
- alternar taxa 10 Hz/80 Hz;
- testar estabilidade comparando menor e maior leitura contra uma tolerancia em kg.

Use 10 Hz como padrao para uso normal e 80 Hz apenas para leituras mais rapidas ou diagnostico.
```
