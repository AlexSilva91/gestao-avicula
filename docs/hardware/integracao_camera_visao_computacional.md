# Integração de câmeras e visão computacional

Este guia descreve como integrar câmeras ao app para visualizar imagens em tempo real, receber alertas no celular e gravar evidências curtas quando houver evento anormal nas dependências dos galpões.

## Objetivo

- Ver câmeras ao vivo pelo celular.
- Detectar acesso indevido, presença humana, movimento anormal ou entrada em área proibida.
- Enviar alerta ao celular quando houver evento.
- Salvar snapshot do evento.
- Salvar vídeo do evento com até 30 minutos: 10 minutos antes, o momento do evento e até 10 minutos depois.
- Evitar armazenamento contínuo em servidor dedicado na nuvem.

## Arquitetura recomendada

Use processamento local na granja:

- Câmeras IP com RTSP/ONVIF.
- Mini PC, Raspberry Pi 5, Orange Pi 5, Intel NUC ou NVR local.
- App Flutter como interface de visualização, configuração e alertas.
- Firebase Cloud Messaging para notificação no celular.
- Banco local ou Firestore apenas para metadados do evento.
- Arquivos de imagem/vídeo salvos localmente na granja, em SSD/cartão de memória/NAS local.

O app não precisa armazenar vídeo dentro do banco. O banco deve guardar apenas dados como câmera, horário, tipo de evento, caminho do snapshot, caminho do vídeo e status.

## Por que precisa de buffer local

Para gravar 10 minutos antes do evento, o sistema precisa manter uma gravação circular sempre ativa.

Isso funciona assim:

1. Cada câmera grava pequenos trechos de vídeo localmente, por exemplo, arquivos de 1 minuto.
2. O sistema mantém apenas os últimos 10 a 15 minutos em uma pasta temporária.
3. Quando ocorre um evento anormal, ele preserva os 10 minutos anteriores.
4. Continua gravando até 10 minutos depois do evento.
5. Junta tudo em um único vídeo do evento, com limite de até 30 minutos.
6. Apaga automaticamente os trechos temporários que não viraram evento.

Esse buffer não é um servidor dedicado na nuvem. É uma gravação local mínima, necessária para recuperar o período anterior ao evento.

## Hardware sugerido

- Câmeras IP PoE ou Wi-Fi com suporte a RTSP.
- Switch PoE, se usar câmeras PoE.
- Mini PC/Raspberry Pi/Orange Pi para processar as imagens.
- SSD externo ou interno para armazenar eventos.
- Nobreak para câmera, rede e processador local.
- Roteador com boa cobertura nos galpões.

Para ambiente rural, prefira câmera IP PoE com proteção externa, visão noturna IR e lente adequada ao corredor/portão monitorado.

## Fluxo do evento

1. Câmera envia vídeo RTSP para o processador local.
2. O processador mantém buffer circular dos últimos minutos.
3. A visão computacional detecta evento anormal.
4. O sistema salva um snapshot em JPG/WebP.
5. O sistema bloqueia os trechos anteriores do buffer.
6. O sistema grava o período posterior ao evento.
7. O sistema gera um vídeo final do evento.
8. O celular recebe notificação.
9. O app mostra snapshot, horário, local e link para abrir o vídeo.

## Eventos anormais sugeridos

- Pessoa detectada fora do horário permitido.
- Movimento em área proibida.
- Entrada por portão lateral.
- Permanência por tempo incomum.
- Veículo detectado em área restrita.
- Câmera offline.
- Obstrução da câmera.
- Mudança brusca de iluminação durante horário fechado.

## Estrutura de dados sugerida

```json
{
  "id": "evt_20260927_154210_galpao_1",
  "cameraId": "galpao_1_entrada",
  "cameraNome": "Galpão 1 - Entrada",
  "tipo": "pessoa_detectada",
  "inicio": "2026-09-27T15:32:10",
  "evento": "2026-09-27T15:42:10",
  "fim": "2026-09-27T15:52:10",
  "snapshotPath": "/security/events/evt_20260927_154210/snapshot.webp",
  "videoPath": "/security/events/evt_20260927_154210/evento.mp4",
  "confianca": 0.91,
  "status": "novo"
}
```

## Organização dos arquivos

```text
security/
  cameras/
    galpao_1_entrada/
      buffer/
        20260927_1532.mp4
        20260927_1533.mp4
  events/
    evt_20260927_154210/
      snapshot.webp
      evento.mp4
      metadata.json
```

## Telas recomendadas no app

### Câmeras

- Lista compacta de câmeras.
- Status online/offline.
- Último evento.
- Botão para abrir ao vivo.

### Ao vivo

- Player da câmera em tempo real.
- Nome do galpão.
- Status da conexão.
- Botão para tirar snapshot manual.
- Botão para iniciar gravação manual curta.

### Eventos

- Lista de eventos com snapshot.
- Filtro por câmera, galpão, data e tipo.
- Status: novo, visto, confirmado ou falso alerta.
- Abertura do vídeo do evento.

### Configurações

- Ativar/desativar monitoramento por câmera.
- Definir horário armado.
- Definir sensibilidade.
- Definir zonas proibidas.
- Definir retenção dos vídeos.

## Visualização em tempo real

Para o celular ver em tempo real, existem dois cenários:

### Dentro da rede da granja

O app pode acessar diretamente o stream local da câmera ou do processador local.

Exemplo:

```text
rtsp://usuario:senha@192.168.1.50:554/stream1
```

Em Flutter, o ideal é usar player compatível com RTSP/HLS. Para maior estabilidade no celular, o processador local pode converter RTSP para HLS/WebRTC.

### Fora da rede da granja

Para acessar de fora, existem três opções:

- VPN segura para entrar na rede da granja.
- Túnel seguro com autenticação.
- Serviço de relay/WebRTC.

Evite expor câmera IP diretamente na internet por porta aberta.

## Gravação do evento

Configuração recomendada:

- Buffer anterior: 10 minutos.
- Janela posterior: 10 minutos.
- Duração máxima final: 30 minutos.
- Formato: MP4/H.264.
- Snapshot: WebP ou JPG.
- Limpeza automática: apagar eventos antigos após 7, 15 ou 30 dias.

Se o evento durar menos, o vídeo pode ficar menor. Se houver evento contínuo, limite em 30 minutos e gere outro evento se necessário.

## Implementação local sugerida

O processador local pode rodar:

- FFmpeg para buffer e recorte dos vídeos.
- Python com OpenCV para detecção simples.
- YOLO leve para detectar pessoa/veículo.
- Serviço HTTP local para o app consultar câmeras e eventos.
- Firebase Admin ou endpoint seguro para disparar notificações.

Endpoints locais sugeridos:

```text
GET  /api/cameras
GET  /api/cameras/{id}/status
GET  /api/cameras/{id}/snapshot
GET  /api/cameras/{id}/live
GET  /api/events
GET  /api/events/{id}
GET  /api/events/{id}/snapshot
GET  /api/events/{id}/video
POST /api/cameras/{id}/arm
POST /api/cameras/{id}/disarm
POST /api/cameras/{id}/record
```

## Cuidados importantes

- Não salvar vídeo no banco local do app.
- Não depender do celular para gravar o evento.
- Não abrir portas das câmeras diretamente para internet.
- Proteger usuário/senha das câmeras.
- Usar rede separada ou VLAN para câmeras, se possível.
- Usar SSD para gravação frequente.
- Definir política de retenção para não encher o armazenamento.

## Próximos passos no app

1. Criar módulo `Segurança`.
2. Criar tela `Câmeras`.
3. Criar tela `Eventos`.
4. Criar tela `Ao vivo`.
5. Criar tela `Configurações de monitoramento`.
6. Adicionar notificações para evento anormal.
7. Integrar com serviço local da granja por HTTP/WebSocket/WebRTC.

