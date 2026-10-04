# GRANJA SELETO - capacidades atuais da aplicacao

Atualizado em: 04/10/2026

Este documento descreve o que a aplicacao e capaz de fazer hoje, com base no
codigo atual do projeto. Ele nao descreve promessas futuras. Quando uma funcao
depende de hardware, permissao do Android, servidor ou configuracao externa, isso
esta indicado explicitamente.

## Visao geral

O GRANJA SELETO e um app Flutter para operacao de granja, controle financeiro,
comercial, alertas, relatorios, sincronizacao remota e integracoes com ESP32,
sensores, reles, MQTT e cameras ONVIF.

O app trabalha com banco local SQLite via Drift. A sincronizacao remota, quando
configurada, envia e recebe os dados do servidor SELETO Sync, mas o app continua
funcionando localmente.

## Modulos disponiveis no menu

As telas existentes hoje sao:

- Inicio
  - Visao geral
- Plantel e ovos
  - Lotes
  - Movimentacoes
  - Coleta
  - Simulacao
  - Estoque de ovos
- Manejo
  - Racao e alimentacao
  - Calendario e luz
  - Vacinacao
- Sensores
  - Central da automacao
  - Iluminacao
  - Ambiente
  - Ventilacao
  - Agua
  - Cameras
- Comercial
  - Comercial
- Financeiro
  - Granja
  - Pessoal
- Gestao
  - Relatorios
- Sistema
  - Alertas
  - Usuarios
  - Configuracoes
  - Auditoria

O menu e filtrado por permissoes. Se o usuario nao tiver permissao para uma tela,
ela nao aparece no menu. Se tentar abrir uma rota sem permissao, o app redireciona
para a primeira tela liberada ou para uma tela de "Sem acesso".

## Fluxo de autenticacao e usuarios

### Primeiro acesso

1. Se nao existe usuario no banco local, a tela de login permite criar a primeira
   conta.
2. Essa primeira conta vira administradora.
3. A primeira conta recebe permissao global de Super Admin.

### Criacao de conta pelo proprio usuario

1. Se ja existe usuario no sistema, uma nova conta criada pela tela de login fica
   inativa.
2. O usuario nao entra automaticamente.
3. Um administrador precisa ativar a conta e liberar as permissoes.

### Login

1. O app procura o usuario no banco local.
2. Se o usuario nao existir localmente e a sincronizacao estiver configurada, o
   app tenta consultar o servidor remoto pelo nome de usuario.
3. Se encontrar dados remotos, baixa o escopo do usuario e tenta autenticar
   localmente.
4. A senha e validada contra hash local.
5. Usuario inativo nao entra.
6. Existe opcao de lembrar login.

### Presenca online

Enquanto o usuario esta logado, o app atualiza `lastSeenAt` no banco local e
tambem envia presenca ao servidor de sincronizacao quando configurado. O intervalo
local e remoto usado no codigo e de 8 segundos.

## Permissionamento atual

O app usa permissoes por chave. Super Admin pode gerenciar permissoes globais.
Administrador de granja com wildcard `*` nao recebe automaticamente permissoes
globais como `tenant.view_all` e `tenants.create`.

Principais grupos de permissoes:

- Inicio
  - Ver painel
  - Ver producao, financeiro, comercial, automacao, sensores, graficos e atalhos
    na home
- Producao
  - Visualizar, criar e alterar lotes
  - Comprar, vender, transferir, ajustar aves e registrar mortalidade
- Racao
  - Visualizar e registrar alimentacao
  - Visualizar/fabricar racao
  - Gerenciar formulacoes
  - Visualizar/ajustar estoque de racao
  - Gerenciar insumos e precos
- Ovos
  - Visualizar e registrar coletas
  - Visualizar/ajustar estoque de ovos
- Comercial
  - Clientes
  - Pedidos
  - Vendas
- Financeiro
  - Financeiro geral
  - Financeiro da granja
  - Financeiro pessoal
  - Criar e alterar lancamentos
- Calendario
  - Visualizar e criar eventos
  - Visualizar e gerenciar iluminacao
- Sensores
  - Central da automacao
  - Iluminacao fisica
  - Ambiente
  - Ventilacao
  - Agua
  - Cameras
- Sistema
  - Relatorios
  - Alertas
  - Configuracoes
  - Auditoria
  - Usuarios e permissoes

Ha compatibilidade com permissoes antigas: por exemplo, `finance.view` ainda pode
liberar financeiro da granja e pessoal, e `settings.view` ainda pode liberar
sensores, para usuarios ja existentes nao perderem acesso de uma vez.

## Home / Visao geral

A Home mostra blocos conforme permissao:

- Painel operacional da granja
  - Aves ativas
  - Ovos hoje
  - Estoque de ovos
  - Racao
  - Resultado do mes
  - Pedidos pendentes
- Status da automacao
  - ESP32 online/offline
  - Nivel de agua
  - Alertas criticos
  - Agenda de luz
- Sensores e automacoes
  - Iluminacao
  - Ambiente
  - Ventilacao
  - Agua
- Graficos
  - Desempenho por lote
  - Alimentacao diaria
  - Desempenho de vendas
  - Taxa de postura diaria
  - Fase e idade dos lotes
  - Mortalidade por lote
- Atalhos
  - Novo lote
  - Registrar coleta
  - Alimentacao
  - Nova venda

Se o usuario tem acesso a Home, mas nenhum bloco foi liberado, a tela exibe uma
mensagem informando que nao ha bloco liberado.

## Fluxo operacional da granja

### 1. Cadastro e controle de lotes

Na tela de lotes, o app controla o plantel por lote. Um lote registra:

- Nome
- Linhagem
- Quantidade inicial
- Data de recebimento
- Idade de chegada em dias
- Valor unitario opcional
- Fornecedor
- Observacoes
- Status

O saldo atual de aves nao e um campo manual. Ele e derivado dos movimentos de
aves. Isso preserva historico.

Movimentos de aves existentes:

- Compra de aves
- Venda de aves
- Mortalidade
- Ajuste de entrada
- Ajuste de saida
- Transferencia entre lotes
- Desfazer transferencia

Quando uma compra de lote e registrada, o sistema pode agendar alertas de mudanca
de fase se a configuracao `PHASE_CHANGE` estiver ativa.

Marcos de fase usados pelo app:

- 49 dias: RECRIA
- 112 dias: PRE-POSTURA
- 154 dias: PRODUCAO I
- 266 dias: PRODUCAO II
- 462 dias: PRODUCAO III

### 2. Coleta e estoque de ovos

Na tela de coleta, o usuario registra coleta por lote e data. O registro aceita:

- Total coletado
- Ovos limpos
- Ovos sujos
- Ovos trincados
- Ovos quebrados
- Ovos descartados
- Observacoes

O sistema calcula metricas como:

- Ovos hoje
- Ovos no mes
- Estoque atual
- Taxa de postura diaria
- Taxa de postura mensal
- Comparativo mensal

O estoque de ovos e movimentado automaticamente por coletas e vendas. A tela de
estoque tambem permite ajuste manual de estoque, respeitando permissao.

### 3. Simulacao de postura

A tela de simulacao usa os dados de lotes, coletas e taxas historicas para exibir
comparativos de postura. Ela tambem mostra diferencas entre periodos quando ha
historico suficiente.

### 4. Racao, insumos e alimentacao

O modulo de racao cobre:

- Cadastro de insumos
- Edicao e inativacao de insumos
- Exclusao permanente de insumo quando nao ha uso impeditivo
- Historico de preco de insumo
- Entrada de lote de insumo
- Ajuste de estoque de lote de insumo
- Transferencia de estoque entre insumos
- Cadastro e versionamento de formulas
- Edicao de formulas
- Importacao de formulas
- Fabricacao de racao
- Compra de racao pronta
- Estoque de racao por lote/fabricacao
- Registro de alimentacao diaria por lote
- Edicao de alimentacao
- Ajuste manual de estoque de racao
- Recomendacoes de consumo por ave
- Importacao de recomendacoes de consumo

Na fabricacao de racao, o sistema usa os insumos e precos salvos para calcular
custo do lote fabricado. O estoque de insumos e consumido conforme planejamento
interno. A alimentacao registrada baixa estoque do lote de racao.

### 5. Comercial

O modulo comercial cobre:

- Cadastro de clientes
- Pedidos
- Historico de status de pedidos
- Venda de ovos soltos/duzias
- Cadastro de itens de embalagem
- Entrada de lotes de embalagem
- Estoque de embalagem
- Montagem de bandejas/cartelas de ovos
- Reversao de montagem de bandejas
- Venda de bandejas/cartelas
- Cancelamento de vendas
- Calculo de custo estimado do ovo para uso na montagem

Pedidos possuem status e podem gerar venda quando entregues, conforme fluxo
implementado no repositorio operacional. Vendas confirmadas movimentam estoque e
entram nos relatorios/metricas financeiras.

### 6. Financeiro da granja

A tela "Financeiro da Granja" possui abas:

- Resumo
- Lancamentos
- Contas
- Investimentos
- Simulador

O financeiro da granja registra:

- Entradas
- Saidas
- Lancamentos confirmados
- Contas a pagar pendentes
- Pagamento de contas a pagar
- Edicao de lancamentos
- Cancelamento de lancamentos
- Investimentos
- Pro-labore
- Importacao de contas a pagar por CSV, XML, XLSX, XLS e XLSL

Categorias de entrada da granja existentes na UI:

- Venda de ovos
- Venda de aves
- Servicos
- Rendimentos
- Reembolso
- Bonificacao
- Outras receitas

Categorias de saida da granja existentes na UI:

- Fatura de cartao
- Boleto
- Compra parcelada
- Mensalidade de servico
- Racao
- Insumos
- Aves
- Embalagem
- Energia
- Agua
- Medicamentos
- Vacinas
- Estrutura
- Equipamentos
- Manutencao
- Impostos e taxas
- Folha/pro-labore
- Frete
- Outras despesas

Resumo financeiro da granja mostra:

- Resultado geral
- Resultado do mes atual
- Resultado do proximo mes
- Contas abertas total
- Contas abertas do mes atual
- Contas abertas do proximo mes
- Previsao de quitacao

A previsao de quitacao usa:

- O ultimo vencimento aberto das contas cadastradas
- A sobra mensal quando ha saldo positivo no mes atual ou no proximo mes

Se nao houver saldo mensal positivo, o app informa que nao ha previsao confiavel
pela sobra mensal.

### 7. Financeiro pessoal

A tela "Financas Pessoais" possui abas:

- Resumo
- Lancamentos
- Contas
- Patrimonio
- Cadastros

O financeiro pessoal registra:

- Entradas pessoais
- Saidas pessoais
- Lancamentos confirmados
- Contas a pagar pendentes
- Pagamento de contas a pagar
- Edicao de lancamentos
- Reservas financeiras
- Investimentos pessoais
- Dividas pessoais
- Estabelecimentos financeiros
- Pro-labore vindo da granja
- Importacao de contas a pagar por CSV, XML, XLSX, XLS e XLSL

Categorias de entrada pessoal existentes na UI:

- Salario
- Pro-labore
- Rendimentos
- Renda extra
- Aluguel recebido
- Reembolso
- Presente/doacao
- Outras entradas

Categorias de saida pessoal existentes na UI:

- Fatura de cartao
- Boleto
- Compra parcelada
- Mensalidade de servico
- Faculdade/curso
- Moradia
- Mercado
- Transporte
- Saude
- Lazer
- Educacao
- Impostos e taxas
- Emprestimos
- Outras saidas

Resumo pessoal mostra:

- Entradas pessoais
- Saidas pessoais
- Saldo pessoal
- Reserva
- Investimentos
- Dividas abertas total
- Dividas do mes atual
- Dividas do proximo mes
- Saldo do mes atual
- Saldo do proximo mes
- Previsao de quitacao
- Aviso de vencimentos proximos

Toda conta pessoal pendente tambem entra como divida aberta no resumo.

### 8. Importacao de contas a pagar

As telas de contas a pagar da granja e pessoal aceitam arquivos:

- CSV
- XML
- XLSX
- XLS
- XLSL

Campos aceitos pelo importador:

- Descricao: `descricao`, `descrição`, `description`, `historico`, `nome`,
  `titulo`
- Categoria: `categoria`, `category`, `tipo`
- Vencimento: `vencimento`, `datavencimento`, `data_de_vencimento`, `due`,
  `duedate`, `due_date`
- Parcelas: `parcelas`, `qtdparcelas`, `installments`
- Valor total: `valortotal`, `valor_total`, `total`, `totalcents`
- Valor: `valor`, `amount`, `amountcents`
- Observacao: `observacao`, `observação`, `obs`, `notes`, `nota`
- Forma de pagamento: `forma`, `formapagamento`, `forma_pagamento`, `payment`,
  `paymentmethod`

Se `valor_total` for informado com `parcelas`, o app divide o total pelas
parcelas. Se houver mais de uma parcela, o app cria uma conta por mes, adicionando
o numero da parcela na descricao.

Datas aceitas incluem ISO e formato brasileiro `dd/mm/aaaa`.

### 9. Calendario, alertas e vacinacao

O calendario permite criar eventos operacionais com:

- Titulo
- Tipo
- Data
- Lote opcional
- Observacoes
- Alerta ligado/desligado
- Mensagem de alerta
- Horario do alerta
- Recorrencia
- Data limite de repeticao
- Dias da semana para recorrencia semanal

Recorrencias implementadas:

- Uma vez
- Diaria
- Semanal
- Mensal

Limites internos de ocorrencias:

- Diaria: ate 90 dias, no maximo 64 ocorrencias
- Semanal: ate 180 dias, no maximo 64 ocorrencias
- Mensal: ate 1 ano, no maximo 24 ocorrencias

A tela de alertas permite visualizar eventos com alerta, editar alerta, ativar ou
desativar e cancelar conforme regras da tela.

Vacinacao registra:

- Nome da vacina
- Doenca
- Data prevista
- Data aplicada
- Lote
- Dose
- Via
- Lote da vacina
- Fabricante
- Responsavel
- Status
- Observacoes

Tambem existe relatorio de vacinacao e configuracao de logo para esse relatorio.

### 10. Notificacoes no device

O app agenda notificacoes locais quando a plataforma suporta. Ha dois grupos
principais:

- Eventos de calendario
- Contas a pagar

Contas a pagar pendentes com vencimento geram dois alertas:

- Um dia antes do vencimento, as 08:00
- No dia do vencimento, as 08:00

Se a conta vence no dia atual e o horario das 08:00 ja passou, o alerta do dia e
agendado para aproximadamente um minuto depois.

Quando uma conta e paga, editada ou cancelada, os alertas antigos sao cancelados
e a agenda persistida e recalculada.

Tambem existem alertas de mudanca de fase de lote quando a configuracao de
notificacao de fase esta ativa.

### 11. Relatorios

A tela de relatorios usa dados operacionais para apresentar:

- Indicadores do painel
- Indicadores de ovos
- Series de producao de ovos
- Series financeiras
- Taxas de postura mensais
- Periodos selecionaveis
- Exportacao de PDF pela tela de relatorios

O conteudo exato dos graficos depende dos registros existentes no banco local ou
sincronizados.

### 12. Auditoria

O app grava eventos de auditoria para acoes operacionais relevantes, como:

- Criacao/alteracao de usuarios
- Permissoes
- Compra/movimentacao de aves
- Coleta de ovos
- Estoque
- Insumos
- Formula
- Fabricacao de racao
- Alimentacao
- Clientes
- Pedidos
- Vendas
- Financeiro
- Calendario
- Configuracoes

A tela de auditoria exibe logs paginados e permite consultar detalhes do evento.

## Fluxo de funcionamento das automacoes

### Visao geral da arquitetura

A automacao atual e hibrida:

- HTTP local para configuracao, leitura, comandos diretos e recuperacao.
- MQTT opcional para comunicacao remota/tempo real com o ESP32.
- Banco local para historico de leituras, eventos e configuracoes.
- Alertas operacionais gerados pelo app a partir de leituras e metricas.

O app nao "adivinha" sensores. Ele depende de o ESP32 responder aos endpoints e
campos esperados.

### Descoberta e conexao com ESP32

O app tenta encontrar o ESP32 assim:

1. Testa o endpoint padrao `http://192.168.4.1/api/status`.
2. Se nao encontrar, identifica a sub-rede Wi-Fi atual.
3. Varre IPs de `.1` a `.254` nessa sub-rede.
4. Para cada IP, testa `/api/status`.
5. Aceita o dispositivo quando a resposta identifica o ESP32 do projeto.

O endpoint salvo e usado nas telas de iluminacao, ambiente, agua e ventilacao.

### Endpoints HTTP usados pelo app

O client HTTP atual usa:

- `GET /api/status`
  - Handshake, status geral, IP, identificacao do dispositivo e estado basico.
- `GET /api/environment`
  - Leitura de temperatura e umidade do ambiente.
- `GET /api/water`
  - Leitura de nivel do reservatorio, temperatura da agua, pH, TDS e ORP/cloro
    quando existir.
- `GET /api/sensors`
  - Leitura generica de sensores.
- `GET /api/remote`
  - Consulta configuracao de sincronizacao remota no ESP.
- `POST /api/remote`
  - Configura sync remoto no ESP.
- `POST /api/mqtt`
  - Configura MQTT no ESP.
- `POST /api/wifi`
  - Envia SSID e senha para conectar o ESP ao Wi-Fi.
- `POST /api/wifi/disconnect`
  - Desconecta Wi-Fi e opcionalmente limpa credenciais.
- `POST /api/relay`
  - Liga, desliga ou pulsa canal de rele.
- `POST /api/time`
  - Sincroniza horario do ESP com o horario do app.
- `POST /api/channel_schedule`
  - Envia agenda de um canal.
- `POST /api/group_schedule`
  - Envia agenda para grupo de canais.

### Provisionamento de Wi-Fi do ESP

Fluxo real pelo app:

1. Usuario abre a tela de iluminacao/integracoes.
2. App tenta descobrir o ESP.
3. Se o ESP estiver em modo AP, o endpoint padrao e `http://192.168.4.1`.
4. Usuario informa rede Wi-Fi e senha.
5. App envia `POST /api/wifi`.
6. Se a resposta confirma IP local, o app salva o endpoint local.
7. O app pode testar o endpoint salvo depois.
8. Tambem ha acao para desconectar Wi-Fi do ESP e limpar credenciais.

No codigo, o AP de configuracao esperado pelo client e `192.168.4.1`. A
documentacao de hardware do projeto cita SSID/senha de setup, mas a conexao em
si depende do usuario conectar o celular ao AP correto.

### Controle de reles

O app controla canais de rele para iluminacao e ventilacao.

Comando HTTP:

- Canal: numero inteiro.
- Estado: `on`, `off` ou `pulse`.
- Endpoint: `POST /api/relay`.

Comando MQTT:

- Topico: `<baseTopic>/<deviceId>/relay/command`
- Payload JSON:
  - `channel`
  - `state`
  - `source: app`
  - `ts`

Quando MQTT esta configurado e conectado, o app tenta usar MQTT para comando de
rele. Quando MQTT nao esta pronto ou falha, o fluxo de integracao usa HTTP como
caminho de controle direto.

### MQTT em tempo real

Configuracao MQTT no app:

- Ativado/desativado
- Broker
- Porta
- Topico base
- Device ID
- Usuario
- Senha

Se a porta for `8883`, o client MQTT usa TLS.

Topicos assinados no runtime:

- `<baseTopic>/<deviceId>/status`
- `<baseTopic>/<deviceId>/sensors`
- `<baseTopic>/<deviceId>/relay/state`

Topicos publicados:

- `<baseTopic>/<deviceId>/ping`
- `<baseTopic>/<deviceId>/relay/command`

O app registra payloads recebidos de sensores e estados de rele quando o fluxo da
tela faz esse processamento.

### Iluminacao

A tela de iluminacao/integracoes permite:

- Informar endpoint/IP local do ESP.
- Descobrir/testar conexao.
- Configurar GPIO padrao.
- Configurar canais de iluminacao.
- Nomear canais.
- Definir GPIO por canal.
- Ativar/desativar canais.
- Ligar/desligar/testar canais.
- Enviar pulso para canal.
- Sincronizar horario do ESP.
- Configurar agenda por canal.
- Aplicar agenda geral para grupo de canais.
- Sincronizar agenda com o ESP.
- Configurar MQTT no ESP.
- Testar MQTT.
- Iniciar runtime MQTT.
- Configurar Wi-Fi do ESP.

A agenda enviada ao ESP inclui:

- Canal ou lista de canais.
- Ativado/desativado.
- Janela da manha ligada/desligada.
- Hora de ligar pela manha.
- Hora de desligar pela manha.
- Janela da tarde/noite ligada/desligada.
- Hora de ligar pela tarde/noite.
- Hora de desligar pela tarde/noite.
- Mascara de dias da semana.

### Ambiente

A tela Ambiente permite:

- Configurar endpoint/IP do ESP32.
- Ler sensores de ambiente.
- Testar conexao.
- Salvar endpoint.
- Visualizar temperatura e umidade.
- Visualizar zonas/pontos quando o payload do ESP retorna lista de zonas.
- Registrar historico de leitura em `sensor_readings`.

Metricas registradas incluem temperatura do ar e umidade do ar. Quando ha zonas,
as leituras podem ser registradas com identificacao de zona.

### Agua

A tela Agua permite:

- Configurar endpoint/IP do ESP32.
- Ler dados do reservatorio.
- Testar conexao.
- Salvar endpoint.
- Visualizar nivel percentual.
- Visualizar temperatura da agua.
- Visualizar pH.
- Visualizar TDS em ppm.
- Visualizar ORP/cloro quando o ESP retorna esse campo.
- Registrar historico de leitura em `sensor_readings`.

### Qualidade da agua

Existe rota para qualidade da agua apontando para pagina de reservatorio no
router atual, e tambem existe classe de pagina `WaterQualitySensorPage` no codigo.
No estado atual do roteamento, `/hardware-water-quality` abre
`WaterReservoirSensorPage`.

### Ventilacao

A tela Ventilacao permite:

- Configurar endpoint/IP do ESP32.
- Ler status/sensores.
- Configurar canais de ventiladores/exaustores.
- Nomear canal.
- Definir GPIO.
- Ativar/desativar canal.
- Ligar/desligar/testar canal.
- Usar controle de rele por HTTP.
- Salvar configuracoes em `app_settings`.

O visual da tela exibe uma instrumentacao de ventiladores e fluxo de ar, mas o
controle real depende de o ESP responder aos comandos de rele.

### Central da automacao

A Central da automacao consolida:

- Estado online/offline do ESP.
- IP do ESP.
- Ultima sincronizacao/leitura.
- Temperatura.
- Umidade.
- Nivel de agua.
- pH.
- TDS.
- Alertas abertos.
- Estados dos reles.
- Status de agenda sincronizada.
- Grafico de series de sensores.
- Painel de eventos/alertas de automacao abertos.

Esses dados vem de `app_settings`, `sensor_readings` e `automation_events`.

### Eventos e alertas de automacao

O app grava eventos de automacao em `automation_events`. Eventos possuem:

- Severidade
- Tipo
- Titulo
- Mensagem
- Origem
- Status
- Data de ocorrencia
- Data de resolucao
- Payload JSON

O repositorio avalia alertas operacionais a partir de leituras e metricas. Pelo
codigo atual, sao avaliados cenarios como:

- ESP offline
- Nivel de agua baixo
- pH fora de faixa operacional
- Temperatura alta
- Falta de coleta de ovos no dia

Eventos abertos aparecem na Central da automacao.

### Cameras

O app permite cadastrar cameras ONVIF nas configuracoes e visualiza-las na tela
Cameras.

Cadastro de camera:

- Nome
- IP/host
- Usuario
- Senha
- Porta RTSP opcional
- URL de snapshot opcional
- Canal ativo/inativo

Funcionamento:

1. Se uma URL de snapshot manual estiver configurada, ela e usada diretamente.
2. Se nao houver URL manual, o app tenta ONVIF:
   - `GetCapabilities`
   - `GetProfiles`
   - `GetSnapshotUri`
3. Se a camera tiver usuario, o app envia autenticacao basica para imagem e usa
   WS-Security nas chamadas SOAP ONVIF.
4. O app tambem monta URL RTSP com credenciais mascaradas para exibicao/copia.

A tela de cameras possui grade com selecao de layout, tiles de camera e acoes de
abrir/parar stream conforme implementacao da UI.

## Configuracoes do sistema

A tela Configuracoes cobre:

- Parametros de producao
  - Consumo na producao
  - Taxa de postura projetada
- Aviso de atualizacao de app
  - Codigo/nome de versao remota
  - Mensagem
  - URL
- Cameras ONVIF
- Backup e restauracao
- Importacao de dados iniciais
- Servidor SELETO Sync
- Configuracoes de notificacoes

### Backup

O app exporta dados em formato JSON interno `SELETO_BACKUP_V1`. A restauracao
usa esse conteudo para repor dados operacionais. Usuarios, permissoes e auditoria
sao tratados com regras especificas no importador/restaurador.

### Importacao operacional

A importacao operacional aceita:

- JSON
- CSV
- XML
- XLSX
- XLSL

Ela converte para o formato interno do app. Para detalhes de campos e aliases,
ver `docs/importacao/formatos_importacao.md`.

### Sincronizacao remota

O app possui cliente SELETO Sync com:

- URL configuravel
- Token configuravel
- Teste de saude do servidor
- Teste de configuracao
- Sincronizacao manual
- Sincronizacao no login
- Sincronizacao ao restaurar sessao lembrada
- Sincronizacao ao voltar do app
- Sincronizacao periodica em tempo real
- Presenca online

Intervalos do codigo:

- Intervalo minimo entre syncs nao forcados: 15 segundos
- Sync periodico em tempo real: 20 segundos
- Heartbeat de presenca: 8 segundos

Endpoints usados pelo servidor:

- `GET /health`
- `POST /sync/v1/status`
- `POST /sync/v1/sync`
- `POST /sync/v1/login`
- `POST /sync/v1/presence`

O token e enviado por `Authorization: Bearer <token>`.

Tabelas/colecoes sincronizadas pelo app incluem:

- tenants
- users
- userPermissions
- auditLogs
- lots
- birdMovements
- eggCollections
- eggStockMovements
- ingredients
- prices
- ingredientLots
- ingredientStockMovements
- formulas
- formulaItems
- feedBatches
- feedBatchItems
- feedStock
- feedings
- feedRecommendations
- customers
- orders
- orderItems
- orderStatusHistory
- packagingItems
- packagingLots
- packagingStockMovements
- eggTrayBatches
- eggTrayStockMovements
- sales
- finance
- investments
- financialEstablishments
- personalFinance
- financialReserves
- personalInvestments
- personalDebts
- lightingPrograms
- lightingSteps
- lotLighting
- calendarEvents
- vaccinationRecords
- notificationSettings
- appSettings

## Dados locais principais

O banco local contem tabelas para:

- Parcerias/tenants
- Usuarios
- Permissoes
- Auditoria
- Lotes
- Movimentos de aves
- Coletas de ovos
- Movimentos de estoque de ovos
- Insumos
- Precos de insumos
- Lotes de insumos
- Movimentos de estoque de insumos
- Formulas de racao
- Itens de formula
- Lotes de racao
- Itens de lote de racao
- Movimentos de estoque de racao
- Alimentacoes diarias
- Recomendacoes de consumo
- Clientes
- Pedidos
- Itens de pedido
- Historico de status de pedido
- Itens de embalagem
- Lotes de embalagem
- Movimentos de embalagem
- Lotes de bandejas/cartelas
- Movimentos de estoque de bandejas
- Vendas
- Financeiro da granja
- Investimentos da granja
- Estabelecimentos financeiros
- Financeiro pessoal
- Reservas pessoais
- Investimentos pessoais
- Dividas pessoais
- Programas de luz
- Etapas de programas de luz
- Programa de luz por lote
- Eventos de calendario
- Configuracoes de notificacao
- Configuracoes do app
- Leituras de sensores
- Eventos de automacao
- Registros de vacinacao

Todas essas tabelas possuem controle de atualizacao (`updated_at`) no estado
atual do banco.

## Limites conhecidos e dependencias reais

- Automacao depende de ESP32/firmware responder aos endpoints esperados.
- MQTT depende de broker configurado e acessivel.
- Comandos remotos por MQTT dependem do ESP estar inscrito nos topicos
  esperados.
- Alertas locais dependem de permissoes do Android para notificacoes.
- Alertas criticos/sonoros dependem da preparacao de permissao implementada no
  servico nativo.
- Cameras ONVIF dependem de a camera aceitar ONVIF, SOAP e credenciais.
- Stream/captura de camera depende de URL/codec/rede suportados pelo dispositivo.
- Sincronizacao remota depende de token, URL, rede e servidor SELETO Sync ativo.
- O app preserva operacao local mesmo sem sync, mas outro aparelho nao recebera
  dados enquanto a sincronizacao nao ocorrer.
- O modulo de qualidade da agua tem classe propria no codigo, mas a rota atual
  registrada aponta para a pagina de reservatorio de agua.

## Arquivos de codigo usados como base

- `lib/core/widgets/app_shell.dart`
- `lib/core/routing/app_router.dart`
- `lib/core/constants/permissions.dart`
- `lib/features/auth/application/auth_controller.dart`
- `lib/features/auth/data/repositories/local_auth_repository.dart`
- `lib/features/lots/application/lots_controller.dart`
- `lib/features/egg_collection/application/egg_collection_controller.dart`
- `lib/features/operations/application/operations_controller.dart`
- `lib/core/database/app_database.dart`
- `lib/core/database/operations_tables.dart`
- `lib/core/database/operations_repository.dart`
- `lib/core/platform/alert_scheduler.dart`
- `lib/core/platform/notification_service.dart`
- `lib/features/operations/application/hardware_esp_client_io.dart`
- `lib/features/operations/application/hardware_mqtt_client_io.dart`
- `lib/features/operations/application/camera_monitoring.dart`
- `lib/features/operations/presentation/pages/*`
- `lib/core/sync/seleto_sync_service.dart`
