# Servidor de sincronizacao SELETO

O app nao usa mais Firebase para sincronizacao. O ponto remoto agora e:

```text
http://solveontecnology.com.br:5005
http://191.252.208.132:5005
```

O servidor escuta somente a porta `5005` e grava snapshots JSONB no PostgreSQL.
O banco padrao e `seleto`.

## Instalacao automatica

Na VPS, copie o repositorio ou pelo menos estes arquivos:

```text
scripts/seleto_sync_server.py
scripts/install_seleto_sync_service.sh
```

Depois execute a partir da raiz do projeto:

```bash
sudo scripts/install_seleto_sync_service.sh
```

O instalador:

- instala Python/venv/pip quando possivel;
- cria `/opt/seleto-sync`;
- cria `/etc/seleto-sync.env` com permissao `600`;
- instala `psycopg[binary]`;
- cria e inicia o `systemd` service `seleto-sync`;
- libera `TCP/5005` em `ufw`, `firewalld` ou `iptables`.

Variaveis aceitas antes da execucao:

```bash
sudo POSTGRES_PASSWORD_VALUE='sua-senha' \
  SELETO_SYNC_TOKEN_VALUE='token-grande' \
  scripts/install_seleto_sync_service.sh
```

Se `SELETO_SYNC_TOKEN_VALUE` nao for informado, o instalador gera um token e
mostra no final. Use esse mesmo token no build do app.

## Configuracao do app

Build exemplo:

```bash
flutter build apk \
  --dart-define=SELETO_SYNC_BASE_URL=http://solveontecnology.com.br:5005 \
  --dart-define=SELETO_SYNC_TOKEN=<token-gerado-no-servidor>
```

Sem `SELETO_SYNC_BASE_URL`, o app usa `http://solveontecnology.com.br:5005`.

## Endpoints

```text
GET  /health
POST /sync/v1/status
POST /sync/v1/pull
POST /sync/v1/push
POST /sync/v1/sync
POST /sync/v1/login
```

Todos os `POST` exigem:

```text
Authorization: Bearer <SELETO_SYNC_TOKEN>
```

## Primeira sincronizacao

Na primeira sincronizacao do aparelho, o app envia `preferLocalOnFirstSync=true`.
Se houver dados locais, o servidor aceita o banco local como fonte inicial e
sobrescreve o snapshot remoto daquele escopo. Para login em aparelho sem usuario
local, o app usa `/sync/v1/login` para baixar o snapshot do usuario antes de
validar a senha no banco local.

## Testes rapidos

```bash
curl -s http://127.0.0.1:5005/health
curl -s http://solveontecnology.com.br:5005/health
```

```bash
curl -s http://solveontecnology.com.br:5005/sync/v1/status \
  -H "Authorization: Bearer $SELETO_SYNC_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"tenantId":"tenant-default","isSuperAdmin":false}'
```

## Tabelas criadas

```text
seleto_sync_snapshots
seleto_sync_events
```

`seleto_sync_snapshots` guarda o payload atual por escopo. `seleto_sync_events`
mantem uma trilha simples de auditoria das sincronizacoes.
