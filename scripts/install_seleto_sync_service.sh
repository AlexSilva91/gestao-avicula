#!/usr/bin/env bash
set -euo pipefail

SERVICE_NAME="${SERVICE_NAME:-seleto-sync}"
INSTALL_DIR="${INSTALL_DIR:-/opt/seleto-sync}"
ENV_FILE="${ENV_FILE:-/etc/seleto-sync.env}"
APP_USER="${APP_USER:-seleto-sync}"
APP_GROUP="${APP_GROUP:-seleto-sync}"
PORT="${SELETO_SYNC_PORT:-5005}"
SOURCE_SCRIPT="${SOURCE_SCRIPT:-scripts/seleto_sync_server.py}"

POSTGRES_DB_VALUE="${POSTGRES_DB_VALUE:-seleto}"
POSTGRES_USER_VALUE="${POSTGRES_USER_VALUE:-agrogestor}"
POSTGRES_HOST_VALUE="${POSTGRES_HOST_VALUE:-127.0.0.1}"
POSTGRES_PORT_VALUE="${POSTGRES_PORT_VALUE:-5432}"
POSTGRES_SSLMODE_VALUE="${POSTGRES_SSLMODE_VALUE:-prefer}"
POSTGRES_CONN_MAX_AGE_VALUE="${POSTGRES_CONN_MAX_AGE_VALUE:-600}"
POSTGRES_PASSWORD_VALUE="${POSTGRES_PASSWORD_VALUE:-}"
SELETO_SYNC_TOKEN_VALUE="${SELETO_SYNC_TOKEN_VALUE:-}"
SELETO_SYNC_PRESENCE_ONLINE_SECONDS_VALUE="${SELETO_SYNC_PRESENCE_ONLINE_SECONDS_VALUE:-25}"

if [[ "${EUID}" -ne 0 ]]; then
  echo "Execute como root: sudo $0"
  exit 1
fi

if [[ ! -f "${SOURCE_SCRIPT}" ]]; then
  echo "Arquivo nao encontrado: ${SOURCE_SCRIPT}"
  echo "Execute este script a partir da raiz do projeto ou defina SOURCE_SCRIPT."
  exit 1
fi

if [[ -z "${POSTGRES_PASSWORD_VALUE}" ]]; then
  read -rsp "Senha do PostgreSQL para ${POSTGRES_USER_VALUE}: " POSTGRES_PASSWORD_VALUE
  echo
fi

if [[ -z "${SELETO_SYNC_TOKEN_VALUE}" ]]; then
  SELETO_SYNC_TOKEN_VALUE="$(python3 - <<'PY'
import secrets
print(secrets.token_urlsafe(32))
PY
)"
fi

install_packages() {
  if command -v apt-get >/dev/null 2>&1; then
    apt-get update
    apt-get install -y python3 python3-venv python3-pip
  elif command -v dnf >/dev/null 2>&1; then
    dnf install -y python3 python3-pip
  elif command -v yum >/dev/null 2>&1; then
    yum install -y python3 python3-pip
  else
    echo "Gerenciador de pacotes nao detectado. Instale python3, venv e pip manualmente."
  fi
}

configure_firewall() {
  if command -v ufw >/dev/null 2>&1; then
    ufw allow "${PORT}/tcp"
    ufw --force enable
    return
  fi
  if command -v firewall-cmd >/dev/null 2>&1; then
    firewall-cmd --permanent --add-port="${PORT}/tcp"
    firewall-cmd --reload
    return
  fi
  if command -v iptables >/dev/null 2>&1; then
    iptables -C INPUT -p tcp --dport "${PORT}" -j ACCEPT 2>/dev/null ||
      iptables -A INPUT -p tcp --dport "${PORT}" -j ACCEPT
    return
  fi
  echo "Firewall nao detectado. Libere manualmente TCP/${PORT}."
}

env_quote() {
  local value="${1//\\/\\\\}"
  value="${value//\"/\\\"}"
  printf '"%s"' "${value}"
}

install_packages

if ! getent group "${APP_GROUP}" >/dev/null; then
  groupadd --system "${APP_GROUP}"
fi
if ! id "${APP_USER}" >/dev/null 2>&1; then
  useradd --system --gid "${APP_GROUP}" --home-dir "${INSTALL_DIR}" --shell /usr/sbin/nologin "${APP_USER}"
fi

install -d -o "${APP_USER}" -g "${APP_GROUP}" -m 0755 "${INSTALL_DIR}"
install -o "${APP_USER}" -g "${APP_GROUP}" -m 0755 "${SOURCE_SCRIPT}" "${INSTALL_DIR}/seleto_sync_server.py"

python3 -m venv "${INSTALL_DIR}/.venv"
"${INSTALL_DIR}/.venv/bin/python" -m pip install --upgrade pip
"${INSTALL_DIR}/.venv/bin/python" -m pip install "psycopg[binary]"
chown -R "${APP_USER}:${APP_GROUP}" "${INSTALL_DIR}"

cat > "${ENV_FILE}" <<EOF
SELETO_SYNC_HOST=$(env_quote "0.0.0.0")
SELETO_SYNC_TOKEN=$(env_quote "${SELETO_SYNC_TOKEN_VALUE}")
SELETO_SYNC_MAX_BODY_BYTES=$(env_quote "67108864")
SELETO_SYNC_TIMEOUT_SECONDS=$(env_quote "30")
SELETO_SYNC_PRESENCE_ONLINE_SECONDS=$(env_quote "${SELETO_SYNC_PRESENCE_ONLINE_SECONDS_VALUE}")
POSTGRES_DB=$(env_quote "${POSTGRES_DB_VALUE}")
POSTGRES_USER=$(env_quote "${POSTGRES_USER_VALUE}")
POSTGRES_PASSWORD=$(env_quote "${POSTGRES_PASSWORD_VALUE}")
POSTGRES_HOST=$(env_quote "${POSTGRES_HOST_VALUE}")
POSTGRES_PORT=$(env_quote "${POSTGRES_PORT_VALUE}")
POSTGRES_SSLMODE=$(env_quote "${POSTGRES_SSLMODE_VALUE}")
POSTGRES_CONN_MAX_AGE=$(env_quote "${POSTGRES_CONN_MAX_AGE_VALUE}")
EOF
chown root:root "${ENV_FILE}"
chmod 600 "${ENV_FILE}"

cat > "/etc/systemd/system/${SERVICE_NAME}.service" <<EOF
[Unit]
Description=SELETO Sync Server
After=network-online.target postgresql.service
Wants=network-online.target

[Service]
Type=simple
User=${APP_USER}
Group=${APP_GROUP}
WorkingDirectory=${INSTALL_DIR}
EnvironmentFile=${ENV_FILE}
ExecStart=${INSTALL_DIR}/.venv/bin/python ${INSTALL_DIR}/seleto_sync_server.py
Restart=always
RestartSec=5
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=full
ProtectHome=true

[Install]
WantedBy=multi-user.target
EOF

configure_firewall

systemctl daemon-reload
systemctl enable --now "${SERVICE_NAME}"
systemctl --no-pager status "${SERVICE_NAME}" || true

echo
echo "Servico instalado: ${SERVICE_NAME}"
echo "Endpoint: http://solveontecnology.com.br:${PORT}"
echo "Token do app:"
echo "${SELETO_SYNC_TOKEN_VALUE}"
echo
echo "Build Flutter sugerido:"
echo "flutter build apk --dart-define=SELETO_SYNC_BASE_URL=http://solveontecnology.com.br:${PORT} --dart-define=SELETO_SYNC_TOKEN=${SELETO_SYNC_TOKEN_VALUE}"
