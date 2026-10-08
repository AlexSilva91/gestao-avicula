# GRANJA SELETO - automacoes atuais e proximos modulos

Atualizado em: 08/10/2026

## 1. Objetivo

Este documento registra o que o projeto GRANJA SELETO ja entrega hoje em automacao e quais automacoes uma granja pequena, media ou grande pode precisar no futuro.

Tambem inclui uma recomendacao de API de previsao do tempo/astronomia para calcular horas de luz com base no nascer e no por do sol.

## 2. Automacoes e integracoes que ja existem hoje

O projeto atual ja possui uma base importante de automacao com ESP32, HTTP local, MQTT remoto, sensores e telas dedicadas.

### Comunicacao ESP32

Ja existe:

- Comunicacao HTTP local.
- Comunicacao MQTT bidirecional.
- Configuracao de Wi-Fi do ESP32 pelo app.
- Configuracao de MQTT do ESP32 pelo app.
- Descoberta/validacao do ESP na rede local.
- Terminal visual para comandos e respostas.
- Scan de redes Wi-Fi captadas pelo ESP32.
- Publicacao de mensagens detalhadas do ESP para o app.

### Iluminacao

Ja existe:

- Controle de reles de iluminacao.
- Canais 1 a 4 reservados para iluminacao.
- Agenda por canal.
- Dois periodos diarios por agenda.
- Sincronizacao de agenda via HTTP local.
- Sincronizacao de agenda via MQTT remoto.
- Confirmacao do ESP por `schedule/ack`.
- Estado atual por `relay/state`.
- Estado de agenda por `schedule/state`.
- Operacao fora da rede local quando MQTT esta configurado.

### Ventilacao

Ja existe base preparada:

- Canais 5 a 12 reservados para ventilacao.
- Tela de ventilacao.
- Mapeamento visual dos canais.
- Estrutura para ligar/desligar ventiladores por rele.

Ainda falta evoluir para controle automatico por temperatura, umidade e estagios.

### Ambiente

Ja existe:

- Tela de ambiente.
- Leitura de temperatura.
- Leitura de umidade.
- Endpoint dedicado no ESP32.
- Registro historico em `sensor_readings`.
- Graficos na central de automacao.

### Agua

Ja existe:

- Tela de agua/reservatorio.
- Leitura de nivel.
- Leitura de temperatura da agua.
- Leitura de pH.
- Leitura de TDS.
- Estrutura para historico e graficos.

Ainda falta controle ativo de bomba, vazao e protecao contra falta de agua.

### Cameras

Ja existe:

- Modulo de cameras.
- Base para camera IP/ONVIF.
- Grade de visualizacao.
- Player de stream.
- Controle visual de cameras ativas/inativas.

Ainda falta evoluir para gravacao, eventos, deteccao e permissao por camera em nivel mais profundo.

### Central de automacao

Ja existe:

- Painel central de automacao.
- Indicador de ESP online/offline.
- Indicadores de temperatura, umidade, agua, pH/TDS.
- Estado dos reles.
- Alertas de automacao.
- Graficos de sensores.
- Configuracoes de ESP, Wi-Fi e MQTT.

## 3. O que uma granja pode precisar alem disso

### 3.1. Alimentacao automatica

Este e o proximo modulo mais importante.

Funcionalidades recomendadas:

- Programar tratos por horario.
- Programar quantidade por lote.
- Calcular quantidade por ave/dia.
- Usar curva de consumo por idade.
- Dividir o total diario em varios tratos.
- Controlar linhas ou zonas de alimentacao.
- Sensor de nivel baixo de racao.
- Sensor de motor travado.
- Sensor de corrente do motor.
- Confirmacao de que a racao caiu.
- Historico de trato.
- Modo manual.
- Modo automatico.
- Alerta se a alimentacao falhar.

Relacao com o app atual:

- O app ja tem modulo de racao/alimentacao.
- O app ja tem MQTT.
- O app ja tem historico de sensores/eventos.
- O app ja tem central de automacao.

Portanto, o alimentador automatico deve ser integrado ao modulo existente de racao e tambem aparecer na central de automacao.

### 3.2. Controle automatico de agua

Funcionalidades recomendadas:

- Acionamento automatico de bomba.
- Nivel minimo e maximo do reservatorio.
- Sensor de vazao.
- Alerta de falta de agua.
- Alerta de consumo anormal.
- Historico de consumo por dia.
- Estimativa de consumo por lote.
- Protecao contra bomba seca.
- Modo manual local.

Sensores e atuadores:

- Sensor de nivel.
- Sensor de vazao.
- Rele/contator da bomba.
- Sensor de corrente da bomba.
- Boia de seguranca mecanica.

### 3.3. Ventilacao automatica real

Funcionalidades recomendadas:

- Controle por temperatura.
- Controle por umidade.
- Controle por idade/fase do lote.
- Estagios de ventilacao.
- Modo emergencia por calor.
- Confirmacao de motor ligado.
- Alerta de ventilador travado.
- Historico de acionamento.

Exemplo de regra:

```text
Temperatura >= 29 C -> liga ventilacao estagio 1
Temperatura >= 32 C -> liga ventilacao estagio 2
Temperatura >= 35 C -> alerta critico
```

### 3.4. Cortinas e entrada de ar

Para granjas maiores ou galpoes semiabertos:

- Abrir/fechar cortina lateral.
- Controlar entrada de ar.
- Proteger contra chuva.
- Proteger contra vento forte.
- Integrar com temperatura e umidade.
- Modo manual local.
- Fim de curso de aberto/fechado.

Sensores recomendados:

- Sensor de chuva.
- Sensor de vento.
- Fim de curso.
- Temperatura/umidade interna.
- Temperatura externa.

### 3.5. Nebulizacao e resfriamento evaporativo

Funcionalidades recomendadas:

- Acionamento por temperatura.
- Bloqueio por umidade alta.
- Ciclos de nebulizacao.
- Controle de bomba/valvula.
- Historico de acionamento.
- Alerta de reservatorio vazio.

Regra exemplo:

```text
Temperatura alta + umidade baixa = nebuliza
Temperatura alta + umidade alta = prioriza ventilacao
```

### 3.6. Monitoramento de energia

Essencial para automacao de granja.

Funcionalidades recomendadas:

- Detectar falta de energia.
- Detectar queda de tensao.
- Monitorar consumo dos motores.
- Monitorar bateria/nobreak do controlador.
- Alertar falha eletrica.
- Historico de interrupcoes.

Itens recomendados:

- Sensor de tensao.
- Sensor de corrente.
- Nobreak ou bateria para o controlador.
- Contator/rele de protecao.
- Alerta via MQTT/app.

### 3.7. Silos e estoque fisico de racao

Funcionalidades recomendadas:

- Sensor de nivel no silo.
- Peso estimado no silo.
- Alerta de racao acabando.
- Previsao de dias restantes.
- Consumo real diario.
- Comparacao com consumo esperado.

Integracao ideal:

- Entradas do estoque do app.
- Consumo automatico do alimentador.
- Saldo fisico estimado.
- Divergencia entre saldo teorico e fisico.

### 3.8. Pesagem

Funcionalidades recomendadas:

- Balanca de racao.
- Balanca de ovos.
- Pesagem amostral de aves.
- Celula de carga no reservatorio.
- Historico de peso.
- Curva de desenvolvimento.

Beneficios:

- Medir consumo real.
- Detectar desperdicio.
- Melhorar conversao alimentar.
- Avaliar desempenho do lote.

### 3.9. Ambiencia avancada

Hoje ja ha temperatura e umidade. Pode evoluir para:

- Amônia.
- CO2.
- Luminosidade em lux.
- Pressao diferencial.
- Velocidade do ar.
- Poeira/particulados.

Prioridade pratica:

1. Lux.
2. Amonia.
3. CO2.
4. Pressao/fluxo de ar.

### 3.10. Iluminacao avancada

Hoje ja existe agenda e controle de relés.

Evolucoes recomendadas:

- Medicao real de lux.
- Dimerizacao.
- Transicao suave amanhecer/anoitecer.
- Programa por idade/fase.
- Alerta de lampada queimada.
- Relatorio de horas reais de luz.

Essa evolucao combina muito bem com uma API de nascer/por do sol.

### 3.11. Coleta de ovos / esteira

Para granjas maiores:

- Controle de esteira de ovos.
- Agendamento de coleta.
- Sensor de esteira travada.
- Contador de ciclos.
- Botao manual.
- Historico de coleta automatizada.
- Alerta de falha de esteira.

### 3.12. Seguranca do galpao

Funcionalidades recomendadas:

- Sensor de porta aberta.
- Sensor de presenca.
- Alarme por movimento fora do horario.
- Sirene/luz de alerta.
- Integracao com camera.
- Log de acessos.

### 3.13. Cameras com eventos

Evolucoes recomendadas:

- Camera offline.
- Gravacao por evento.
- Deteccao de movimento.
- Timelapse.
- Deteccao de aglomeracao.
- Alertas por imagem.
- Permissao por camera.
- Retencao de gravacoes por plano/propriedade.

### 3.14. Manutencao preventiva

Funcionalidades recomendadas:

- Horas de uso de motor.
- Ciclos de rele.
- Alertas de limpeza.
- Alertas de lubrificacao.
- Proxima manutencao.
- Historico de falhas por equipamento.

## 4. Prioridade recomendada

Ordem sugerida para evolucao do produto:

1. Alimentador automatico.
2. Agua automatica com bomba/vazao.
3. Ventilacao automatica por temperatura.
4. Monitoramento de energia/falha eletrica.
5. Silo/estoque fisico de racao.
6. Lux e iluminacao avancada.
7. Nebulizacao/resfriamento.
8. Cameras com eventos.
9. Manutencao preventiva.
10. Cortinas/entrada de ar.

## 5. API de previsao do tempo e horas de luz

### Recomendacao principal: Open-Meteo

Para o SELETO, a melhor opcao inicial e a Open-Meteo.

Motivos:

- Nao exige chave de API para uso basico.
- Retorna nascer do sol.
- Retorna por do sol.
- Retorna duracao de luz do dia em segundos.
- Permite definir latitude, longitude e timezone.
- Tambem entrega previsao do tempo, temperatura, chuva, vento e umidade.
- E simples de usar em app Flutter, servidor Python ou ESP/proxy.

Endpoint exemplo:

```text
https://api.open-meteo.com/v1/forecast?latitude=-7.115&longitude=-34.861&daily=sunrise,sunset,daylight_duration&timezone=America%2FRecife
```

Campos uteis:

```json
{
  "daily": {
    "sunrise": ["2026-10-08T05:03"],
    "sunset": ["2026-10-08T17:19"],
    "daylight_duration": [44160]
  }
}
```

Uso no SELETO:

- Calcular horas naturais de luz.
- Ajustar programa de iluminacao artificial.
- Estimar quanto tempo de luz complementar sera necessario.
- Criar agenda automatica baseada no nascer/por do sol.

Exemplo de regra:

```text
Meta de luz do lote: 16h/dia
Luz natural calculada: 12h16min
Complemento artificial necessario: 3h44min
```

Aplicacao pratica:

```text
Liga luz antes do nascer do sol: 04:30
Desliga apos nascer do sol: 06:00
Liga novamente antes do por do sol: 17:00
Desliga ao atingir meta diaria: 20:44
```

### Alternativa: WeatherAPI.com

Boa alternativa se o projeto precisar de um provedor com endpoint de astronomia direto.

Ele oferece:

- Nascer do sol.
- Por do sol.
- Nascer da lua.
- Fase da lua.
- Iluminacao lunar.
- Dados de clima.

Ponto de atencao:

- Exige chave de API.
- O plano gratuito/limites precisam ser conferidos antes de uso em producao.

### Alternativa: OpenWeather One Call

Tambem fornece nascer e por do sol.

Ponto de atencao:

- Exige chave de API.
- Pode exigir cadastro/plano especifico dependendo do uso.
- E mais indicado se o projeto ja estiver usando OpenWeather para clima.

## 6. Como implementar no SELETO

### Dados necessarios por propriedade

Adicionar configuracoes por tenant/propriedade:

```text
farm_latitude
farm_longitude
farm_timezone
weather_provider=open_meteo
lighting_target_hours_by_phase
```

### Fluxo sugerido

1. App pega latitude/longitude da propriedade.
2. App ou servidor consulta Open-Meteo diariamente.
3. Salva nascer do sol, por do sol e duracao do dia.
4. Calcula complemento de luz artificial.
5. Gera agenda de iluminacao.
6. Envia agenda para ESP32 via MQTT/HTTP.
7. ESP confirma por `schedule/ack`.
8. App valida por `schedule/state`.

### Cache recomendado

Salvar localmente:

```text
date
latitude
longitude
sunrise
sunset
daylight_duration_seconds
provider
fetched_at
```

Evitar chamar API toda hora. Uma chamada diaria por propriedade e suficiente para o calculo de luz.

## 7. Conclusao

O GRANJA SELETO ja tem a base tecnica para crescer em automacao: ESP32, MQTT, sensores, relés, historico, alertas, sincronizacao e telas.

O maior salto de valor agora esta em transformar os sensores e relés em rotinas produtivas automatizadas:

- alimentar,
- fornecer agua,
- ventilar,
- resfriar,
- controlar luz por fase,
- monitorar energia,
- detectar falhas,
- registrar historico e alertar o usuario.

Para horas de luz baseadas no nascer do sol, a recomendacao principal e usar Open-Meteo com `sunrise`, `sunset` e `daylight_duration`.
