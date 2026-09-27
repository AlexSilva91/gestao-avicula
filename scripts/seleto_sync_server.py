#!/usr/bin/env python3
"""
Servidor de sincronizacao SELETO.

Endpoints principais:
  GET  /health
  POST /sync/v1/pull
  POST /sync/v1/push
  POST /sync/v1/sync

O processo escuta somente a porta 5005. As credenciais do PostgreSQL e o token
HTTP devem vir de variaveis de ambiente.
"""

from __future__ import annotations

import hashlib
import json
import os
import signal
import sys
import time
import traceback
from datetime import datetime, timezone
from http import HTTPStatus
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from typing import Any
from urllib.parse import parse_qs, urlparse


HOST = os.environ.get("SELETO_SYNC_HOST", "0.0.0.0")
PORT = 5005
MAX_BODY_BYTES = int(os.environ.get("SELETO_SYNC_MAX_BODY_BYTES", "67108864"))
REQUEST_TIMEOUT_SECONDS = int(os.environ.get("SELETO_SYNC_TIMEOUT_SECONDS", "30"))
DEFAULT_TENANT_ID = "tenant-default"
SYNC_TOKEN = os.environ.get("SELETO_SYNC_TOKEN", "").strip()
ALLOW_NO_TOKEN = os.environ.get("SELETO_SYNC_ALLOW_NO_TOKEN", "").lower() in {
    "1",
    "true",
    "yes",
}

SYNC_TABLES = {
    "tenants": "id",
    "users": "id",
    "userPermissions": "id",
    "auditLogs": "id",
    "lots": "id",
    "birdMovements": "id",
    "eggCollections": "id",
    "eggStockMovements": "id",
    "ingredients": "id",
    "prices": "id",
    "ingredientLots": "id",
    "ingredientStockMovements": "id",
    "formulas": "id",
    "formulaItems": "id",
    "feedBatches": "id",
    "feedBatchItems": "id",
    "feedStock": "id",
    "feedings": "id",
    "feedRecommendations": "id",
    "customers": "id",
    "orders": "id",
    "orderItems": "id",
    "orderStatusHistory": "id",
    "packagingItems": "id",
    "packagingLots": "id",
    "packagingStockMovements": "id",
    "eggTrayBatches": "id",
    "eggTrayStockMovements": "id",
    "sales": "id",
    "finance": "id",
    "investments": "id",
    "lightingPrograms": "id",
    "lightingSteps": "id",
    "lotLighting": "id",
    "calendarEvents": "id",
    "notificationSettings": "id",
    "appSettings": "key",
}

LOCAL_AUTHORITATIVE_ON_MERGE = {
    "ingredients",
    "prices",
    "ingredientLots",
    "ingredientStockMovements",
    "formulas",
    "formulaItems",
}

TIMESTAMP_KEYS = [
    "updatedAt",
    "createdAt",
    "timestamp",
    "occurredAt",
    "collectedOn",
    "effectiveDate",
    "entryDate",
    "validFrom",
    "producedAt",
    "feedingDate",
    "requestedDate",
    "purchasedAt",
    "assembledAt",
    "soldAt",
    "investmentDate",
    "startsAt",
    "assignedAt",
    "changedAt",
]


SCHEMA_SQL = """
create table if not exists seleto_sync_snapshots (
  scope_key text primary key,
  tenant_id text not null,
  user_id text,
  is_super_admin boolean not null default false,
  payload jsonb not null,
  payload_hash text not null,
  revision bigint not null default 1,
  updated_at timestamptz not null default now(),
  updated_by_device text,
  reason text
);

create table if not exists seleto_sync_events (
  id bigserial primary key,
  scope_key text not null,
  device_id text,
  user_id text,
  status text not null,
  local_hash text,
  remote_hash_before text,
  remote_hash_after text,
  revision bigint,
  reason text,
  created_at timestamptz not null default now()
);

create index if not exists idx_seleto_sync_events_scope_created
  on seleto_sync_events (scope_key, created_at desc);
"""


class Database:
    def __init__(self) -> None:
        self.driver = ""
        self._dict_row = None
        self._real_dict_cursor = None
        try:
            import psycopg
            from psycopg.rows import dict_row

            self.driver = "psycopg"
            self._connect_impl = psycopg.connect
            self._dict_row = dict_row
        except ImportError:
            try:
                import psycopg2
                import psycopg2.extras

                self.driver = "psycopg2"
                self._connect_impl = psycopg2.connect
                self._real_dict_cursor = psycopg2.extras.RealDictCursor
            except ImportError as exc:
                raise RuntimeError(
                    "Instale o driver PostgreSQL: pip install 'psycopg[binary]'"
                ) from exc

    def connect(self):
        kwargs = {
            "dbname": os.environ.get("POSTGRES_DB", "seleto"),
            "user": os.environ.get("POSTGRES_USER", "agrogestor"),
            "password": os.environ.get("POSTGRES_PASSWORD", ""),
            "host": os.environ.get("POSTGRES_HOST", "127.0.0.1"),
            "port": int(os.environ.get("POSTGRES_PORT", "5432")),
            "sslmode": os.environ.get("POSTGRES_SSLMODE", "prefer"),
            "connect_timeout": REQUEST_TIMEOUT_SECONDS,
        }
        if self.driver == "psycopg":
            return self._connect_impl(**kwargs, row_factory=self._dict_row)
        return self._connect_impl(**kwargs, cursor_factory=self._real_dict_cursor)

    def initialize(self) -> None:
        with self.connect() as conn:
            with conn.cursor() as cur:
                for statement in SCHEMA_SQL.split(";"):
                    statement = statement.strip()
                    if statement:
                        cur.execute(statement)
            conn.commit()


DB: Database | None = None


def get_db() -> Database:
    global DB
    if DB is None:
        DB = Database()
    return DB


def utc_now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


def canonical_json(value: Any) -> str:
    return json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":"))


def payload_hash(payload: dict[str, Any]) -> str:
    return hashlib.sha256(canonical_json(payload).encode("utf-8")).hexdigest()


def rows(payload: dict[str, Any], key: str) -> list[dict[str, Any]]:
    value = payload.get(key, [])
    if not isinstance(value, list):
        return []
    return [item for item in value if isinstance(item, dict)]


def has_rows(payload: dict[str, Any]) -> bool:
    return any(rows(payload, key) for key in payload if key != "format")


def normalize_payload(payload: Any) -> dict[str, Any]:
    if not isinstance(payload, dict):
        raise ValueError("payload deve ser um objeto JSON")
    normalized: dict[str, Any] = {"format": "SELETO_SYNC_V1"}
    keys = sorted(
        key
        for key, value in payload.items()
        if key not in {"format", "exportedAt"} and isinstance(value, list)
    )
    for key in keys:
        primary_key = SYNC_TABLES.get(key, "id")
        clean_rows = rows(payload, key)
        clean_rows.sort(
            key=lambda row: (
                str(row.get(primary_key) or row.get("id") or ""),
                canonical_json(row),
            )
        )
        normalized[key] = clean_rows
    for key in SYNC_TABLES:
        normalized.setdefault(key, [])
    return normalized


def parse_date(value: Any) -> datetime | None:
    if value is None:
        return None
    if isinstance(value, (int, float)):
        try:
            return datetime.fromtimestamp(value / 1000, tz=timezone.utc)
        except (OSError, OverflowError, ValueError):
            return None
    if isinstance(value, str):
        text = value.strip()
        if not text:
            return None
        if text.endswith("Z"):
            text = f"{text[:-1]}+00:00"
        try:
            parsed = datetime.fromisoformat(text)
        except ValueError:
            return None
        if parsed.tzinfo is None:
            return parsed.replace(tzinfo=timezone.utc)
        return parsed.astimezone(timezone.utc)
    return None


def row_date(row: dict[str, Any]) -> datetime | None:
    for key in TIMESTAMP_KEYS:
        parsed = parse_date(row.get(key))
        if parsed is not None:
            return parsed
    return None


def newer_or_remote(local: dict[str, Any], remote: dict[str, Any]) -> dict[str, Any]:
    if canonical_json(local) == canonical_json(remote):
        return remote
    local_date = row_date(local)
    remote_date = row_date(remote)
    if local_date is not None and remote_date is not None:
        return local if local_date > remote_date else remote
    if local_date is not None and remote_date is None:
        return local
    return remote


def merge_rows(
    local_rows: list[dict[str, Any]],
    remote_rows: list[dict[str, Any]],
    collection_key: str,
) -> list[dict[str, Any]]:
    primary_key = SYNC_TABLES.get(collection_key, "id")
    by_id: dict[str, dict[str, Any]] = {}
    for row in remote_rows:
        row_id = str(row.get(primary_key) or row.get("id") or payload_hash({"row": row}))
        by_id[row_id] = row
    for row in local_rows:
        row_id = str(row.get(primary_key) or row.get("id") or payload_hash({"row": row}))
        remote = by_id.get(row_id)
        by_id[row_id] = row if remote is None else newer_or_remote(row, remote)
    result = list(by_id.values())
    result.sort(
        key=lambda row: (
            str(row.get(primary_key) or row.get("id") or ""),
            canonical_json(row),
        )
    )
    return result


def merge_payloads(local: dict[str, Any], remote: dict[str, Any]) -> dict[str, Any]:
    local = normalize_payload(local)
    remote = normalize_payload(remote)
    merged: dict[str, Any] = {"format": "SELETO_SYNC_V1"}
    keys = sorted(set(local.keys()) | set(remote.keys()) | set(SYNC_TABLES.keys()))
    for key in keys:
        if key == "format":
            continue
        if key in LOCAL_AUTHORITATIVE_ON_MERGE:
            merged[key] = rows(local, key)
        else:
            merged[key] = merge_rows(rows(local, key), rows(remote, key), key)
    return normalize_payload(merged)


def scope_from_body(body: dict[str, Any]) -> tuple[str, str, str | None, bool]:
    is_super_admin = bool(body.get("isSuperAdmin", body.get("is_super_admin", False)))
    tenant_id = str(body.get("tenantId") or body.get("tenant_id") or DEFAULT_TENANT_ID)
    user_id_raw = body.get("userId", body.get("user_id"))
    user_id = None if user_id_raw is None else str(user_id_raw)
    scope_key = body.get("scopeKey") or body.get("scope_key")
    if scope_key is None:
        scope_key = "super_admin" if is_super_admin else f"tenant_{tenant_id}"
    return str(scope_key), tenant_id, user_id, is_super_admin


def decode_payload(value: Any) -> dict[str, Any] | None:
    if value is None:
        return None
    if isinstance(value, dict):
        return value
    if isinstance(value, str):
        return json.loads(value)
    return dict(value)


def audit_event(
    cur,
    *,
    scope_key: str,
    device_id: str | None,
    user_id: str | None,
    status: str,
    local_hash: str | None,
    remote_hash_before: str | None,
    remote_hash_after: str | None,
    revision: int | None,
    reason: str | None,
) -> None:
    cur.execute(
        """
        insert into seleto_sync_events (
          scope_key, device_id, user_id, status, local_hash,
          remote_hash_before, remote_hash_after, revision, reason
        ) values (%s, %s, %s, %s, %s, %s, %s, %s, %s)
        """,
        (
            scope_key,
            device_id,
            user_id,
            status,
            local_hash,
            remote_hash_before,
            remote_hash_after,
            revision,
            reason,
        ),
    )


def snapshot_response(row: dict[str, Any] | None, *, include_payload: bool) -> dict[str, Any]:
    if row is None:
        return {"exists": False, "payload": None, "payloadHash": None, "revision": 0}
    response = {
        "exists": True,
        "payloadHash": row.get("payload_hash"),
        "revision": row.get("revision"),
        "updatedAt": str(row.get("updated_at")),
        "updatedByDevice": row.get("updated_by_device"),
        "tenantId": row.get("tenant_id"),
        "userId": row.get("user_id"),
        "isSuperAdmin": row.get("is_super_admin"),
    }
    if include_payload:
        response["payload"] = decode_payload(row.get("payload"))
    return response


def user_is_super_admin(payload: dict[str, Any], user: dict[str, Any]) -> bool:
    if bool(user.get("isSuperuser", user.get("is_superuser", False))):
        return True
    user_id = str(user.get("id") or "")
    if not user_id:
        return False
    for permission in rows(payload, "userPermissions"):
        permission_user_id = str(
            permission.get("userId") or permission.get("user_id") or ""
        )
        value = str(permission.get("permission") or "")
        if permission_user_id == user_id and value in {"*", "system.super_admin"}:
            return True
    return False


def find_login_snapshot(body: dict[str, Any]) -> tuple[int, dict[str, Any]]:
    username = str(body.get("username") or "").strip().lower()
    device_id = str(body.get("deviceId") or body.get("device_id") or "")
    if not username:
        return HTTPStatus.BAD_REQUEST, {
            "status": "erro",
            "message": "Informe username para consulta de login.",
        }

    with get_db().connect() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                select *
                  from seleto_sync_snapshots
                 order by is_super_admin desc, updated_at desc
                """
            )
            snapshots = cur.fetchall()
            for snapshot in snapshots:
                payload = normalize_payload(decode_payload(snapshot.get("payload")) or {})
                for user in rows(payload, "users"):
                    if str(user.get("username") or "").strip().lower() != username:
                        continue
                    user_id = str(user.get("id") or "")
                    tenant_id = str(
                        user.get("tenantId")
                        or user.get("tenant_id")
                        or snapshot.get("tenant_id")
                        or DEFAULT_TENANT_ID
                    )
                    is_super_admin = user_is_super_admin(payload, user)
                    audit_event(
                        cur,
                        scope_key=str(snapshot.get("scope_key")),
                        device_id=device_id,
                        user_id=user_id,
                        status="login_snapshot",
                        local_hash=None,
                        remote_hash_before=snapshot.get("payload_hash"),
                        remote_hash_after=snapshot.get("payload_hash"),
                        revision=int(snapshot.get("revision") or 0),
                        reason="login",
                    )
                    conn.commit()
                    return HTTPStatus.OK, {
                        "status": "ok",
                        "exists": True,
                        **snapshot_response(snapshot, include_payload=True),
                        "scopeKey": snapshot.get("scope_key"),
                        "tenantId": tenant_id,
                        "userId": user_id,
                        "isSuperAdmin": is_super_admin,
                    }
    return HTTPStatus.OK, {"status": "ok", "exists": False}


def pull_snapshot(body: dict[str, Any]) -> tuple[int, dict[str, Any]]:
    scope_key, _, _, _ = scope_from_body(body)
    with get_db().connect() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "select * from seleto_sync_snapshots where scope_key = %s",
                (scope_key,),
            )
            row = cur.fetchone()
    return HTTPStatus.OK, {"status": "ok", "scopeKey": scope_key, **snapshot_response(row, include_payload=True)}


def status_snapshot(body: dict[str, Any]) -> tuple[int, dict[str, Any]]:
    scope_key, _, _, _ = scope_from_body(body)
    with get_db().connect() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "select * from seleto_sync_snapshots where scope_key = %s",
                (scope_key,),
            )
            row = cur.fetchone()
    return HTTPStatus.OK, {"status": "ok", "scopeKey": scope_key, **snapshot_response(row, include_payload=False)}


def upsert_snapshot(
    cur,
    *,
    scope_key: str,
    tenant_id: str,
    user_id: str | None,
    is_super_admin: bool,
    payload: dict[str, Any],
    payload_hash_value: str,
    device_id: str | None,
    reason: str | None,
) -> int:
    cur.execute(
        """
        insert into seleto_sync_snapshots (
          scope_key, tenant_id, user_id, is_super_admin, payload, payload_hash,
          revision, updated_at, updated_by_device, reason
        ) values (%s, %s, %s, %s, %s::jsonb, %s, 1, now(), %s, %s)
        on conflict (scope_key) do update set
          tenant_id = excluded.tenant_id,
          user_id = excluded.user_id,
          is_super_admin = excluded.is_super_admin,
          payload = excluded.payload,
          payload_hash = excluded.payload_hash,
          revision = seleto_sync_snapshots.revision + 1,
          updated_at = now(),
          updated_by_device = excluded.updated_by_device,
          reason = excluded.reason
        returning revision
        """,
        (
            scope_key,
            tenant_id,
            user_id,
            is_super_admin,
            canonical_json(payload),
            payload_hash_value,
            device_id,
            reason,
        ),
    )
    row = cur.fetchone()
    return int(row["revision"])


def push_snapshot(body: dict[str, Any]) -> tuple[int, dict[str, Any]]:
    scope_key, tenant_id, user_id, is_super_admin = scope_from_body(body)
    device_id = str(body.get("deviceId") or body.get("device_id") or "")
    reason = body.get("reason")
    force = bool(body.get("force", False))
    expected_remote_hash = body.get("expectedRemoteHash") or body.get("expected_remote_hash")
    local_payload = normalize_payload(body.get("payload"))
    local_hash = payload_hash(local_payload)

    with get_db().connect() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "select * from seleto_sync_snapshots where scope_key = %s for update",
                (scope_key,),
            )
            remote = cur.fetchone()
            remote_hash_before = None if remote is None else remote.get("payload_hash")
            if remote is not None and expected_remote_hash and expected_remote_hash != remote_hash_before and not force:
                conn.rollback()
                return (
                    HTTPStatus.CONFLICT,
                    {
                        "status": "conflict",
                        "scopeKey": scope_key,
                        "message": "Snapshot remoto mudou. Baixe antes de sobrescrever.",
                        **snapshot_response(remote, include_payload=True),
                    },
                )
            revision = upsert_snapshot(
                cur,
                scope_key=scope_key,
                tenant_id=tenant_id,
                user_id=user_id,
                is_super_admin=is_super_admin,
                payload=local_payload,
                payload_hash_value=local_hash,
                device_id=device_id,
                reason=str(reason) if reason is not None else None,
            )
            audit_event(
                cur,
                scope_key=scope_key,
                device_id=device_id,
                user_id=user_id,
                status="uploaded",
                local_hash=local_hash,
                remote_hash_before=remote_hash_before,
                remote_hash_after=local_hash,
                revision=revision,
                reason=str(reason) if reason is not None else None,
            )
        conn.commit()
    return HTTPStatus.OK, {
        "status": "uploaded",
        "scopeKey": scope_key,
        "payloadHash": local_hash,
        "revision": revision,
        "serverTime": utc_now_iso(),
    }


def sync_snapshot(body: dict[str, Any]) -> tuple[int, dict[str, Any]]:
    scope_key, tenant_id, user_id, is_super_admin = scope_from_body(body)
    device_id = str(body.get("deviceId") or body.get("device_id") or "")
    reason = body.get("reason")
    last_remote_hash = body.get("lastRemoteHash") or body.get("last_remote_hash")
    prefer_local_on_first_sync = bool(
        body.get("preferLocalOnFirstSync", body.get("prefer_local_on_first_sync", False))
    )
    local_payload = normalize_payload(body.get("payload") or body.get("localPayload"))
    local_hash = payload_hash(local_payload)

    with get_db().connect() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "select * from seleto_sync_snapshots where scope_key = %s for update",
                (scope_key,),
            )
            remote = cur.fetchone()
            remote_payload = decode_payload(remote.get("payload")) if remote else None
            remote_hash = None if remote is None else remote.get("payload_hash")

            status = "idle"
            result_payload = local_payload
            result_hash = local_hash
            revision = 0 if remote is None else int(remote.get("revision") or 0)
            should_store = False

            if remote_payload is None:
                if has_rows(local_payload):
                    status = "uploaded"
                    should_store = True
                else:
                    status = "idle"
                    result_payload = None
                    result_hash = None
            elif (
                prefer_local_on_first_sync
                and last_remote_hash is None
                and has_rows(local_payload)
            ):
                status = "uploaded"
                should_store = True
            elif local_hash == remote_hash:
                status = "idle"
                result_payload = remote_payload
                result_hash = remote_hash
            elif last_remote_hash == remote_hash:
                status = "uploaded"
                should_store = True
            elif last_remote_hash == local_hash:
                status = "downloaded"
                result_payload = remote_payload
                result_hash = remote_hash
            else:
                status = "merged"
                result_payload = merge_payloads(local_payload, remote_payload)
                result_hash = payload_hash(result_payload)
                should_store = True

            if should_store:
                revision = upsert_snapshot(
                    cur,
                    scope_key=scope_key,
                    tenant_id=tenant_id,
                    user_id=user_id,
                    is_super_admin=is_super_admin,
                    payload=result_payload,
                    payload_hash_value=result_hash,
                    device_id=device_id,
                    reason=str(reason) if reason is not None else None,
                )

            audit_event(
                cur,
                scope_key=scope_key,
                device_id=device_id,
                user_id=user_id,
                status=status,
                local_hash=local_hash,
                remote_hash_before=remote_hash,
                remote_hash_after=result_hash,
                revision=revision,
                reason=str(reason) if reason is not None else None,
            )
        conn.commit()

    return HTTPStatus.OK, {
        "status": status,
        "scopeKey": scope_key,
        "payload": result_payload,
        "payloadHash": result_hash,
        "revision": revision,
        "serverTime": utc_now_iso(),
    }


class SyncHandler(BaseHTTPRequestHandler):
    server_version = "SeletoSync/1.0"

    def log_message(self, fmt: str, *args: Any) -> None:
        sys.stdout.write(
            "%s %s\n" % (datetime.now().isoformat(timespec="seconds"), fmt % args)
        )
        sys.stdout.flush()

    def _send_json(self, status: int, payload: dict[str, Any]) -> None:
        body = json.dumps(payload, ensure_ascii=False, separators=(",", ":")).encode("utf-8")
        self.send_response(int(status))
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        self.wfile.write(body)

    def _authorized(self) -> bool:
        if ALLOW_NO_TOKEN:
            return True
        if not SYNC_TOKEN:
            self._send_json(
                HTTPStatus.SERVICE_UNAVAILABLE,
                {
                    "status": "erro",
                    "message": "SELETO_SYNC_TOKEN nao configurado no servidor.",
                },
            )
            return False
        auth = self.headers.get("Authorization", "")
        token = self.headers.get("X-Seleto-Sync-Token", "")
        if auth.startswith("Bearer "):
            token = auth.removeprefix("Bearer ").strip()
        if token != SYNC_TOKEN:
            self._send_json(
                HTTPStatus.UNAUTHORIZED,
                {"status": "erro", "message": "Token de sincronizacao invalido."},
            )
            return False
        return True

    def _read_json(self) -> dict[str, Any]:
        length = int(self.headers.get("Content-Length", "0"))
        if length > MAX_BODY_BYTES:
            raise ValueError("Corpo da requisicao excede o limite configurado.")
        if length <= 0:
            return {}
        body = self.rfile.read(length)
        return json.loads(body.decode("utf-8"))

    def do_OPTIONS(self) -> None:
        self.send_response(HTTPStatus.NO_CONTENT)
        self.send_header("Allow", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Headers", "authorization, content-type, x-seleto-sync-token")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.end_headers()

    def do_GET(self) -> None:
        parsed = urlparse(self.path)
        if parsed.path != "/health":
            self._send_json(HTTPStatus.NOT_FOUND, {"status": "erro", "message": "Rota nao encontrada."})
            return
        started = time.time()
        try:
            with get_db().connect() as conn:
                with conn.cursor() as cur:
                    cur.execute("select 1 as ok")
                    cur.fetchone()
            self._send_json(
                HTTPStatus.OK,
                {
                    "status": "ok",
                    "service": "seleto-sync",
                    "port": PORT,
                    "database": "ok",
                    "latencyMs": round((time.time() - started) * 1000, 2),
                    "serverTime": utc_now_iso(),
                },
            )
        except Exception as exc:
            self._send_json(
                HTTPStatus.SERVICE_UNAVAILABLE,
                {"status": "erro", "database": "erro", "message": str(exc)},
            )

    def do_POST(self) -> None:
        if not self._authorized():
            return
        parsed = urlparse(self.path)
        try:
            body = self._read_json()
            if parsed.path == "/sync/v1/pull":
                status, payload = pull_snapshot(body)
            elif parsed.path == "/sync/v1/status":
                status, payload = status_snapshot(body)
            elif parsed.path == "/sync/v1/push":
                status, payload = push_snapshot(body)
            elif parsed.path == "/sync/v1/sync":
                status, payload = sync_snapshot(body)
            elif parsed.path == "/sync/v1/login":
                status, payload = find_login_snapshot(body)
            else:
                query = parse_qs(parsed.query)
                status, payload = HTTPStatus.NOT_FOUND, {
                    "status": "erro",
                    "message": "Rota nao encontrada.",
                    "path": parsed.path,
                    "query": query,
                }
            self._send_json(status, payload)
        except json.JSONDecodeError:
            self._send_json(
                HTTPStatus.BAD_REQUEST,
                {"status": "erro", "message": "JSON invalido."},
            )
        except ValueError as exc:
            self._send_json(
                HTTPStatus.BAD_REQUEST,
                {"status": "erro", "message": str(exc)},
            )
        except Exception as exc:
            traceback.print_exc()
            self._send_json(
                HTTPStatus.INTERNAL_SERVER_ERROR,
                {"status": "erro", "message": str(exc)},
            )


def main() -> int:
    if not SYNC_TOKEN and not ALLOW_NO_TOKEN:
        print(
            "ERRO: defina SELETO_SYNC_TOKEN antes de iniciar o servidor publico.",
            file=sys.stderr,
        )
        print(
            "Para ambiente local isolado, use SELETO_SYNC_ALLOW_NO_TOKEN=true.",
            file=sys.stderr,
        )
        return 2
    get_db().initialize()
    httpd = ThreadingHTTPServer((HOST, PORT), SyncHandler)
    httpd.daemon_threads = True

    def stop(signum, _frame) -> None:
        print(f"Recebido sinal {signum}; encerrando servidor...")
        httpd.shutdown()

    signal.signal(signal.SIGTERM, stop)
    signal.signal(signal.SIGINT, stop)
    print(f"SELETO sync server ouvindo em {HOST}:{PORT}")
    httpd.serve_forever()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
