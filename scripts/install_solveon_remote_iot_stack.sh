#!/usr/bin/env bash
set -euo pipefail

# Instala e endurece a comunicacao remota SELETO na VPS Solveon:
# - Broker MQTT Mosquitto para APP <-> ESP32
# - Usuarios/senhas fortes e ACL por tipo de cliente
# - TLS via Let's Encrypt quando CERT_EMAIL for informado
# - Firewall liberando apenas as portas necessarias
# - Proxy HTTPS opcional para o servidor de sincronizacao atual

DOMAIN="${DOMAIN:-solveontecnology.com.br}"
MQTT_BASE_TOPIC="${MQTT_BASE_TOPIC:-seleto/esp32}"
MQTT_APP_USER="${MQTT_APP_USER:-seleto_app}"
MQTT_ESP_USER="${MQTT_ESP_USER:-seleto_esp}"
MQTT_APP_PASSWORD="${MQTT_APP_PASSWORD:-}"
MQTT_ESP_PASSWORD="${MQTT_ESP_PASSWORD:-}"
CERT_EMAIL="${CERT_EMAIL:-}"
ENABLE_PLAIN_MQTT="${ENABLE_PLAIN_MQTT:-false}"
ENABLE_SYNC_PROXY="${ENABLE_SYNC_PROXY:-true}"
SYNC_UPSTREAM="${SYNC_UPSTREAM:-http://127.0.0.1:5005}"
SYNC_PUBLIC_PATH="${SYNC_PUBLIC_PATH:-/sync/}"
HEALTH_PUBLIC_PATH="${HEALTH_PUBLIC_PATH:-/health}"
MOSQUITTO_CONF="/etc/mosquitto/conf.d/seleto.conf"
MOSQUITTO_ACL="/etc/mosquitto/seleto.acl"
MOSQUITTO_PASSWD="/etc/mosquitto/passwd"
MOSQUITTO_CERT_DIR="/etc/mosquitto/certs"
LE_CERT_DIR=""
NGINX_SITE="/etc/nginx/sites-available/seleto-sync"
NGINX_SITE_ENABLED="/etc/nginx/sites-enabled/seleto-sync"
SUMMARY_FILE="/root/seleto-remote-stack-credentials.txt"

if [[ "${EUID}" -ne 0 ]]; then
  echo "Execute como root: sudo $0"
  exit 1
fi

random_secret() {
  python3 - <<'PY'
import secrets
print(secrets.token_urlsafe(32))
PY
}

bool_enabled() {
  case "${1,,}" in
    1|true|yes|sim|on) return 0 ;;
    *) return 1 ;;
  esac
}

install_packages() {
  if command -v apt-get >/dev/null 2>&1; then
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y \
      ca-certificates \
      curl \
      fail2ban \
      mosquitto \
      mosquitto-clients \
      nginx \
      openssl \
      python3 \
      python3-certbot-nginx \
      ufw
  else
    echo "Este instalador foi preparado para VPS Debian/Ubuntu com apt-get."
    exit 1
  fi
}

backup_file() {
  local path="$1"
  if [[ -f "${path}" ]]; then
    cp -a "${path}" "${path}.bak.$(date +%Y%m%d%H%M%S)"
  fi
}

configure_firewall() {
  ufw allow OpenSSH
  ufw allow 80/tcp
  ufw allow 443/tcp
  if [[ -n "${CERT_EMAIL}" ]]; then
    ufw allow 8883/tcp
  fi
  if bool_enabled "${ENABLE_PLAIN_MQTT}"; then
    ufw allow 1883/tcp
  else
    ufw delete allow 1883/tcp >/dev/null 2>&1 || true
  fi
  if bool_enabled "${ENABLE_SYNC_PROXY}"; then
    ufw delete allow 5005/tcp >/dev/null 2>&1 || true
  fi
  ufw --force enable
}

issue_certificate() {
  if [[ -z "${CERT_EMAIL}" ]]; then
    return
  fi

  LE_CERT_DIR="$(find /etc/letsencrypt/live -maxdepth 1 -type d \( -name "${DOMAIN}" -o -name "${DOMAIN}-*" \) | sort | tail -n 1)"
  if [[ -z "${LE_CERT_DIR}" || ! -f "${LE_CERT_DIR}/privkey.pem" ]]; then
    systemctl stop nginx >/dev/null 2>&1 || true
    certbot certonly --standalone \
      --non-interactive \
      --agree-tos \
      --email "${CERT_EMAIL}" \
      -d "${DOMAIN}"
    LE_CERT_DIR="$(find /etc/letsencrypt/live -maxdepth 1 -type d \( -name "${DOMAIN}" -o -name "${DOMAIN}-*" \) | sort | tail -n 1)"
  fi
  if [[ -z "${LE_CERT_DIR}" || ! -f "${LE_CERT_DIR}/privkey.pem" ]]; then
    echo "Certificado Let's Encrypt nao encontrado para ${DOMAIN}."
    exit 1
  fi

  install -d -m 0750 -o root -g mosquitto "${MOSQUITTO_CERT_DIR}"
  install -m 0644 -o root -g mosquitto "${LE_CERT_DIR}/chain.pem" "${MOSQUITTO_CERT_DIR}/chain.pem"
  install -m 0644 -o root -g mosquitto "${LE_CERT_DIR}/cert.pem" "${MOSQUITTO_CERT_DIR}/cert.pem"
  install -m 0640 -o root -g mosquitto "${LE_CERT_DIR}/privkey.pem" "${MOSQUITTO_CERT_DIR}/privkey.pem"

  install -d -m 0755 /etc/letsencrypt/renewal-hooks/deploy
  cat >/etc/letsencrypt/renewal-hooks/deploy/seleto-mosquitto-certs.sh <<EOF
#!/usr/bin/env bash
set -euo pipefail
install -d -m 0750 -o root -g mosquitto "${MOSQUITTO_CERT_DIR}"
LE_CERT_DIR="\$(find /etc/letsencrypt/live -maxdepth 1 -type d \\( -name "${DOMAIN}" -o -name "${DOMAIN}-*" \\) | sort | tail -n 1)"
install -m 0644 -o root -g mosquitto "\${LE_CERT_DIR}/chain.pem" "${MOSQUITTO_CERT_DIR}/chain.pem"
install -m 0644 -o root -g mosquitto "\${LE_CERT_DIR}/cert.pem" "${MOSQUITTO_CERT_DIR}/cert.pem"
install -m 0640 -o root -g mosquitto "\${LE_CERT_DIR}/privkey.pem" "${MOSQUITTO_CERT_DIR}/privkey.pem"
systemctl reload mosquitto >/dev/null 2>&1 || systemctl restart mosquitto
EOF
  chmod 0755 /etc/letsencrypt/renewal-hooks/deploy/seleto-mosquitto-certs.sh
}

configure_mosquitto() {
  MQTT_APP_PASSWORD="${MQTT_APP_PASSWORD:-$(random_secret)}"
  MQTT_ESP_PASSWORD="${MQTT_ESP_PASSWORD:-$(random_secret)}"

  install -d -m 0750 -o mosquitto -g mosquitto /etc/mosquitto
  touch "${MOSQUITTO_PASSWD}"
  chown mosquitto:mosquitto "${MOSQUITTO_PASSWD}"
  chmod 0700 "${MOSQUITTO_PASSWD}"

  mosquitto_passwd -b "${MOSQUITTO_PASSWD}" "${MQTT_APP_USER}" "${MQTT_APP_PASSWORD}"
  mosquitto_passwd -b "${MOSQUITTO_PASSWD}" "${MQTT_ESP_USER}" "${MQTT_ESP_PASSWORD}"
  chown mosquitto:mosquitto "${MOSQUITTO_PASSWD}"
  chmod 0700 "${MOSQUITTO_PASSWD}"

  backup_file "${MOSQUITTO_ACL}"
  cat >"${MOSQUITTO_ACL}" <<EOF
user ${MQTT_APP_USER}
topic read ${MQTT_BASE_TOPIC}/+/status
topic read ${MQTT_BASE_TOPIC}/+/sensors
topic read ${MQTT_BASE_TOPIC}/+/relay/state
topic write ${MQTT_BASE_TOPIC}/+/relay/command

user ${MQTT_ESP_USER}
topic write ${MQTT_BASE_TOPIC}/+/status
topic write ${MQTT_BASE_TOPIC}/+/sensors
topic write ${MQTT_BASE_TOPIC}/+/relay/state
topic read ${MQTT_BASE_TOPIC}/+/relay/command
EOF
  chown mosquitto:mosquitto "${MOSQUITTO_ACL}"
  chmod 0640 "${MOSQUITTO_ACL}"

  backup_file "${MOSQUITTO_CONF}"
  {
    cat <<EOF
per_listener_settings false
allow_anonymous false
password_file ${MOSQUITTO_PASSWD}
acl_file ${MOSQUITTO_ACL}
autosave_interval 60
max_inflight_messages 20
max_queued_messages 200
max_packet_size 1048576
log_dest syslog
log_type error
log_type warning
log_type notice
connection_messages true
EOF
    if [[ -n "${CERT_EMAIL}" ]]; then
      cat <<EOF

listener 8883 0.0.0.0
cafile ${MOSQUITTO_CERT_DIR}/chain.pem
certfile ${MOSQUITTO_CERT_DIR}/cert.pem
keyfile ${MOSQUITTO_CERT_DIR}/privkey.pem
tls_version tlsv1.2
EOF
    fi
    if bool_enabled "${ENABLE_PLAIN_MQTT}"; then
      cat <<EOF

listener 1883 0.0.0.0
EOF
    else
      cat <<EOF

listener 1883 127.0.0.1
EOF
    fi
  } >"${MOSQUITTO_CONF}"
  chown root:root "${MOSQUITTO_CONF}"
  chmod 0644 "${MOSQUITTO_CONF}"

  systemctl enable mosquitto
  systemctl restart mosquitto
}

configure_fail2ban() {
  cat >/etc/fail2ban/filter.d/mosquitto-seleto.conf <<'EOF'
[Definition]
failregex = ^.*mosquitto.*(Socket error on client|Client <HOST> disconnected, not authorised|bad username or password).*
ignoreregex =
EOF

  cat >/etc/fail2ban/jail.d/mosquitto-seleto.conf <<'EOF'
[mosquitto-seleto]
enabled = true
filter = mosquitto-seleto
backend = systemd
journalmatch = _SYSTEMD_UNIT=mosquitto.service
maxretry = 6
findtime = 600
bantime = 3600
EOF

  systemctl enable fail2ban
  systemctl restart fail2ban
}

configure_sync_proxy() {
  if ! bool_enabled "${ENABLE_SYNC_PROXY}"; then
    return
  fi

  backup_file "${NGINX_SITE}"
  cat >"${NGINX_SITE}" <<EOF
server {
    listen 80;
    server_name ${DOMAIN};

    client_max_body_size 64m;

    location ${HEALTH_PUBLIC_PATH} {
        proxy_pass ${SYNC_UPSTREAM}${HEALTH_PUBLIC_PATH};
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    location ${SYNC_PUBLIC_PATH} {
        limit_except POST OPTIONS { deny all; }
        proxy_pass ${SYNC_UPSTREAM}${SYNC_PUBLIC_PATH};
        proxy_http_version 1.1;
        proxy_read_timeout 35s;
        proxy_send_timeout 35s;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF
  ln -sf "${NGINX_SITE}" "${NGINX_SITE_ENABLED}"
  nginx -t
  systemctl enable nginx
  systemctl restart nginx

  if [[ -n "${CERT_EMAIL}" ]]; then
    certbot --nginx \
      --non-interactive \
      --agree-tos \
      --email "${CERT_EMAIL}" \
      -d "${DOMAIN}" \
      --redirect
    nginx -t
    systemctl reload nginx
  fi
}

write_summary() {
  local mqtt_port="1883"
  local mqtt_scheme="mqtt"
  if [[ -n "${CERT_EMAIL}" ]]; then
    mqtt_port="8883"
    mqtt_scheme="mqtts"
  fi

  cat >"${SUMMARY_FILE}" <<EOF
SELETO REMOTE STACK - ${DOMAIN}
Gerado em: $(date -Is)

MQTT recomendado para o app:
  Broker: ${DOMAIN}
  Porta: ${mqtt_port}
  TLS: $([[ -n "${CERT_EMAIL}" ]] && echo "sim" || echo "nao")
  Topico base: ${MQTT_BASE_TOPIC}
  Device ID exemplo: SELETO-RELE-01
  Usuario APP: ${MQTT_APP_USER}
  Senha APP: ${MQTT_APP_PASSWORD}

MQTT recomendado para o ESP32:
  Broker: ${DOMAIN}
  Porta: ${mqtt_port}
  TLS: $([[ -n "${CERT_EMAIL}" ]] && echo "sim" || echo "nao")
  Topico base: ${MQTT_BASE_TOPIC}
  Usuario ESP: ${MQTT_ESP_USER}
  Senha ESP: ${MQTT_ESP_PASSWORD}

Teste MQTT local na VPS:
  mosquitto_sub -h 127.0.0.1 -p 1883 -u ${MQTT_APP_USER} -P '${MQTT_APP_PASSWORD}' -t '${MQTT_BASE_TOPIC}/+/status' -v

Teste MQTT remoto:
  mosquitto_sub -h ${DOMAIN} -p ${mqtt_port} $([[ -n "${CERT_EMAIL}" ]] && echo "--cafile /etc/letsencrypt/live/${DOMAIN}/chain.pem") -u ${MQTT_APP_USER} -P '${MQTT_APP_PASSWORD}' -t '${MQTT_BASE_TOPIC}/+/status' -v

Sync HTTP:
  Proxy HTTPS: ${ENABLE_SYNC_PROXY}
  URL recomendada no app: $([[ -n "${CERT_EMAIL}" && "${ENABLE_SYNC_PROXY,,}" =~ ^(1|true|yes|sim|on)$ ]] && echo "https://${DOMAIN}" || echo "http://${DOMAIN}:5005")
EOF
  chmod 0600 "${SUMMARY_FILE}"
}

main() {
  install_packages
  configure_firewall
  issue_certificate
  configure_mosquitto
  configure_fail2ban
  configure_sync_proxy
  write_summary

  echo
  echo "OK: stack remoto SELETO configurado."
  echo "Credenciais salvas em ${SUMMARY_FILE} com permissao 600."
  echo
  cat "${SUMMARY_FILE}"
}

main "$@"
