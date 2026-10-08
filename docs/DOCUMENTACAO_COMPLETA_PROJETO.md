# GRANJA SELETO - documentacao completa do projeto

Atualizado em: 08/10/2026

## 1. Visao geral

O GRANJA SELETO e um aplicativo Flutter para gestao operacional, produtiva, financeira e de automacao de uma granja. O app foi desenhado para trabalhar primeiro com banco local, operar mesmo sem internet, controlar dados por propriedade e integrar equipamentos ESP32 por rede local e por MQTT remoto.

Hoje o projeto entrega:

- App Flutter Android com navegacao protegida por login e permissao.
- Banco local SQLite com Drift, migracoes e dados persistentes no device.
- Isolamento multi-tenant por propriedade.
- Perfis de usuario com permissao por tela/recurso.
- Sincronizacao remota com fila local, historico e assinatura HMAC.
- Servidor de sincronizacao em Python com PostgreSQL remoto como espelho do banco local.
- Deploy de servidor de sync e MQTT para `131.221.236.34`.
- Broker MQTT Mosquitto com ACL para os topicos do SELETO.
- Integracao ESP32 por HTTP local e MQTT remoto.
- Controle de iluminacao com estado real, agenda diaria e resposta do ESP.
- Scan de redes Wi-Fi captadas pelo ESP32, inclusive via MQTT.
- Monitoramento de sensores, automacao, ventilacao, agua e cameras.
- Modulos produtivos, comerciais, financeiros, relatorios, alertas e auditoria.

## 2. Arquitetura atual

### App Flutter

O app fica em `lib/` e usa Flutter com Riverpod, GoRouter, Drift, SQLite, HTTP, MQTT, MediaKit e componentes proprios de UI.

Responsabilidades principais:

- Renderizar a interface do operador.
- Persistir tudo no banco local.
- Aplicar permissoes, tenant atual e regras de visibilidade.
- Enfileirar alteracoes para sincronizacao.
- Comunicar com ESP32 via HTTP local quando possivel.
- Comunicar com MQTT remoto para comandos fora da rede local.
- Exibir historico, terminal de comandos e respostas dos dispositivos.

### Banco local

O banco local e SQLite + Drift. A conexao fica em `lib/core/database/`, e o schema atual esta na versao `22`.

O banco local e a fonte de trabalho do app. A instalacao do APK deve ser feita com:

```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

Esse fluxo atualiza o app sem desinstalar, sem limpar dados e sem trocar o caminho do banco local. Nao usar `adb uninstall`, `pm clear` ou remocao manual de dados quando a intencao for preservar o banco.

### Servidor de sincronizacao

O servidor de sincronizacao esta em `scripts/seleto_sync_server.py`.

Ele entrega endpoints:

- `POST /sync/v1/health`
- `POST /sync/v1/status`
- `POST /sync/v1/pull`
- `POST /sync/v1/push`
- `POST /sync/v1/sync`
- `POST /sync/v1/login`
- `POST /sync/v1/presence`

O servidor usa PostgreSQL remoto como espelho do banco local. Ele nao substitui a operacao local do app: a funcao principal e receber, devolver e guardar snapshots/eventos por escopo de sincronizacao.

### MQTT

O MQTT roda no Mosquitto e e usado para:

- Estado online do ESP32.
- Estado real dos reles.
- Agenda salva no ESP32.
- Comandos de rele.
- Sincronizacao remota da agenda.
- Scan de Wi-Fi captado pelo ESP32.
- Respostas e mensagens do ESP para aparecerem no app.

Configuracao atual esperada:

- Host: `131.221.236.34`
- Porta: `1883`
- Base topic: `seleto/esp32`
- Usuario: `seleto`
- Device ID padrao do ESP: `SELETO-RELE-01`

### ESP32

O firmware atual fica em:

`docs/hardware/firmware/esp32-granja-seleto/granja_seleto_wifi_bluetooth.ino`

Ele entrega:

- AP local de recuperacao `SELETO-SETUP`.
- HTTP local para status, reles, agenda, Wi-Fi, MQTT e sensores.
- MQTT para status, sensores, comandos, agenda e scan de redes.
- Persistencia de Wi-Fi, MQTT e agenda na flash via Preferences.
- Buffer MQTT aumentado para `8192` bytes.

## 3. Tecnologias principais

- Flutter.
- Dart.
- Riverpod.
- GoRouter.
- Drift.
- SQLite.
- HTTP.
- MQTT.
- Mosquitto.
- Python para servidor de sync.
- PostgreSQL no servidor remoto.
- systemd para servico remoto.
- ESP32 Arduino Core.
- PubSubClient no ESP32.
- MediaKit para camera/stream.

## 4. Modulos e telas entregues

### Inicio

Rota: `/dashboard`

Entrega:

- Visao geral da granja.
- Indicadores de producao.
- Painel de automacao.
- Cards de sensores.
- Preview de iluminacao, ambiente, agua e ventilacao.
- Graficos de desempenho, racao, vendas, postura, fases e mortalidade.
- Atalhos rapidos.

### Lotes

Rota: `/lots`

Entrega:

- Cadastro e edicao de lotes.
- Quantidade inicial e atual.
- Data de alojamento.
- Fase do lote.
- Indicadores por lote.
- Saida/baixa de aves.
- Integracao com movimentacoes e producao.

### Movimentacoes

Rota: `/movements`

Entrega:

- Historico de entradas, saidas, perdas, ajustes e transferencias.
- Reversao/desfazer quando aplicavel.
- Rastreabilidade operacional por lote.

### Coleta de ovos

Rota: `/egg-collection`

Entrega:

- Lancamento diario de coleta.
- Coleta por lote.
- Indicadores de postura.
- Historico de taxa de postura.
- Totalizadores.
- Integracao com estoque de ovos.

### Simulacao de postura

Rota: `/posture-simulation`

Entrega:

- Simulacao de postura por periodo.
- Comparacao mensal.
- Projecoes de producao.
- Quebra detalhada de previsoes.

### Estoque de ovos

Rota: `/egg-stock`

Entrega:

- Controle de saldo de ovos.
- Ajustes de estoque.
- Entradas ligadas a coleta.
- Saidas ligadas a vendas/pedidos quando aplicavel.

### Racao e alimentacao

Rota: `/feed`

Entrega:

- Cadastro de ingredientes.
- Historico de precos de ingredientes.
- Lotes de ingredientes.
- Movimentacao de estoque de ingredientes.
- Formulas de racao.
- Itens de formula.
- Fabricacao de bateladas.
- Estoque de racao pronta.
- Lancamentos de alimentacao diaria.
- Recomendacoes de consumo.
- Correcoes e transferencias de estoque.
- Paginacao e indicadores do painel de alimentacao.

### Calendario e luz

Rota: `/calendar`

Entrega:

- Agenda operacional.
- Eventos de manejo.
- Programas de luz.
- Etapas de iluminacao.
- Associacao de programa de luz a lote.

### Vacinacao

Rota: `/vaccination`

Entrega:

- Cadastro de vacinas/manejos sanitarios.
- Dose, via, data e observacoes.
- Historico por lote.
- Edicao de registros.

### Central da automacao

Rota: `/automation-center`

Entrega:

- Painel central de configuracoes do ESP32.
- Indicadores e graficos de automacao.
- Configuracao de Wi-Fi do ESP32.
- Configuracao de MQTT do ESP32.
- Terminal comum de comandos/respostas do ESP.
- Acesso a dados de rede captados pelo ESP.

### Iluminacao

Rota: `/integrations`

Entrega:

- Aba propria de iluminacao.
- Controle de canais de rele.
- Estado real dos canais.
- Agenda de iluminacao por canal.
- Sincronizacao de agenda via HTTP local e MQTT remoto.
- Mensagens do ESP no app.
- Acks de comando e de agenda.
- Fallback de comunicacao: rede local prioritaria, MQTT para operacao remota.

### Ambiente

Rota: `/hardware-environment`

Entrega:

- Tela dedicada a sensor de ambiente.
- Leitura de temperatura/umidade quando o ESP disponibiliza.
- Configuracao de endpoint.
- Payload bruto para diagnostico.

### Ventilacao

Rota: `/hardware-ventilation`

Entrega:

- Tela dedicada de ventilacao.
- Painel visual de ventiladores.
- Canais reservados para ventilacao no ESP32.
- Indicadores e comandos preparados para integracao.

### Agua

Rota: `/hardware-water`

Entrega:

- Tela de reservatorio/agua.
- Leituras de nivel e sensores analogicos quando conectados ao ESP.
- Painel de diagnostico.

### Cameras

Rota: `/cameras`

Entrega:

- Monitoramento por camera.
- Grade de cameras.
- Player de stream.
- Controles de layout.
- Suporte arquitetural para cameras RTSP/ONVIF.

### Comercial

Rota: `/commercial`

Entrega:

- Cadastro de clientes.
- Pedidos.
- Itens de pedido.
- Historico de status.
- Entrega/faturamento.
- Vendas.
- Integracao com estoque de ovos e financeiro.

### Financeiro da granja

Rota: `/finance`

Entrega:

- Visao financeira do negocio.
- Receitas e despesas.
- Contas a pagar.
- Investimentos.
- Pro-labore.
- Previsoes e simulador.
- Estabelecimentos financeiros.

### Financeiro pessoal

Rota: `/personal-finance`

Entrega:

- Transacoes pessoais.
- Reservas.
- Investimentos pessoais.
- Dividas.
- Bens/ativos.
- Visao separada do financeiro da granja.

### Relatorios

Rota: `/reports`

Entrega:

- Relatorios gerenciais.
- Visoes consolidadas da operacao.
- Base para analise de producao, comercial e financeiro.

### Alertas

Rota: `/alerts`

Entrega:

- Alertas manuais e programados.
- Alertas ligados ao calendario.
- Edicao e criacao de lembretes.
- Lista de alertas ativos.

### Usuarios

Rota: `/users`

Entrega:

- Cadastro de usuarios.
- Edicao de usuarios.
- Redefinicao de senha.
- Cadastro de propriedades/tenants.
- Definicao de permissoes.
- Superadmin com acesso total.
- Admin limitado a propria propriedade.

### Configuracoes

Rota: `/settings`

Entrega:

- Configuracao de servidor de sincronizacao.
- Campo de token de sincronizacao preenchido quando existe token salvo.
- Token oculto por padrao, com opcao de exibir.
- Validacao de configuracao com servidor.
- Fila e historico de sincronizacao.
- Terminal visual de sync, organizado para telas pequenas.
- Configuracoes operacionais do app.

### Auditoria

Rota: `/audit`

Entrega:

- Historico de operacoes.
- Rastreabilidade de alteracoes.
- Apoio a diagnostico e controle de usuarios.

## 5. Autenticacao, multi-tenant e permissoes

O app tem login obrigatorio e redirecionamento por permissao.

Regras entregues:

- Usuario sem sessao vai para `/login`.
- Usuario autenticado so acessa rotas liberadas.
- Usuario sem permissao para a rota e redirecionado para a primeira rota permitida.
- Se nenhuma rota for permitida, cai em tela de "Sem acesso".
- Superadmin pode tudo.
- Admin pode administrar apenas dentro da propria propriedade.
- Dados sao associados ao tenant/propriedade para impedir que uma propriedade veja dados da outra.
- Permissoes sao granulares por recurso/tela, por exemplo `dashboard.view`, `lots.view`, `settings.view`, `hardware.lighting.view`.

## 6. Banco local e tabelas principais

O banco local inclui tabelas para:

- Tenants/propriedades.
- Usuarios.
- Permissoes de usuarios.
- Auditoria.
- Lotes.
- Movimentacoes de aves.
- Coleta de ovos.
- Estoque de ovos.
- Ingredientes.
- Historico de precos.
- Lotes de ingredientes.
- Estoque de ingredientes.
- Formulas de racao.
- Bateladas de racao.
- Estoque de racao.
- Alimentacao diaria.
- Recomendacoes de consumo.
- Clientes.
- Pedidos.
- Itens de pedido.
- Historico de pedidos.
- Embalagens.
- Lotes de embalagem.
- Bandejas/lotes de ovos.
- Vendas.
- Financeiro da granja.
- Investimentos.
- Estabelecimentos financeiros.
- Financeiro pessoal.
- Reservas.
- Dividas.
- Programas de iluminacao.
- Eventos de calendario.
- Configuracoes de notificacao.
- Configuracoes do app.
- Leituras de sensores.
- Eventos de automacao.
- Registros de vacinacao.
- Fila de sincronizacao.
- Historico de sincronizacao.

## 7. Sincronizacao

### Objetivo

A sincronizacao mantem o servidor remoto como espelho do banco local e permite continuidade quando ha mais de um device/usuario.

### Fila clara

O app registra itens de fila e historico. A tela de configuracoes exibe:

- Itens pendentes.
- Operacoes executadas.
- Validacoes de configuracao.
- Resultado da sincronizacao.
- Mensagens de erro.
- Estado visual em formato de terminal.

### Evitar sincronizacao desnecessaria

O fluxo atual evita gerar historico/cache quando nao ha alteracao real. A sincronizacao deve ser acionada quando existe mudanca local/remota relevante ou validacao solicitada.

### Primeiro login

No primeiro login, se o usuario nao existir localmente, o app consulta o banco remoto pelo endpoint de login/sync. Isso permite recuperar usuario/permissoes sem recriar dados manualmente no device.

### Assinatura HMAC

O servidor aceita token simples, mas a configuracao atual exige assinatura HMAC.

Cabecalhos usados:

- `X-Seleto-Sync-Timestamp`
- `X-Seleto-Sync-Nonce`
- `X-Seleto-Sync-Signature`
- `X-Seleto-Sync-Token` ou `Authorization: Bearer`

O servidor rejeita:

- Assinatura ausente quando exigida.
- Timestamp fora da janela permitida.
- Nonce repetido.
- Assinatura invalida.
- Token incorreto.

## 8. Servidor remoto

Servidor atual:

- IP: `131.221.236.34`
- Servico sync: `seleto-sync`
- Porta padrao do sync: `5005`
- MQTT: `1883`
- Banco remoto: PostgreSQL.

Scripts relacionados:

- `scripts/deploy_seleto_sync_mqtt.sh`
- `scripts/install_seleto_sync_service.sh`
- `scripts/update_seleto_mqtt_server.sh`
- `scripts/install_solveon_remote_iot_stack.sh`

Cuidados do deploy:

- O script libera apenas as portas necessarias.
- Nao deve fechar portas ja abertas.
- Nao deve derrubar servicos de outras aplicacoes.
- O script de instalacao pede senha do PostgreSQL quando ela nao e informada.
- A senha do banco fica no arquivo de ambiente do servidor, normalmente `/etc/seleto-sync.env`, com permissao restrita.

## 9. ESP32 - firmware e endpoints

Firmware:

`docs/hardware/firmware/esp32-granja-seleto/granja_seleto_wifi_bluetooth.ino`

Endpoints HTTP entregues:

- `GET /api/ping`
- `GET /api/status`
- `GET /api/environment`
- `GET /api/water`
- `GET /api/sensors`
- `GET /api/relay?channel=1`
- `POST /api/relay`
- `POST /api/channel_schedule`
- `POST /api/group_schedule`
- `GET /api/schedule`
- `POST /api/time`
- `POST /api/wifi`
- `POST /api/wifi/disconnect`
- `GET /api/wifi/scan`
- `GET /api/mqtt`
- `POST /api/mqtt`

Recursos do firmware:

- Wi-Fi em modo `WIFI_AP_STA`.
- AP de recuperacao `SELETO-SETUP`.
- WebServer local na porta 80.
- Horario por NTP.
- Sincronizacao de horario por app.
- Rele ativo baixo configuravel.
- 12 canais de rele.
- Canais 1 a 4 reservados para iluminacao.
- Canais 5 a 12 reservados para ventilacao/expansao.
- Agenda com 2 janelas por canal.
- Persistencia da agenda na flash.
- Persistencia de MQTT na flash.
- Scan de redes Wi-Fi captadas pelo ESP.
- Publicacao de mensagens detalhadas para o app.

## 10. MQTT do ESP32

Topicos do device:

- `seleto/esp32/SELETO-RELE-01/status`
- `seleto/esp32/SELETO-RELE-01/sensors`
- `seleto/esp32/SELETO-RELE-01/relay/state`
- `seleto/esp32/SELETO-RELE-01/schedule/state`
- `seleto/esp32/SELETO-RELE-01/wifi/scan/state`
- `seleto/esp32/SELETO-RELE-01/command/ack`
- `seleto/esp32/SELETO-RELE-01/schedule/ack`
- `seleto/esp32/SELETO-RELE-01/relay/command`
- `seleto/esp32/SELETO-RELE-01/schedule/command`
- `seleto/esp32/SELETO-RELE-01/wifi/scan/command`
- `seleto/esp32/SELETO-RELE-01/ping`

O ESP publica mensagens com envelope contendo:

- `deviceId`
- `source`
- `message`
- `localTime`
- `uptimeMs`

Isso permite que o app mostre respostas mais claras no terminal.

## 11. Iluminacao em tempo real

O controle de iluminacao entrega:

- Liga/desliga por canal.
- Estado real publicado pelo ESP.
- Agenda por canal.
- Envio de agenda por MQTT.
- Confirmacao de agenda por `schedule/ack`.
- Estado salvo/publicado por `schedule/state`.
- Estado dos reles por `relay/state`.
- Comando manual por `relay/command`.
- Confirmacao por `command/ack`.

Quando o app esta na mesma rede local do ESP, a comunicacao local e prioritaria por ser mais rapida. Quando o usuario esta fora da rede local, o app usa MQTT para comando e agenda.

## 12. Scan Wi-Fi pelo ESP32

O app consegue solicitar o scan das redes que o ESP32 enxerga.

Formas de scan:

- HTTP local: `GET /api/wifi/scan`
- MQTT remoto: publicar em `wifi/scan/command` e receber em `wifi/scan/state`

O app exibe os dados em formato de terminal Linux, adequado para telas pequenas, com:

- SSID.
- RSSI em dBm.
- Canal.
- Criptografia.
- BSSID quando disponivel.
- Nivel textual claro: `BOM`, `RAZOAVEL`, `ACEITAVEL` ou `RUIM`.

Esse scan e do ESP32, nao apenas do device Android. Quando houver dados do device e do ESP, o app pode cruzar as informacoes para diagnosticar diferenca de sinal.

## 13. Cameras

O modulo de cameras esta preparado para cameras de baixo custo que exponham stream RTSP e/ou ONVIF.

Entrega atual:

- Cadastro/monitoramento visual.
- Grade de exibicao.
- Player.
- Indicadores de camera ativa/inativa.
- Base para cameras IP locais ou remotas.

Recomendacao tecnica:

- Preferir camera com RTSP/ONVIF.
- Evitar depender de app proprietario fechado sem RTSP.
- Para acesso remoto, usar VPN, tunnel seguro ou servidor intermediario; nao expor camera diretamente na internet sem protecao.

## 14. Scripts e comandos importantes

Build release:

```bash
flutter build apk --release
```

Instalar mantendo banco local:

```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

Atualizar MQTT no servidor:

```bash
REMOTE_USER=ourinet \
REMOTE_HOST=131.221.236.34 \
KEEP_MQTT_PASSWORD=true \
REMOTE_SUDO_PASSWORD='mk20ur1cli' \
scripts/update_seleto_mqtt_server.sh
```

Deploy completo sync + MQTT:

```bash
REMOTE_USER=ourinet \
REMOTE_HOST=131.221.236.34 \
POSTGRES_DB=seleto \
POSTGRES_USER=agrogestor \
scripts/deploy_seleto_sync_mqtt.sh
```

Instalar servico de sync diretamente no servidor:

```bash
sudo SERVICE_NAME=seleto-sync \
SOURCE_SCRIPT=/tmp/seleto-deploy/seleto_sync_server.py \
SELETO_SYNC_PORT=5005 \
SELETO_SYNC_REQUIRE_SIGNATURE_VALUE=true \
POSTGRES_DB_VALUE=seleto \
POSTGRES_USER_VALUE=agrogestor \
scripts/install_seleto_sync_service.sh
```

## 15. Seguranca atual

Entregue:

- Login obrigatorio.
- Permissoes por tela/recurso.
- Isolamento por tenant.
- Token de sync.
- Assinatura HMAC nas requisicoes de sync.
- Nonce para evitar replay.
- Janela de timestamp.
- MQTT com usuario/senha.
- ACL de topicos do Mosquitto.
- Senha do banco em variavel de ambiente/arquivo `.env` do servidor com permissao restrita.

Observacao:

- HTTPS com certificado publico em IP puro nao e confiavel sem dominio. Por isso foi adotada assinatura HMAC/token para proteger a integridade/autenticidade da comunicacao de sync mesmo usando IP.

## 16. O que exige firmware novo no ESP32

Para as funcionalidades abaixo funcionarem no hardware fisico, o ESP32 precisa estar com o firmware atual deste repositorio:

- Scan Wi-Fi por HTTP.
- Scan Wi-Fi por MQTT.
- Buffer MQTT de `8192`.
- Mensagens detalhadas com `message`, `localTime` e `uptimeMs`.
- Topico `wifi/scan/state`.
- Topico `wifi/scan/command`.
- Acks detalhados de agenda/comando.

## 17. Cuidados operacionais

- Nao desinstalar o app se quiser preservar o banco local.
- Nao limpar dados do app no Android.
- Nao alterar manualmente o caminho do banco.
- Usar APK release para instalacao final.
- Para atualizar servidor, nao fechar portas ja abertas.
- Para MQTT, manter ACL com os topicos novos de `wifi/scan`.
- Para validar agenda remota, verificar `schedule/ack` e depois `schedule/state`.
- Para validar estado real de canal, verificar `relay/state`.
- Para validar Wi-Fi do ESP, verificar `wifi/scan/state`.

## 18. Estado atual do projeto

Hoje o projeto entrega uma plataforma local-first para granja com:

- Controle operacional completo de lotes, ovos, racao e manejo.
- Controle comercial e financeiro.
- Usuarios, permissoes e multi-tenant.
- Sincronizacao remota assinada.
- Servidor de sync e MQTT implantaveis por script.
- Automacao ESP32 com HTTP local e MQTT remoto.
- Iluminacao com agenda remota e estado real.
- Diagnostico de rede Wi-Fi captada pelo proprio ESP.
- Interface preparada para operacao em telas pequenas.
- Preservacao do banco local quando o app e atualizado corretamente.
