#!/usr/bin/env bash
set -euo pipefail

REMOTE_HOST="${REMOTE_HOST:-131.221.236.34}"
REMOTE_USER="${REMOTE_USER:-root}"
REMOTE="${REMOTE_USER}@${REMOTE_HOST}"
REMOTE_TMP="${REMOTE_TMP:-/tmp/seleto-deploy}"
SYNC_PORT="${SELETO_SYNC_PORT:-5005}"
MQTT_PORT="${MQTT_PORT:-1883}"
MQTT_USER="${MQTT_USER:-seleto}"
MQTT_PASSWORD="${MQTT_PASSWORD:-}"
MQTT_BASE_TOPIC="${MQTT_BASE_TOPIC:-seleto/esp32}"
SYNC_TOKEN="${SELETO_SYNC_TOKEN:-}"
POSTGRES_DB="${POSTGRES_DB:-seleto}"
POSTGRES_USER="${POSTGRES_USER:-agrogestor}"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-}"
POSTGRES_HOST="${POSTGRES_HOST:-127.0.0.1}"
TLS_DOMAIN="${TLS_DOMAIN:-}"

prompt_required_secret() {
  local prompt="$1"
  local value=""
  while [[ -z "${value}" ]]; do
    read -rsp "${prompt}" value
    echo
    if [[ -z "${value}" ]]; then
      echo "Valor obrigatorio. Informe uma senha."
    fi
  done
  printf '%s' "${value}"
}

if [[ -z "${POSTGRES_PASSWORD}" ]]; then
  POSTGRES_PASSWORD="$(prompt_required_secret "Senha PostgreSQL (${POSTGRES_DB}/${POSTGRES_USER}@${POSTGRES_HOST}): ")"
fi

if [[ -z "${SYNC_TOKEN}" ]]; then
  SYNC_TOKEN="$(openssl rand -base64 32 | tr -d '\n')"
fi

if [[ -z "${MQTT_PASSWORD}" ]]; then
  MQTT_PASSWORD="$(openssl rand -base64 24 | tr -d '\n')"
fi

echo "==> Enviando artefatos para ${REMOTE}"
ssh "${REMOTE}" "mkdir -p '${REMOTE_TMP}'"
scp \
  scripts/seleto_sync_server.py \
  scripts/install_seleto_sync_service.sh \
  "${REMOTE}:${REMOTE_TMP}/"

echo "==> Instalando servidor SELETO Sync em ${REMOTE_HOST}:${SYNC_PORT}"
ssh "${REMOTE}" "\
  chmod +x '${REMOTE_TMP}/install_seleto_sync_service.sh' && \
  SERVICE_NAME='seleto-sync' \
  SOURCE_SCRIPT='${REMOTE_TMP}/seleto_sync_server.py' \
  SELETO_SYNC_PORT='${SYNC_PORT}' \
  SELETO_SYNC_TOKEN_VALUE='${SYNC_TOKEN}' \
  SELETO_SYNC_REQUIRE_SIGNATURE_VALUE='true' \
  POSTGRES_DB_VALUE='${POSTGRES_DB}' \
  POSTGRES_USER_VALUE='${POSTGRES_USER}' \
  POSTGRES_PASSWORD_VALUE='${POSTGRES_PASSWORD}' \
  POSTGRES_HOST_VALUE='${POSTGRES_HOST}' \
  '${REMOTE_TMP}/install_seleto_sync_service.sh'"

echo "==> Instalando/configurando Mosquitto MQTT"
ssh "${REMOTE}" bash -s -- "${MQTT_USER}" "${MQTT_PASSWORD}" "${MQTT_PORT}" "${MQTT_BASE_TOPIC}" <<'REMOTE_SCRIPT'
set -euo pipefail
MQTT_USER="$1"
MQTT_PASSWORD="$2"
MQTT_PORT="$3"
MQTT_BASE_TOPIC="$4"

if command -v apt-get >/dev/null 2>&1; then
  apt-get update
  apt-get install -y mosquitto mosquitto-clients
elif command -v dnf >/dev/null 2>&1; then
  dnf install -y mosquitto mosquitto-clients
elif command -v yum >/dev/null 2>&1; then
  yum install -y mosquitto mosquitto-clients
else
  echo "Instale mosquitto manualmente neste servidor."
  exit 1
fi

install -d -m 0755 /etc/mosquitto/conf.d
install -d -m 0750 -o mosquitto -g mosquitto /etc/mosquitto
cat > /etc/mosquitto/conf.d/seleto.conf <<EOF
listener ${MQTT_PORT} 0.0.0.0
allow_anonymous false
password_file /etc/mosquitto/passwd
acl_file /etc/mosquitto/seleto.acl
persistence true
persistence_location /var/lib/mosquitto/
log_dest syslog
log_type error
log_type warning
log_type notice
EOF

touch /etc/mosquitto/passwd
mosquitto_passwd -b /etc/mosquitto/passwd "${MQTT_USER}" "${MQTT_PASSWORD}"
chmod 600 /etc/mosquitto/passwd
chown mosquitto:mosquitto /etc/mosquitto/passwd

cat > /etc/mosquitto/seleto.acl <<EOF
user ${MQTT_USER}
topic readwrite ${MQTT_BASE_TOPIC}/+/status
topic readwrite ${MQTT_BASE_TOPIC}/+/sensors
topic readwrite ${MQTT_BASE_TOPIC}/+/relay/state
topic readwrite ${MQTT_BASE_TOPIC}/+/schedule/state
topic readwrite ${MQTT_BASE_TOPIC}/+/wifi/scan/state
topic readwrite ${MQTT_BASE_TOPIC}/+/command/ack
topic readwrite ${MQTT_BASE_TOPIC}/+/schedule/ack
topic readwrite ${MQTT_BASE_TOPIC}/+/relay/command
topic readwrite ${MQTT_BASE_TOPIC}/+/schedule/command
topic readwrite ${MQTT_BASE_TOPIC}/+/wifi/scan/command
topic readwrite ${MQTT_BASE_TOPIC}/+/ping
EOF
chown mosquitto:mosquitto /etc/mosquitto/seleto.acl
chmod 640 /etc/mosquitto/seleto.acl

if command -v ufw >/dev/null 2>&1; then
  ufw allow "${MQTT_PORT}/tcp"
elif command -v firewall-cmd >/dev/null 2>&1; then
  firewall-cmd --permanent --add-port="${MQTT_PORT}/tcp"
  firewall-cmd --reload
fi

systemctl enable mosquitto
if systemctl is-active --quiet mosquitto; then
  systemctl reload mosquitto || systemctl kill -s HUP mosquitto
else
  systemctl start mosquitto
fi
systemctl --no-pager status mosquitto || true
REMOTE_SCRIPT

if [[ -n "${TLS_DOMAIN}" ]]; then
  echo "==> Configurando HTTPS com Caddy para ${TLS_DOMAIN}"
  ssh "${REMOTE}" bash -s -- "${TLS_DOMAIN}" "${SYNC_PORT}" <<'REMOTE_TLS'
set -euo pipefail
TLS_DOMAIN="$1"
SYNC_PORT="$2"

if command -v apt-get >/dev/null 2>&1; then
  apt-get install -y debian-keyring debian-archive-keyring apt-transport-https curl
  curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' |
    gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
  curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' |
    tee /etc/apt/sources.list.d/caddy-stable.list
  apt-get update
  apt-get install -y caddy
else
  echo "Instale Caddy manualmente para TLS automatico."
  exit 1
fi

cat > /etc/caddy/Caddyfile <<EOF
${TLS_DOMAIN} {
  encode gzip
  reverse_proxy 127.0.0.1:${SYNC_PORT}
}
EOF

if command -v ufw >/dev/null 2>&1; then
  ufw allow 80/tcp
  ufw allow 443/tcp
fi

systemctl enable --now caddy
systemctl reload caddy
REMOTE_TLS
fi

echo
echo "Deploy concluido."
echo "Servidor Sync:"
if [[ -n "${TLS_DOMAIN}" ]]; then
  echo "  https://${TLS_DOMAIN}"
else
  echo "  http://${REMOTE_HOST}:${SYNC_PORT}"
fi
echo "Token Sync:"
echo "  ${SYNC_TOKEN}"
echo "MQTT:"
echo "  host=${REMOTE_HOST}"
echo "  port=${MQTT_PORT}"
echo "  baseTopic=${MQTT_BASE_TOPIC}"
echo "  user=${MQTT_USER}"
echo "  password=${MQTT_PASSWORD}"
