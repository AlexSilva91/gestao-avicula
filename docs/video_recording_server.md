# Plataforma propria de CFTV, liveview e gravacoes

Este documento define uma arquitetura recomendada para uma plataforma CFTV multi-cliente, com app multiplataforma, interfaces personalizadas, permissao por usuario/camera/audio, liveview em tempo real, reproducao de gravacoes e alertas configuraveis.

A ideia central e construir um produto proprio, sem depender de softwares NVR prontos como Shinobi. O sistema pode usar componentes de infraestrutura maduros, como PostgreSQL, FFmpeg, WebRTC/SFU, object storage e filas, mas a experiencia, as permissoes, o painel, o app, a regra de negocio e o provisionamento por cliente ficam sob controle do GRANJA SELETO.

## Requisitos do servidor CFTV

### Cameras

- cadastro, remocao e edicao de cameras;
- teste de conexao RTSP;
- status online/offline;
- configuracao de nome, local, grupo, audio, retencao e qualidade;
- liveview em tempo real;
- reproducao de gravacoes;
- controle de acesso por usuario.

### Usuarios

- cadastro, remocao e edicao de usuarios;
- perfis por cliente;
- usuarios administradores por cliente;
- usuarios comuns com acesso parcial;
- permissao por canal;
- permissao por audio;
- permissao para ver live;
- permissao para ver gravacoes;
- permissao para baixar trechos;
- permissao para receber alertas.

### Liveview e playback

- liveview em tempo real;
- liveview com ou sem audio conforme permissao;
- grid de canais personalizado;
- playback de gravacoes por data/hora;
- playback com ou sem audio conforme permissao;
- download/exportacao controlada;
- auditoria de acesso.

### Alertas

- alertas no celular do cliente;
- regras configuraveis por camera;
- horario de funcionamento por alerta;
- dias da semana;
- severidade;
- canais/usuarios que recebem o alerta;
- historico de incidentes;
- silenciamento temporario;
- auditoria de disparos.

## Melhor arquitetura geral

A melhor arquitetura e hibrida:

1. Agente local no cliente para capturar RTSP dentro da rede local.
2. Servidor central proprio para autenticacao, permissoes, API, metadados, alertas e coordenacao.
3. Camada de media separada para liveview e playback.
4. Storage de gravacoes separado da API.
5. App Flutter multiplataforma para Android, iOS, Windows, Linux, macOS e Web opcional.

Fluxo de gravacao:

```text
Camera RTSP
  -> Agente local do cliente
  -> Ingestao segura no servidor central
  -> Storage de segmentos
  -> API/DB de metadados
  -> App do cliente
```

Fluxo de liveview:

```text
Camera RTSP
  -> Agente local
  -> Gateway de media/WebRTC
  -> App autorizado
```

## Por que usar agente local

O servidor central nao deve puxar RTSP diretamente das cameras pela internet.

Problemas evitados:

- NAT;
- IP dinamico;
- abertura de portas;
- cameras expostas na internet;
- suporte dificil em roteadores diferentes;
- instabilidade de conexao;
- risco de vazamento de credenciais RTSP.

O agente local fica na rede das cameras, abre os RTSP localmente e conversa com o servidor central por HTTPS, WebSocket ou VPN segura.

## Stack recomendada

### App cliente

Recomendacao: Flutter.

Motivos:

- uma base de codigo para Android, iOS, Windows, macOS, Linux e Web;
- combina com o app atual;
- permite interfaces personalizadas por cliente;
- bom suporte para apps operacionais, dashboards e players;
- facilita manter o mesmo permissionamento visual em todas as plataformas.

Plataformas alvo:

```text
Android
iOS
Windows
Linux
macOS
Web opcional
```

Para player:

- liveview de baixa latencia: WebRTC;
- gravacoes: HLS/fMP4 ou MP4 segmentado;
- desktop/mobile nativo: WebRTC SDK ou player nativo;
- web: HLS/WebRTC, nunca RTSP direto.

### Backend/API

Recomendacao: Go ou Python/FastAPI.

Escolha preferida para longo prazo: Go.

Motivos:

- bom para servicos concorrentes;
- bom para agentes locais;
- gera binario simples para Linux/Windows;
- baixo consumo;
- facilita workers, ingestao e conexoes persistentes.

FastAPI tambem e uma boa escolha se a velocidade de desenvolvimento for mais importante no MVP.

Sugestao pratica:

```text
API principal: Go ou FastAPI
Agente local: Go
Workers de video: Go chamando FFmpeg
IA/eventos futuros: Python separado
```

### Banco de dados

Recomendacao: PostgreSQL.

Motivos:

- relacional e confiavel;
- bom para multi-tenant;
- suporta Row Level Security;
- bom para auditoria, permissoes, eventos e metadados;
- facilita consultas por camera/data/usuario.

Use PostgreSQL para:

- clientes;
- unidades;
- cameras;
- usuarios;
- papeis;
- permissoes;
- segmentos gravados;
- alertas;
- incidentes;
- logs de auditoria;
- sessoes;
- tokens de agentes.

### Cache, fila e tempo real

Recomendacao inicial: Redis.

Usos:

- fila simples de jobs;
- cache de sessoes;
- rate limit;
- pub/sub de eventos;
- estado online/offline de agentes;
- fanout de notificacoes internas.

Evolucao: NATS.

Use NATS quando houver muitos agentes, muitos eventos e necessidade de mensageria mais robusta.

### Media/liveview

Para liveview, a melhor escolha tecnica e WebRTC.

Motivos:

- baixa latencia;
- funciona em navegadores modernos e clientes nativos;
- permite audio/video;
- permite controle de tracks de audio e video;
- e mais adequado que HLS para tempo real.

Opcoes:

1. LiveKit self-hosted.
2. SRS.
3. Gateway WebRTC proprio com Pion, no futuro.

Recomendacao: LiveKit self-hosted no inicio do produto real.

Isso nao transforma o produto em NVR pronto. LiveKit seria apenas a infraestrutura de transporte WebRTC/SFU. O sistema de cameras, permissoes, clientes, gravacoes, alertas e app continuam proprios.

Modelo:

```text
1 camera = 1 stream/trilha de video
audio da camera = track separada
usuario recebe token com permissao apenas para tracks autorizadas
```

Se o usuario nao tem permissao de audio, o backend nao entrega autorizacao para assinar a track de audio.

### Gravacoes/playback

Para gravacoes, use segmentos.

Formato recomendado:

```text
fMP4 ou MP4 segmentado
```

Tamanho:

```text
1 a 5 minutos por segmento
```

Playback:

```text
HLS sob demanda
```

Por que HLS para gravacoes:

- funciona bem em mobile e web;
- facilita timeline;
- permite tocar trechos especificos;
- e mais simples que WebRTC para arquivo historico.

## Componentes do sistema

### 1. Agente local

Roda no cliente.

Pode ser:

- mini PC Linux;
- NVR Linux;
- servidor local;
- container Docker;
- appliance proprio no futuro.

Responsabilidades:

- conectar nas cameras RTSP;
- testar conexao;
- publicar live para o gateway WebRTC;
- gravar segmentos localmente quando necessario;
- enviar segmentos para o servidor;
- reportar status;
- receber configuracoes;
- atualizar credenciais;
- reiniciar streams com falha;
- monitorar audio/video.

Configuracao remota:

```text
agent_id
tenant_id
site_id
token
camera_configs
recording_policy
alert_policy
```

### 2. API central

Responsabilidades:

- autenticacao;
- usuarios;
- permissoes;
- tenants/clientes;
- sites/unidades;
- cameras;
- politicas de audio;
- politicas de gravacao;
- politicas de alerta;
- auditoria;
- entrega de tokens WebRTC;
- entrega de URLs HLS autorizadas;
- coordenacao dos agentes.

### 3. Servico de autorizacao de media

Responsavel por decidir:

- usuario pode ver camera X?
- usuario pode ouvir camera X?
- usuario pode ver gravacoes da camera X?
- usuario pode baixar trecho?
- usuario esta dentro do horario permitido?
- alerta esta ativo nesse horario?

Nunca deixe o app decidir permissao sozinho. O app pede acesso, o backend valida e emite uma credencial curta.

### 4. Servico de gravacao

Responsabilidades:

- receber segmentos;
- validar tenant/camera/token;
- salvar arquivo;
- registrar segmento no banco;
- gerar thumbnails;
- marcar duracao;
- verificar integridade;
- acionar retencao.

### 5. Servico de playback

Responsabilidades:

- receber pedido de camera/data/hora;
- validar permissao;
- montar playlist HLS temporaria;
- assinar URLs;
- bloquear audio quando usuario nao tiver permissao;
- registrar auditoria.

### 6. Servico de alertas

Responsabilidades:

- avaliar regras de alerta;
- respeitar janelas de horario;
- disparar push no celular;
- registrar incidente;
- evitar spam;
- escalar severidade;
- permitir silenciar por tempo.

## Modelo de permissoes

Permissao deve ser por usuario e por camera.

Entidades sugeridas:

```text
users
roles
permissions
camera_permissions
camera_groups
user_camera_groups
```

Permissoes por camera:

```text
can_view_live
can_hear_live_audio
can_view_recordings
can_hear_recording_audio
can_download_recordings
can_control_alerts
can_receive_alerts
```

Exemplo:

```text
Usuario Joao
  Camera Galpao 1:
    live: sim
    audio_live: nao
    gravacoes: sim
    audio_gravacoes: nao
    download: nao

  Camera Escritorio:
    live: nao
    audio_live: nao
    gravacoes: nao
```

## Perfis de usuario

### Super admin da plataforma

Seu usuario interno.

Pode:

- ver todos os clientes;
- provisionar clientes;
- administrar servidores/agentes;
- suporte tecnico;
- acessar logs conforme politica.

### Admin do cliente

Usuario administrador de um cliente.

Pode:

- cadastrar usuarios do proprio cliente;
- editar usuarios do proprio cliente;
- liberar cameras;
- liberar ou bloquear audio;
- configurar alertas;
- ver cameras permitidas para o cliente;
- gerenciar grupos e locais.

Nao pode:

- acessar outro cliente;
- ver cameras de outro cliente;
- alterar infra global.

### Operador/usuario comum

Pode apenas:

- ver canais permitidos;
- ouvir apenas canais com audio liberado;
- ver gravacoes permitidas;
- receber alertas permitidos.

## Audio como permissao separada

Audio deve ser tratado como permissao independente, nao como detalhe do player.

Regras:

- video e audio sao autorizados separadamente;
- usuario pode ter video sem audio;
- usuario pode ver live sem ouvir;
- usuario pode ver gravacao sem ouvir;
- usuario pode ter audio em algumas cameras e nao em outras;
- auditoria deve registrar quando audio foi liberado.

No liveview WebRTC:

```text
video track autorizada
audio track autorizada apenas se permitido
```

No playback:

```text
se usuario nao pode ouvir audio:
  entregar playlist/arquivo sem audio
ou
  gerar/remuxar versao sem audio sob demanda
```

Para economizar CPU, se possivel grave video e audio separados ou mantenha metadados que permitam gerar versoes sem audio sob demanda.

## Alertas configuraveis

Entidades sugeridas:

```text
alert_rules
alert_schedules
alert_recipients
alert_incidents
alert_silences
```

Campos de uma regra:

```text
tenant_id
site_id
camera_id
type
enabled
severity
schedule_id
cooldown_seconds
recipient_policy
push_enabled
email_enabled
in_app_enabled
```

Tipos de alerta:

- camera offline;
- perda de audio;
- perda de video;
- movimento;
- pessoa detectada;
- zona invadida;
- falha de gravacao;
- disco cheio;
- agente offline.

Agenda:

```text
sempre ativo
somente horario comercial
somente noite
dias especificos
janela customizada
```

Exemplo:

```text
Alerta: movimento no galpao 2
Ativo: segunda a sexta, 18:00-06:00
Destinatarios: administradores + vigia
Cooldown: 5 minutos
Push: sim
```

Para notificacoes mobile, use FCM no Android e integracao APNs/iOS via Firebase ou configuracao nativa.

## Modelo multi-tenant

Toda entidade operacional deve carregar `tenant_id`.

Exemplos:

```text
sites.tenant_id
cameras.tenant_id
users.tenant_id
recording_segments.tenant_id
alert_rules.tenant_id
audit_logs.tenant_id
```

Camadas de protecao:

1. filtro obrigatorio no backend;
2. Row Level Security no PostgreSQL;
3. tokens curtos por tenant;
4. storage particionado por tenant;
5. auditoria de acessos.

## Estrutura de storage

Organizacao recomendada:

```text
tenant/site/camera/yyyy/mm/dd/hh/mm/segment.mp4
```

Exemplo:

```text
granja-seleto/matriz/galpao-01/2026/09/28/18/00/segment-0001.mp4
```

Metadados no banco:

```text
recording_segments
  id
  tenant_id
  site_id
  camera_id
  started_at
  ended_at
  duration_ms
  storage_node
  object_key
  size_bytes
  has_audio
  codec_video
  codec_audio
  status
  expires_at
```

## Retencao

Politicas por cliente/plano/camera:

```text
basic: 3 dias
standard: 7 dias
premium: 30 dias
enterprise: customizado
```

O worker de retencao:

- apaga segmentos vencidos;
- respeita segmentos protegidos;
- atualiza banco;
- emite log de auditoria;
- gera relatorio de uso.

## Liveview vs playback

### Liveview

Use WebRTC.

Objetivo:

- baixa latencia;
- audio/video em tempo real;
- permissao por track;
- experiencia boa em mobile e desktop.

### Playback

Use HLS/fMP4.

Objetivo:

- estabilidade;
- timeline;
- busca por horario;
- download/exportacao;
- custo menor.

## App multiplataforma

Recomendacao: Flutter.

Telas principais:

- login;
- selecao de ambiente/cliente;
- dashboard de cameras;
- liveview grid;
- camera ampliada;
- timeline de gravacoes;
- incidentes/alertas;
- administracao de usuarios;
- permissoes por usuario;
- cadastro/teste de cameras;
- configuracao de alertas;
- auditoria/downloads.

Personalizacao por cliente:

- logo;
- cores;
- nome do ambiente;
- grupos de cameras;
- layouts salvos;
- permissao de recursos por plano.

## Tabelas principais

```text
tenants
tenant_branding
sites
cameras
camera_groups
users
roles
user_roles
camera_permissions
agents
agent_heartbeats
recording_segments
recording_exports
alert_rules
alert_schedules
alert_recipients
alert_incidents
audit_logs
device_push_tokens
```

## APIs principais

### Cameras

```text
POST   /cameras
GET    /cameras
PATCH  /cameras/:id
DELETE /cameras/:id
POST   /cameras/:id/test
GET    /cameras/:id/status
```

### Usuarios

```text
POST   /users
GET    /users
PATCH  /users/:id
DELETE /users/:id
PUT    /users/:id/camera-permissions
```

### Liveview

```text
POST /live/sessions
POST /live/sessions/:id/token
```

O backend valida permissao e emite token de media temporario.

### Gravacoes

```text
GET  /recordings
GET  /recordings/timeline
POST /recordings/playback-session
POST /recordings/export
```

### Alertas

```text
POST   /alerts/rules
GET    /alerts/rules
PATCH  /alerts/rules/:id
DELETE /alerts/rules/:id
GET    /alerts/incidents
POST   /alerts/incidents/:id/ack
POST   /alerts/silence
```

## Infraestrutura inicial recomendada

Para o MVP:

```text
1 servidor dedicado
Docker Compose
PostgreSQL
Redis
API
Worker de ingestao
Worker de retencao
Worker de alertas
LiveKit ou SRS
Caddy/Nginx
Storage em disco local
```

Quando crescer:

```text
API em servidor separado
PostgreSQL gerenciado ou dedicado
Redis/NATS
Nos de storage
Nos de media/WebRTC
Object storage S3/MinIO
Monitoramento Prometheus/Grafana
Backups offsite
```

## Estrategia de desenvolvimento

### Fase 1 - MVP funcional

1. Cadastro de cliente.
2. Cadastro de cameras.
3. Agente local.
4. Teste RTSP.
5. Liveview com permissao por camera.
6. Audio permitido/bloqueado por camera.
7. Gravacao em segmentos.
8. Playback HLS.
9. Usuarios e permissoes.
10. Alertas de camera offline/agente offline.

### Fase 2 - Produto comercial

1. Interface personalizada por cliente.
2. Grupos de cameras.
3. Layouts salvos de grid.
4. Alertas com horario.
5. Push mobile.
6. Auditoria completa.
7. Exportacao de trechos.
8. Dashboard de saude.

### Fase 3 - Escala

1. Nos de storage.
2. Multi-regiao se necessario.
3. IA para eventos.
4. Retencao premium.
5. Object storage.
6. Alta disponibilidade.

## Decisao recomendada

Melhor stack para este produto:

```text
App: Flutter
API: Go ou FastAPI
Agente local: Go + FFmpeg
Banco: PostgreSQL
Fila/cache: Redis no MVP, NATS na escala
Live baixa latencia: WebRTC via LiveKit self-hosted
Playback gravado: HLS/fMP4
Storage inicial: filesystem local
Storage futuro: S3/MinIO
Push mobile: Firebase Cloud Messaging + APNs/iOS
Proxy: Caddy ou Nginx
Deploy inicial: Docker Compose
Deploy futuro: Kubernetes ou Nomad apenas quando houver escala real
```

Ponto mais importante: permissoes de video e audio devem ser aplicadas no backend e na camada de media, nao apenas escondidas no app.

## Fontes tecnicas

- Flutter supported platforms: https://docs.flutter.dev/reference/supported-platforms
- WebRTC: https://webrtc.org/
- LiveKit self-hosting: https://docs.livekit.io/transport/self-hosting/
- Firebase Cloud Messaging: https://firebase.google.com/docs/cloud-messaging
- PostgreSQL Row Level Security: https://www.postgresql.org/docs/17/ddl-rowsecurity.html
- FFmpeg HLS muxer: https://ffmpeg.org/ffmpeg-formats.html#hls-2
