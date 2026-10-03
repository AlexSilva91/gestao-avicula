# Servidor de sincronizacao SELETO

O app nao usa mais Firebase para sincronizacao. O ponto remoto agora e:

```text
http://solveontecnology.com.br:5005
http://191.252.208.132:5005
```

O servidor escuta somente a porta `5005` e grava os dados em tabelas
PostgreSQL equivalentes ao banco local (`users`, `lots`, `egg_collections`,
`finance_transactions`, etc.). O banco padrao e `seleto`.

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
POST /sync/v1/health
POST /sync/v1/status
POST /sync/v1/pull
POST /sync/v1/push
POST /sync/v1/sync
POST /sync/v1/login
POST /sync/v1/presence
```

Todos os `POST` exigem:

```text
Authorization: Bearer <SELETO_SYNC_TOKEN>
```

`GET /health` e `POST /sync/v1/health` retornam estado do PostgreSQL, latencia,
uptime, total de usuarios, escopos sincronizados e usuarios online.

## Primeira sincronizacao

Na primeira sincronizacao do aparelho, o app envia `preferLocalOnFirstSync=true`.
Se houver dados locais, o servidor aceita o banco local como fonte inicial e
faz upsert linha a linha nas tabelas PostgreSQL. Para login em aparelho sem
usuario local, o app usa `/sync/v1/login` para baixar os dados do escopo do
usuario antes de validar a senha no banco local.

## Presenca online

O app envia `POST /sync/v1/presence` enquanto houver usuario logado. O heartbeat
padrao do app roda a cada `8` segundos e o servidor considera online quem enviou
presenca nos ultimos `25` segundos.

O servidor grava essa informacao em `seleto_user_presence` e tambem atualiza
`users.last_seen_at` quando recebe estado online. Ao sair, pausar ou fechar o
app, o cliente envia `state=offline` para remover o usuario da lista ativa com
o menor atraso possivel.

Teste manual:

```bash
curl -s http://solveontecnology.com.br:5005/sync/v1/presence \
  -H "Authorization: Bearer $SELETO_SYNC_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"userId":"<id-do-usuario>","tenantId":"tenant-default","state":"online"}'
```

## Testes rapidos

```bash
curl -s http://127.0.0.1:5005/health
curl -s http://solveontecnology.com.br:5005/health
```

```bash
curl -s http://solveontecnology.com.br:5005/sync/v1/health \
  -H "Authorization: Bearer $SELETO_SYNC_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{}'
```

```bash
curl -s http://solveontecnology.com.br:5005/sync/v1/status \
  -H "Authorization: Bearer $SELETO_SYNC_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"tenantId":"tenant-default","isSuperAdmin":false}'
```

## Atualizar VPS

Do seu computador, a partir da raiz do projeto:

```bash
scp scripts/seleto_sync_server.py scripts/install_seleto_sync_service.sh root@solveontecnology.com.br:/tmp/
ssh root@solveontecnology.com.br
```

No servidor:

```bash
mkdir -p /opt/seleto-sync
install -m 0755 /tmp/seleto_sync_server.py /opt/seleto-sync/seleto_sync_server.py
install -m 0755 /tmp/install_seleto_sync_service.sh /opt/seleto-sync/install_seleto_sync_service.sh
systemctl daemon-reload
systemctl restart seleto-sync
systemctl status -l --no-pager seleto-sync
curl -s http://127.0.0.1:5005/health
```

Se for reinstalar o service inteiro mantendo o token existente em
`/etc/seleto-sync.env`:

```bash
cd /opt/seleto-sync
set -a
. /etc/seleto-sync.env
set +a
SOURCE_SCRIPT=/opt/seleto-sync/seleto_sync_server.py \
POSTGRES_PASSWORD_VALUE="$POSTGRES_PASSWORD" \
SELETO_SYNC_TOKEN_VALUE="$SELETO_SYNC_TOKEN" \
./install_seleto_sync_service.sh
```

## Tabelas criadas

```text
tenants
users
user_permissions
audit_logs
lots
bird_movements
egg_collections
egg_stock_movements
ingredients
ingredient_price_history
ingredient_lots
ingredient_stock_movements
feed_formulas
feed_formula_items
feed_batches
feed_batch_items
feed_stock_movements
daily_feedings
feed_consumption_recommendations
customers
orders
order_items
order_status_history
packaging_items
packaging_lots
packaging_stock_movements
egg_tray_batches
egg_tray_stock_movements
sales
finance_transactions
investments
lighting_programs
lighting_program_steps
lot_lighting_programs
calendar_events
vaccination_records
notification_settings
app_settings
seleto_sync_scopes
seleto_sync_row_scopes
seleto_sync_events
seleto_user_presence
```

As tabelas de negocio guardam os dados reais do app. `seleto_sync_scopes` e
`seleto_sync_row_scopes` guardam apenas metadados de sincronizacao e isolamento
por escopo/tenant. `seleto_sync_events` mantem uma trilha simples de auditoria
das sincronizacoes. `seleto_user_presence` guarda o estado online em tempo quase
real.
