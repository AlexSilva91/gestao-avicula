#!/usr/bin/env bash
set -euo pipefail

REMOTE_HOST="${REMOTE_HOST:-131.221.236.34}"
REMOTE_USER="${REMOTE_USER:-ourinet}"
REMOTE="${REMOTE_USER}@${REMOTE_HOST}"
MQTT_PORT="${MQTT_PORT:-1883}"
MQTT_USER="${MQTT_USER:-seleto}"
MQTT_PASSWORD="${MQTT_PASSWORD:-}"
MQTT_BASE_TOPIC="${MQTT_BASE_TOPIC:-seleto/esp32}"
KEEP_MQTT_PASSWORD="${KEEP_MQTT_PASSWORD:-false}"
REMOTE_SUDO_PASSWORD="${REMOTE_SUDO_PASSWORD:-}"

if [[ -z "${MQTT_PASSWORD}" && "${KEEP_MQTT_PASSWORD}" != "true" ]]; then
  read -rsp "Senha MQTT para ${MQTT_USER} (vazio para manter a atual): " MQTT_PASSWORD
  echo
fi

echo "==> Atualizando Mosquitto MQTT em ${REMOTE}"
echo "==> Porta: ${MQTT_PORT} | Topico base: ${MQTT_BASE_TOPIC} | Usuario: ${MQTT_USER}"

MQTT_PASSWORD_B64="$(printf '%s' "${MQTT_PASSWORD}" | base64 -w 0)"
REMOTE_SUDO_PASSWORD_B64="$(printf '%s' "${REMOTE_SUDO_PASSWORD}" | base64 -w 0)"

ssh "${REMOTE}" "SUDO_PASSWORD_B64='${REMOTE_SUDO_PASSWORD_B64}' bash -s -- '${MQTT_USER}' '${MQTT_PASSWORD_B64}' '${MQTT_PORT}' '${MQTT_BASE_TOPIC}'" <<'REMOTE_SCRIPT'
set -euo pipefail

if [[ -n "${SUDO_PASSWORD_B64:-}" ]]; then
  SUDO_PASSWORD="$(printf '%s' "${SUDO_PASSWORD_B64}" | base64 -d)"
  exec sudo -S bash -s -- "$@" <<<"${SUDO_PASSWORD}
$(cat)"
fi

MQTT_USER="$1"
MQTT_PASSWORD="$(printf '%s' "$2" | base64 -d)"
MQTT_PORT="$3"
MQTT_BASE_TOPIC="$4"

if command -v apt-get >/dev/null 2>&1; then
  apt-get update
  apt-get install -y mosquitto mosquitto-clients
elif command -v dnf >/dev/null 2>&1; then
  dnf install -y mosquitto mosquitto-clients
elif command -v yum >/dev/null 2>&1; then
  yum install -y mosquitto mosquitto-clients
fi

install -d -m 0755 /etc/mosquitto/conf.d
install -d -m 0750 -o mosquitto -g mosquitto /etc/mosquitto

cat >/etc/mosquitto/conf.d/seleto.conf <<EOF
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
if [[ -n "${MQTT_PASSWORD}" ]]; then
  mosquitto_passwd -b /etc/mosquitto/passwd "${MQTT_USER}" "${MQTT_PASSWORD}"
elif [[ ! -s /etc/mosquitto/passwd ]]; then
  echo "Senha MQTT ausente e /etc/mosquitto/passwd ainda nao existe." >&2
  exit 1
fi
chown mosquitto:mosquitto /etc/mosquitto/passwd
chmod 0600 /etc/mosquitto/passwd

cat >/etc/mosquitto/seleto.acl <<EOF
user ${MQTT_USER}
topic readwrite ${MQTT_BASE_TOPIC}/+/status
topic readwrite ${MQTT_BASE_TOPIC}/+/sensors
topic readwrite ${MQTT_BASE_TOPIC}/+/relay/state
topic readwrite ${MQTT_BASE_TOPIC}/+/schedule/state
topic readwrite ${MQTT_BASE_TOPIC}/+/command/ack
topic readwrite ${MQTT_BASE_TOPIC}/+/schedule/ack
topic readwrite ${MQTT_BASE_TOPIC}/+/relay/command
topic readwrite ${MQTT_BASE_TOPIC}/+/schedule/command
topic readwrite ${MQTT_BASE_TOPIC}/+/ping
EOF
chown mosquitto:mosquitto /etc/mosquitto/seleto.acl
chmod 0640 /etc/mosquitto/seleto.acl

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

systemctl --no-pager --full status mosquitto || true
REMOTE_SCRIPT

echo
echo "MQTT atualizado."
echo "host=${REMOTE_HOST}"
echo "port=${MQTT_PORT}"
echo "baseTopic=${MQTT_BASE_TOPIC}"
echo "user=${MQTT_USER}"
