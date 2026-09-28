# Servidor próprio para gravações de câmeras

Este documento resume uma arquitetura econômica para armazenar gravações de câmeras RTSP em infraestrutura própria, sem depender de softwares prontos de NVR como Shinobi. A ideia é permitir ambientes personalizados por cliente, com controle total de retenção, acesso, layout, armazenamento e integrações.

## Objetivo

Criar uma plataforma própria para:

- gravar câmeras RTSP por cliente;
- armazenar gravações em segmentos;
- consultar gravações por câmera, data e horário;
- aplicar retenção por plano/cliente;
- permitir visualização e download pelo app/painel;
- manter isolamento entre clientes;
- escalar de um servidor dedicado simples para múltiplos nós.

## Princípio principal

O servidor central não deve depender de acessar diretamente as câmeras dos clientes pela internet. Isso evita problemas de NAT, IP dinâmico, portas abertas e exposição de câmeras.

A abordagem recomendada é:

1. Um agente local roda na rede do cliente.
2. O agente acessa as câmeras RTSP localmente.
3. O agente grava ou segmenta o vídeo.
4. O agente envia os segmentos para o servidor central.
5. O servidor central armazena, indexa e disponibiliza as gravações.

## Componentes

### Agente local

Roda em um mini PC, NVR Linux, servidor local ou container Docker na rede do cliente.

Responsabilidades:

- buscar configuração no servidor central;
- abrir os streams RTSP das câmeras;
- gravar segmentos com FFmpeg ou GStreamer;
- enviar segmentos para o servidor;
- reportar status, falhas e métricas;
- reconectar streams automaticamente.

### Servidor central

Roda em servidor dedicado ou VPS com bom armazenamento.

Responsabilidades:

- API de clientes, unidades, câmeras e permissões;
- recebimento de segmentos;
- armazenamento em disco local ou object storage;
- catálogo de gravações no banco;
- limpeza automática por retenção;
- geração de playback/download;
- autenticação e isolamento multi-cliente.

### Banco de dados

PostgreSQL é uma boa escolha.

Tabelas principais:

- `tenants`
- `sites`
- `cameras`
- `recording_segments`
- `users`
- `permissions`
- `retention_policies`
- `agent_heartbeats`

Cada segmento deve registrar:

- cliente;
- unidade/local;
- câmera;
- início;
- fim;
- caminho do arquivo;
- tamanho;
- status;
- checksum opcional;
- data de expiração.

## Estrutura de arquivos

Use segmentos curtos, por exemplo de 1, 5 ou 10 minutos.

Exemplo:

```text
cliente/camera/ano/mes/dia/hora/minuto.mp4
```

Exemplo real:

```text
granja-seleto/cam01/2026/09/28/08/50.mp4
```

Vantagens:

- apagar gravações antigas fica simples;
- recuperar falhas fica mais fácil;
- baixar um trecho específico exige juntar poucos arquivos;
- playback por horário fica direto;
- evita arquivos gigantes corrompidos.

## Cálculo de armazenamento

Regra prática:

```text
Mbps da câmera x 0,45 = GB por hora
```

Exemplos aproximados:

```text
1 câmera a 2 Mbps = 0,9 GB/h
24h = 21,6 GB/dia
30 dias = 648 GB/mês por câmera
```

Estimativas:

```text
4 câmeras a 2 Mbps por 30 dias  = ~2,6 TB
8 câmeras a 2 Mbps por 30 dias  = ~5,2 TB
16 câmeras a 2 Mbps por 30 dias = ~10,4 TB
```

Variáveis que mais afetam custo:

- bitrate;
- resolução;
- FPS;
- codec;
- retenção;
- gravação contínua ou por evento;
- redundância/backups.

## Arquitetura econômica inicial

Para começar:

- 1 servidor dedicado com bastante disco;
- Linux;
- Docker;
- PostgreSQL;
- API própria em FastAPI, Go ou Node;
- workers de gravação/processamento;
- storage local em filesystem;
- backup seletivo em object storage quando necessário.

Exemplo de serviços:

```text
api
postgres
redis/nats
recording-ingest
retention-worker
playback-worker
nginx/caddy
```

## Escala futura

Quando crescer:

- separar API e banco;
- criar nós de storage;
- distribuir clientes/câmeras por nó;
- adicionar object storage compatível S3;
- usar MinIO quando houver discos/nós suficientes;
- replicar apenas clientes que pagam retenção premium;
- criar monitoramento por câmera/agente.

## Storage

### Fase 1: filesystem local

Mais simples e barato para começar.

Use diretórios bem organizados, permissões corretas e rotina de retenção.

### Fase 2: object storage

Opções:

- MinIO próprio;
- Backblaze B2;
- Wasabi;
- S3 compatível;
- storage frio para retenção longa.

MinIO é interessante quando houver necessidade de API S3 própria, múltiplos discos e erasure coding. Para o início, pode adicionar complexidade desnecessária.

## Retenção

Crie políticas por cliente/plano:

```text
basic: 3 dias
standard: 7 dias
premium: 30 dias
enterprise: customizado
```

O worker de retenção deve:

- consultar segmentos vencidos;
- apagar arquivos;
- marcar registros como removidos;
- manter logs de auditoria;
- nunca apagar segmentos protegidos por solicitação/exportação.

## Segurança

Recomendações:

- cada agente usa token próprio;
- tokens podem ser revogados;
- tráfego sempre via HTTPS;
- cada cliente isolado por `tenant_id`;
- permissões por usuário/câmera;
- logs de acesso a gravações;
- trilha de auditoria para downloads;
- não expor RTSP diretamente para usuários finais.

PostgreSQL Row Level Security pode ajudar no isolamento multi-cliente, mas a API também deve validar permissões.

## Playback

Opções:

- gerar HLS sob demanda;
- juntar segmentos MP4 para download;
- gerar thumbnails por horário;
- manter index por data/hora;
- permitir busca por câmera e intervalo.

Para playback web/mobile, HLS costuma ser mais prático do que RTSP direto.

## Stack sugerida

MVP:

- agente: Go ou Python + FFmpeg;
- API: FastAPI;
- banco: PostgreSQL;
- fila: Redis/RQ ou NATS;
- storage: filesystem local;
- proxy: Caddy ou Nginx;
- app: integração com API e HLS.

Evolução:

- workers separados por função;
- MinIO/S3;
- Prometheus/Grafana;
- alertas por câmera offline;
- snapshots/thumbnails;
- eventos por movimento/IA.

## MVP recomendado

1. Cadastro de cliente.
2. Cadastro de unidade/local.
3. Cadastro de câmera RTSP.
4. Agente local autenticado por token.
5. Gravação em segmentos de 5 minutos.
6. Upload/ingestão no servidor central.
7. Registro dos segmentos no PostgreSQL.
8. Listagem por câmera e data.
9. Retenção automática.
10. Download de trecho.
11. Playback HLS.

## Comando base de segmentação

Exemplo conceitual com FFmpeg:

```bash
ffmpeg -rtsp_transport tcp \
  -i "rtsp://LOGIN:SENHA@IP_CAMERA" \
  -c copy \
  -f segment \
  -segment_time 300 \
  -reset_timestamps 1 \
  "cliente/camera/%Y/%m/%d/%H/%M.mp4"
```

A implementação final deve lidar com reconexão, timeout, logs, nomes de arquivos únicos e falhas parciais.

## Observações finais

O caminho mais econômico e controlável é começar simples: agente local, segmentos curtos, servidor dedicado com disco local e PostgreSQL. Só depois adicionar MinIO, replicação e retenção longa em cloud storage.

O diferencial do produto será o controle por cliente: layouts personalizados, retenção por plano, ambientes isolados, permissões por usuário e integração direta com o app GRANJA SELETO.
