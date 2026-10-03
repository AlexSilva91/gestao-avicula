#!/usr/bin/env python3
"""
Servidor de sincronizacao SELETO.

Endpoints principais:
  GET  /health
  POST /sync/v1/health
  POST /sync/v1/status
  POST /sync/v1/pull
  POST /sync/v1/push
  POST /sync/v1/sync
  POST /sync/v1/login
  POST /sync/v1/presence

O processo escuta somente a porta 5005. O PostgreSQL reflete o banco local
tabela por tabela; JSON e usado apenas como corpo HTTP do protocolo de sync.
"""

from __future__ import annotations

import hashlib
import json
import os
import signal
import sys
import time
import traceback
from dataclasses import dataclass
from datetime import datetime, timezone
from http import HTTPStatus
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from typing import Any
from urllib.parse import parse_qs, urlparse


HOST = os.environ.get("SELETO_SYNC_HOST", "0.0.0.0")
PORT = 5005
STARTED_AT = time.time()
MAX_BODY_BYTES = int(os.environ.get("SELETO_SYNC_MAX_BODY_BYTES", "67108864"))
REQUEST_TIMEOUT_SECONDS = int(os.environ.get("SELETO_SYNC_TIMEOUT_SECONDS", "30"))
PRESENCE_ONLINE_WINDOW_SECONDS = int(os.environ.get("SELETO_SYNC_PRESENCE_ONLINE_SECONDS", "25"))
DEFAULT_TENANT_ID = "tenant-default"
SYNC_TOKEN = os.environ.get("SELETO_SYNC_TOKEN", "").strip()
ALLOW_NO_TOKEN = os.environ.get("SELETO_SYNC_ALLOW_NO_TOKEN", "").lower() in {
    "1",
    "true",
    "yes",
}


@dataclass(frozen=True)
class ColumnSpec:
    json_key: str
    sql_name: str
    kind: str


@dataclass(frozen=True)
class TableSpec:
    collection_key: str
    table_name: str
    primary_key: str
    columns: tuple[ColumnSpec, ...]

    @property
    def primary_sql(self) -> str:
        return column_sql_name(self.primary_key)


def column_sql_name(name: str) -> str:
    result = []
    for char in name:
        if char.isupper():
            result.append("_")
            result.append(char.lower())
        else:
            result.append(char)
    return "".join(result).lstrip("_")


def col(name: str, kind: str) -> ColumnSpec:
    return ColumnSpec(name, column_sql_name(name), kind)


TABLE_SPECS: tuple[TableSpec, ...] = (
    TableSpec("tenants", "tenants", "id", (col("id", "text"), col("name", "text"), col("isActive", "bool"), col("createdAt", "datetime"), col("createdBy", "text"))),
    TableSpec("users", "users", "id", (col("id", "text"), col("tenantId", "text"), col("username", "text"), col("displayName", "text"), col("passwordHash", "text"), col("isSuperuser", "bool"), col("isActive", "bool"), col("createdAt", "datetime"), col("updatedAt", "datetime"), col("lastLoginAt", "datetime"), col("lastSeenAt", "datetime"))),
    TableSpec("userPermissions", "user_permissions", "id", (col("id", "text"), col("userId", "text"), col("permission", "text"), col("createdAt", "datetime"))),
    TableSpec("auditLogs", "audit_logs", "id", (col("id", "text"), col("userId", "text"), col("action", "text"), col("entityType", "text"), col("entityId", "text"), col("timestamp", "datetime"), col("description", "text"), col("metadata", "text"))),
    TableSpec("lots", "lots", "id", (col("id", "text"), col("name", "text"), col("strain", "text"), col("initialQuantity", "int"), col("receivedAt", "datetime"), col("arrivalAgeDays", "int"), col("unitValueCents", "int"), col("supplier", "text"), col("notes", "text"), col("status", "text"), col("createdAt", "datetime"), col("createdBy", "text"))),
    TableSpec("birdMovements", "bird_movements", "id", (col("id", "text"), col("type", "text"), col("occurredAt", "datetime"), col("lotId", "text"), col("relatedLotId", "text"), col("quantity", "int"), col("unitValueCents", "int"), col("totalValueCents", "int"), col("reference", "text"), col("notes", "text"), col("createdBy", "text"), col("createdAt", "datetime"))),
    TableSpec("eggCollections", "egg_collections", "id", (col("id", "text"), col("collectedOn", "datetime"), col("lotId", "text"), col("quantity", "int"), col("cleanEggs", "int"), col("dirtyEggs", "int"), col("crackedEggs", "int"), col("brokenEggs", "int"), col("discardedEggs", "int"), col("notes", "text"), col("createdBy", "text"), col("createdAt", "datetime"))),
    TableSpec("eggStockMovements", "egg_stock_movements", "id", (col("id", "text"), col("type", "text"), col("occurredAt", "datetime"), col("quantity", "int"), col("collectionId", "text"), col("reference", "text"), col("notes", "text"), col("createdBy", "text"), col("createdAt", "datetime"))),
    TableSpec("ingredients", "ingredients", "id", (col("id", "text"), col("name", "text"), col("unit", "text"), col("isActive", "bool"), col("notes", "text"), col("createdAt", "datetime"), col("createdBy", "text"))),
    TableSpec("prices", "ingredient_price_history", "id", (col("id", "text"), col("ingredientId", "text"), col("pricePerKgCents", "int"), col("effectiveDate", "datetime"), col("supplier", "text"), col("notes", "text"), col("createdBy", "text"), col("createdAt", "datetime"))),
    TableSpec("ingredientLots", "ingredient_lots", "id", (col("id", "text"), col("ingredientId", "text"), col("code", "text"), col("entryDate", "datetime"), col("initialQuantityKg", "real"), col("packageUnit", "text"), col("packageQuantity", "real"), col("packageWeightKg", "real"), col("totalCostCents", "int"), col("pricePerKgCents", "int"), col("supplier", "text"), col("notes", "text"), col("createdBy", "text"), col("createdAt", "datetime"))),
    TableSpec("ingredientStockMovements", "ingredient_stock_movements", "id", (col("id", "text"), col("type", "text"), col("occurredAt", "datetime"), col("ingredientId", "text"), col("ingredientLotId", "text"), col("quantityKg", "real"), col("pricePerKgCentsSnapshot", "int"), col("totalCostCents", "int"), col("referenceType", "text"), col("referenceId", "text"), col("notes", "text"), col("createdBy", "text"), col("createdAt", "datetime"))),
    TableSpec("formulas", "feed_formulas", "id", (col("id", "text"), col("name", "text"), col("phase", "text"), col("version", "int"), col("isActive", "bool"), col("validFrom", "datetime"), col("notes", "text"), col("createdBy", "text"), col("createdAt", "datetime"))),
    TableSpec("formulaItems", "feed_formula_items", "id", (col("id", "text"), col("formulaId", "text"), col("ingredientId", "text"), col("baseQuantityKg", "real"))),
    TableSpec("feedBatches", "feed_batches", "id", (col("id", "text"), col("code", "text"), col("phase", "text"), col("formulaId", "text"), col("producedAt", "datetime"), col("producedQuantityKg", "real"), col("totalCostCents", "int"), col("costPerKgCents", "real"), col("notes", "text"), col("createdBy", "text"), col("createdAt", "datetime"))),
    TableSpec("feedBatchItems", "feed_batch_items", "id", (col("id", "text"), col("batchId", "text"), col("ingredientId", "text"), col("quantityKg", "real"), col("pricePerKgCentsSnapshot", "int"), col("itemCostCents", "int"))),
    TableSpec("feedStock", "feed_stock_movements", "id", (col("id", "text"), col("type", "text"), col("occurredAt", "datetime"), col("batchId", "text"), col("quantityKg", "real"), col("feedingId", "text"), col("notes", "text"), col("createdBy", "text"), col("createdAt", "datetime"))),
    TableSpec("feedings", "daily_feedings", "id", (col("id", "text"), col("feedingDate", "datetime"), col("lotId", "text"), col("batchId", "text"), col("quantityKg", "real"), col("notes", "text"), col("createdBy", "text"), col("createdAt", "datetime"))),
    TableSpec("feedRecommendations", "feed_consumption_recommendations", "id", (col("id", "text"), col("startWeek", "int"), col("endWeek", "int"), col("gramsPerBirdDay", "real"), col("phase", "text"), col("source", "text"), col("notes", "text"), col("createdBy", "text"), col("createdAt", "datetime"))),
    TableSpec("customers", "customers", "id", (col("id", "text"), col("name", "text"), col("phone", "text"), col("address", "text"), col("notes", "text"), col("isActive", "bool"), col("createdAt", "datetime"), col("createdBy", "text"))),
    TableSpec("orders", "orders", "id", (col("id", "text"), col("orderNumber", "int"), col("customerId", "text"), col("requestedDate", "datetime"), col("expectedDeliveryDate", "datetime"), col("status", "text"), col("subtotalCents", "int"), col("discountCents", "int"), col("totalCents", "int"), col("notes", "text"), col("createdBy", "text"), col("updatedBy", "text"), col("createdAt", "datetime"), col("updatedAt", "datetime"))),
    TableSpec("orderItems", "order_items", "id", (col("id", "text"), col("orderId", "text"), col("productType", "text"), col("quantity", "real"), col("unitPriceCents", "int"), col("totalCents", "int"))),
    TableSpec("orderStatusHistory", "order_status_history", "id", (col("id", "text"), col("orderId", "text"), col("oldStatus", "text"), col("newStatus", "text"), col("changedAt", "datetime"), col("changedBy", "text"), col("notes", "text"))),
    TableSpec("packagingItems", "packaging_items", "id", (col("id", "text"), col("type", "text"), col("name", "text"), col("notes", "text"), col("isActive", "bool"), col("createdBy", "text"), col("createdAt", "datetime"))),
    TableSpec("packagingLots", "packaging_lots", "id", (col("id", "text"), col("itemId", "text"), col("batchCode", "text"), col("initialQuantity", "int"), col("unitCostCents", "int"), col("totalCostCents", "int"), col("purchasedAt", "datetime"), col("supplier", "text"), col("notes", "text"), col("createdBy", "text"), col("createdAt", "datetime"))),
    TableSpec("packagingStockMovements", "packaging_stock_movements", "id", (col("id", "text"), col("itemId", "text"), col("lotId", "text"), col("type", "text"), col("occurredAt", "datetime"), col("quantity", "int"), col("reference", "text"), col("notes", "text"), col("createdBy", "text"), col("createdAt", "datetime"))),
    TableSpec("eggTrayBatches", "egg_tray_batches", "id", (col("id", "text"), col("trayLotId", "text"), col("labelLotId", "text"), col("quantity", "int"), col("eggsPerTray", "int"), col("assembledAt", "datetime"), col("trayUnitCostCents", "int"), col("labelUnitCostCents", "int"), col("eggUnitCostCents", "int"), col("unitPackagingCostCents", "int"), col("finalUnitPriceCents", "int"), col("notes", "text"), col("createdBy", "text"), col("createdAt", "datetime"))),
    TableSpec("eggTrayStockMovements", "egg_tray_stock_movements", "id", (col("id", "text"), col("batchId", "text"), col("type", "text"), col("occurredAt", "datetime"), col("quantity", "int"), col("reference", "text"), col("notes", "text"), col("createdBy", "text"), col("createdAt", "datetime"))),
    TableSpec("sales", "sales", "id", (col("id", "text"), col("soldAt", "datetime"), col("customerId", "text"), col("orderId", "text"), col("trayBatchId", "text"), col("trayQuantity", "int"), col("dozens", "int"), col("looseEggs", "int"), col("dozenPriceCents", "int"), col("totalCents", "int"), col("paymentMethod", "text"), col("status", "text"), col("notes", "text"), col("createdBy", "text"), col("createdAt", "datetime"))),
    TableSpec("finance", "finance_transactions", "id", (col("id", "text"), col("occurredAt", "datetime"), col("type", "text"), col("category", "text"), col("description", "text"), col("amountCents", "int"), col("referenceType", "text"), col("referenceId", "text"), col("paymentMethod", "text"), col("status", "text"), col("notes", "text"), col("createdBy", "text"), col("createdAt", "datetime"))),
    TableSpec("investments", "investments", "id", (col("id", "text"), col("description", "text"), col("category", "text"), col("investmentDate", "datetime"), col("amountCents", "int"), col("lotId", "text"), col("createdBy", "text"), col("createdAt", "datetime"))),
    TableSpec("financialEstablishments", "financial_establishments", "id", (col("id", "text"), col("name", "text"), col("type", "text"), col("contact", "text"), col("notes", "text"), col("isActive", "bool"), col("createdBy", "text"), col("createdAt", "datetime"))),
    TableSpec("personalFinance", "personal_finance_transactions", "id", (col("id", "text"), col("occurredAt", "datetime"), col("type", "text"), col("category", "text"), col("description", "text"), col("amountCents", "int"), col("establishmentId", "text"), col("paymentMethod", "text"), col("status", "text"), col("notes", "text"), col("referenceType", "text"), col("referenceId", "text"), col("createdBy", "text"), col("createdAt", "datetime"))),
    TableSpec("financialReserves", "financial_reserves", "id", (col("id", "text"), col("name", "text"), col("targetAmountCents", "int"), col("currentAmountCents", "int"), col("account", "text"), col("notes", "text"), col("createdBy", "text"), col("createdAt", "datetime"), col("updatedAt", "datetime"))),
    TableSpec("personalInvestments", "personal_investments", "id", (col("id", "text"), col("description", "text"), col("category", "text"), col("institution", "text"), col("amountCents", "int"), col("allocationPercent", "real"), col("investmentDate", "datetime"), col("notes", "text"), col("createdBy", "text"), col("createdAt", "datetime"))),
    TableSpec("personalDebts", "personal_debts", "id", (col("id", "text"), col("creditor", "text"), col("debtType", "text"), col("totalAmountCents", "int"), col("paidAmountCents", "int"), col("installmentAmountCents", "int"), col("dueDate", "datetime"), col("expectedPayoffDate", "datetime"), col("alertEnabled", "bool"), col("notes", "text"), col("status", "text"), col("createdBy", "text"), col("createdAt", "datetime"))),
    TableSpec("lightingPrograms", "lighting_programs", "id", (col("id", "text"), col("name", "text"), col("description", "text"), col("isDefault", "bool"), col("isActive", "bool"), col("createdBy", "text"), col("createdAt", "datetime"))),
    TableSpec("lightingSteps", "lighting_program_steps", "id", (col("id", "text"), col("programId", "text"), col("startAgeDays", "int"), col("endAgeDays", "int"), col("totalLightMinutes", "int"), col("startTime", "text"), col("endTime", "text"), col("weeklyIncrementMinutes", "int"), col("relatedPhase", "text"), col("notes", "text"))),
    TableSpec("lotLighting", "lot_lighting_programs", "id", (col("id", "text"), col("lotId", "text"), col("programId", "text"), col("assignedAt", "datetime"), col("createdBy", "text"))),
    TableSpec("calendarEvents", "calendar_events", "id", (col("id", "text"), col("title", "text"), col("type", "text"), col("startsAt", "datetime"), col("endsAt", "datetime"), col("lotId", "text"), col("referenceType", "text"), col("referenceId", "text"), col("notes", "text"), col("alertEnabled", "bool"), col("alertMessage", "text"), col("alertTime", "text"), col("recurrence", "text"), col("repeatUntil", "datetime"), col("weekdays", "text"), col("createdBy", "text"), col("createdAt", "datetime"), col("updatedAt", "datetime"))),
    TableSpec("vaccinationRecords", "vaccination_records", "id", (col("id", "text"), col("lotId", "text"), col("vaccineName", "text"), col("disease", "text"), col("scheduledAt", "datetime"), col("appliedAt", "datetime"), col("dose", "text"), col("route", "text"), col("batchNumber", "text"), col("manufacturer", "text"), col("responsible", "text"), col("status", "text"), col("notes", "text"), col("createdBy", "text"), col("createdAt", "datetime"), col("updatedAt", "datetime"))),
    TableSpec("notificationSettings", "notification_settings", "id", (col("id", "text"), col("type", "text"), col("isEnabled", "bool"), col("daysBefore", "int"), col("notificationTime", "text"), col("defaultMessage", "text"), col("defaultRecurrence", "text"))),
    TableSpec("appSettings", "app_settings", "key", (col("key", "text"), col("value", "text"), col("updatedAt", "datetime"), col("updatedBy", "text"))),
)

TABLE_BY_COLLECTION = {spec.collection_key: spec for spec in TABLE_SPECS}
LOCAL_AUTHORITATIVE_ON_MERGE = {
    "ingredients",
    "prices",
    "ingredientLots",
    "ingredientStockMovements",
    "formulas",
    "formulaItems",
}
GLOBAL_ONLY_COLLECTIONS = {"feedRecommendations", "notificationSettings", "appSettings"}
CREATED_BY_COLLECTIONS = {
    "lots", "birdMovements", "eggCollections", "eggStockMovements",
    "ingredients", "prices", "ingredientLots", "ingredientStockMovements",
    "formulas", "feedBatches", "feedStock", "feedings", "customers", "orders",
    "packagingItems", "packagingLots", "packagingStockMovements",
    "eggTrayBatches", "eggTrayStockMovements", "sales", "finance",
    "investments", "financialEstablishments", "personalFinance",
    "financialReserves", "personalInvestments", "personalDebts",
    "lightingPrograms", "lotLighting", "calendarEvents", "vaccinationRecords",
}
CHILD_COLLECTIONS = {
    "formulaItems": ("formulas", "formulaId"),
    "feedBatchItems": ("feedBatches", "batchId"),
    "orderItems": ("orders", "orderId"),
    "orderStatusHistory": ("orders", "orderId"),
    "lightingSteps": ("lightingPrograms", "programId"),
}
TIMESTAMP_KEYS = [
    "updatedAt", "createdAt", "timestamp", "occurredAt", "collectedOn",
    "effectiveDate", "entryDate", "validFrom", "producedAt", "feedingDate",
    "requestedDate", "purchasedAt", "assembledAt", "soldAt", "investmentDate",
    "startsAt", "assignedAt", "changedAt", "scheduledAt", "appliedAt",
    "dueDate", "expectedPayoffDate",
]


def sql_type(kind: str) -> str:
    return {
        "text": "text",
        "int": "bigint",
        "real": "double precision",
        "bool": "boolean",
        "datetime": "timestamptz",
    }[kind]


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
                create_schema(cur)
                migrate_legacy_snapshots(cur)
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
    return any(rows(payload, spec.collection_key) for spec in TABLE_SPECS)


def normalize_payload(payload: Any) -> dict[str, Any]:
    if not isinstance(payload, dict):
        raise ValueError("payload deve ser um objeto JSON")
    normalized: dict[str, Any] = {"format": "SELETO_SYNC_V1"}
    for spec in TABLE_SPECS:
        clean_rows = rows(payload, spec.collection_key)
        clean_rows.sort(
            key=lambda row: (
                str(row.get(spec.primary_key) or row.get("id") or ""),
                canonical_json(row),
            )
        )
        normalized[spec.collection_key] = clean_rows
    return normalized


def parse_date(value: Any) -> datetime | None:
    if value is None:
        return None
    if isinstance(value, datetime):
        return value.astimezone(timezone.utc) if value.tzinfo else value.replace(tzinfo=timezone.utc)
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
        return parsed.astimezone(timezone.utc) if parsed.tzinfo else parsed.replace(tzinfo=timezone.utc)
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


def merge_rows(local_rows: list[dict[str, Any]], remote_rows: list[dict[str, Any]], spec: TableSpec) -> list[dict[str, Any]]:
    by_id: dict[str, dict[str, Any]] = {}
    for row in remote_rows:
        row_id = str(row.get(spec.primary_key) or row.get("id") or payload_hash({"row": row}))
        by_id[row_id] = row
    for row in local_rows:
        row_id = str(row.get(spec.primary_key) or row.get("id") or payload_hash({"row": row}))
        remote = by_id.get(row_id)
        by_id[row_id] = row if remote is None else newer_or_remote(row, remote)
    result = list(by_id.values())
    result.sort(key=lambda row: (str(row.get(spec.primary_key) or row.get("id") or ""), canonical_json(row)))
    return result


def merge_payloads(local: dict[str, Any], remote: dict[str, Any]) -> dict[str, Any]:
    local = normalize_payload(local)
    remote = normalize_payload(remote)
    merged: dict[str, Any] = {"format": "SELETO_SYNC_V1"}
    for spec in TABLE_SPECS:
        key = spec.collection_key
        merged[key] = rows(local, key) if key in LOCAL_AUTHORITATIVE_ON_MERGE else merge_rows(rows(local, key), rows(remote, key), spec)
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


def create_schema(cur) -> None:
    for spec in TABLE_SPECS:
        columns = []
        for column in spec.columns:
            definition = f"{column.sql_name} {sql_type(column.kind)}"
            if column.json_key == spec.primary_key:
                definition += " primary key"
            columns.append(definition)
        cur.execute(f"create table if not exists {spec.table_name} ({', '.join(columns)})")
        for column in spec.columns:
            if column.json_key == spec.primary_key:
                continue
            cur.execute(
                f"alter table {spec.table_name} add column if not exists {column.sql_name} {sql_type(column.kind)}"
            )

    def ensure_columns(table_name: str, columns: tuple[tuple[str, str], ...]) -> None:
        for column_name, column_type in columns:
            cur.execute(
                f"alter table {table_name} add column if not exists {column_name} {column_type}"
            )

    cur.execute(
        """
        create table if not exists seleto_sync_scopes (
          scope_key text primary key,
          tenant_id text not null,
          user_id text,
          is_super_admin boolean not null default false,
          payload_hash text,
          revision bigint not null default 0,
          updated_at timestamptz not null default now(),
          updated_by_device text,
          reason text
        )
        """
    )
    ensure_columns(
        "seleto_sync_scopes",
        (
            ("tenant_id", "text"),
            ("user_id", "text"),
            ("is_super_admin", "boolean not null default false"),
            ("payload_hash", "text"),
            ("revision", "bigint not null default 0"),
            ("updated_at", "timestamptz not null default now()"),
            ("updated_by_device", "text"),
            ("reason", "text"),
        ),
    )
    cur.execute(
        """
        create table if not exists seleto_sync_row_scopes (
          collection_key text not null,
          row_key text not null,
          scope_key text not null,
          primary key (collection_key, row_key, scope_key)
        )
        """
    )
    ensure_columns(
        "seleto_sync_row_scopes",
        (
            ("collection_key", "text"),
            ("row_key", "text"),
            ("scope_key", "text"),
        ),
    )
    cur.execute(
        """
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
        )
        """
    )
    ensure_columns(
        "seleto_sync_events",
        (
            ("scope_key", "text"),
            ("device_id", "text"),
            ("user_id", "text"),
            ("status", "text"),
            ("local_hash", "text"),
            ("remote_hash_before", "text"),
            ("remote_hash_after", "text"),
            ("revision", "bigint"),
            ("reason", "text"),
            ("created_at", "timestamptz not null default now()"),
        ),
    )
    cur.execute(
        """
        create table if not exists seleto_user_presence (
          user_id text primary key,
          tenant_id text not null,
          scope_key text not null,
          device_id text,
          is_super_admin boolean not null default false,
          is_online boolean not null default false,
          last_seen_at timestamptz,
          last_offline_at timestamptz,
          updated_at timestamptz not null default now(),
          app_state text
        )
        """
    )
    ensure_columns(
        "seleto_user_presence",
        (
            ("tenant_id", "text"),
            ("scope_key", "text"),
            ("device_id", "text"),
            ("is_super_admin", "boolean not null default false"),
            ("is_online", "boolean not null default false"),
            ("last_seen_at", "timestamptz"),
            ("last_offline_at", "timestamptz"),
            ("updated_at", "timestamptz not null default now()"),
            ("app_state", "text"),
        ),
    )
    cur.execute("create index if not exists idx_seleto_sync_row_scopes_scope on seleto_sync_row_scopes (scope_key, collection_key)")
    cur.execute("create index if not exists idx_seleto_sync_events_scope_created on seleto_sync_events (scope_key, created_at desc)")
    cur.execute("create index if not exists idx_seleto_user_presence_tenant_seen on seleto_user_presence (tenant_id, last_seen_at desc)")
    cur.execute("create index if not exists idx_seleto_user_presence_scope_seen on seleto_user_presence (scope_key, last_seen_at desc)")


def db_value(column: ColumnSpec, value: Any) -> Any:
    if value is None:
        return None
    if column.kind == "datetime":
        return parse_date(value)
    if column.kind == "bool":
        return bool(value)
    if column.kind == "int":
        return int(value)
    if column.kind == "real":
        return float(value)
    return str(value)


def json_value(value: Any) -> Any:
    if isinstance(value, datetime):
        return value.astimezone(timezone.utc).isoformat()
    return value


def upsert_row(cur, spec: TableSpec, row: dict[str, Any]) -> str | None:
    row_key_raw = row.get(spec.primary_key)
    if row_key_raw is None:
        return None
    row_key = str(row_key_raw)
    column_names = [column.sql_name for column in spec.columns]
    values = [db_value(column, row.get(column.json_key)) for column in spec.columns]
    placeholders = ", ".join(["%s"] * len(column_names))
    updates = ", ".join(f"{name} = excluded.{name}" for name in column_names if name != spec.primary_sql)
    cur.execute(
        f"""
        insert into {spec.table_name} ({', '.join(column_names)})
        values ({placeholders})
        on conflict ({spec.primary_sql}) do update set {updates}
        """,
        values,
    )
    return row_key


def row_to_payload(spec: TableSpec, row: dict[str, Any]) -> dict[str, Any]:
    result: dict[str, Any] = {}
    for column in spec.columns:
        result[column.json_key] = json_value(row.get(column.sql_name))
    return result


def payload_from_tables(cur, scope_key: str) -> dict[str, Any]:
    payload: dict[str, Any] = {"format": "SELETO_SYNC_V1"}
    for spec in TABLE_SPECS:
        if scope_key == "super_admin":
            cur.execute(f"select * from {spec.table_name} order by {spec.primary_sql}")
        else:
            cur.execute(
                f"""
                select t.*
                  from {spec.table_name} t
                  join seleto_sync_row_scopes s
                    on s.collection_key = %s
                   and s.row_key = t.{spec.primary_sql}
                   and s.scope_key = %s
                 order by t.{spec.primary_sql}
                """,
                (spec.collection_key, scope_key),
            )
        payload[spec.collection_key] = [row_to_payload(spec, row) for row in cur.fetchall()]
    return normalize_payload(payload)


def scope_row(cur, scope_key: str) -> dict[str, Any] | None:
    cur.execute("select * from seleto_sync_scopes where scope_key = %s", (scope_key,))
    return cur.fetchone()


def upsert_scope(
    cur,
    *,
    scope_key: str,
    tenant_id: str,
    user_id: str | None,
    is_super_admin: bool,
    payload_hash_value: str | None,
    device_id: str | None,
    reason: str | None,
) -> int:
    cur.execute(
        """
        insert into seleto_sync_scopes (
          scope_key, tenant_id, user_id, is_super_admin, payload_hash,
          revision, updated_at, updated_by_device, reason
        ) values (%s, %s, %s, %s, %s, 1, now(), %s, %s)
        on conflict (scope_key) do update set
          tenant_id = excluded.tenant_id,
          user_id = excluded.user_id,
          is_super_admin = excluded.is_super_admin,
          payload_hash = excluded.payload_hash,
          revision = seleto_sync_scopes.revision + 1,
          updated_at = now(),
          updated_by_device = excluded.updated_by_device,
          reason = excluded.reason
        returning revision
        """,
        (scope_key, tenant_id, user_id, is_super_admin, payload_hash_value, device_id, reason),
    )
    row = cur.fetchone()
    return int(row["revision"])


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
        (scope_key, device_id, user_id, status, local_hash, remote_hash_before, remote_hash_after, revision, reason),
    )


def tenant_scope_from_user_id(user_id: str | None, tenant_by_user_id: dict[str, str]) -> str | None:
    if not user_id or user_id == "system":
        return None
    tenant_id = tenant_by_user_id.get(user_id)
    return f"tenant_{tenant_id or DEFAULT_TENANT_ID}"


def derive_row_scopes(payload: dict[str, Any], collection_key: str, row: dict[str, Any], explicit_scope: str) -> set[str]:
    scopes = {explicit_scope}
    if explicit_scope == "super_admin" and collection_key in GLOBAL_ONLY_COLLECTIONS:
        return scopes

    tenant_by_user_id = {
        str(user["id"]): str(user.get("tenantId") or DEFAULT_TENANT_ID)
        for user in rows(payload, "users")
        if user.get("id") is not None
    }
    parent_by_collection = {
        key: {str(parent.get("id")): parent for parent in rows(payload, key) if parent.get("id") is not None}
        for key in {value[0] for value in CHILD_COLLECTIONS.values()}
    }

    tenant_scope = None
    if collection_key == "tenants":
        tenant_id = row.get("id")
        tenant_scope = f"tenant_{tenant_id}" if tenant_id else None
    elif collection_key == "users":
        tenant_scope = f"tenant_{row.get('tenantId') or DEFAULT_TENANT_ID}"
    elif collection_key in {"userPermissions", "auditLogs"}:
        tenant_scope = tenant_scope_from_user_id(str(row.get("userId") or ""), tenant_by_user_id)
    elif collection_key == "orderStatusHistory":
        tenant_scope = tenant_scope_from_user_id(str(row.get("changedBy") or ""), tenant_by_user_id)
    elif collection_key in CREATED_BY_COLLECTIONS:
        tenant_scope = tenant_scope_from_user_id(str(row.get("createdBy") or ""), tenant_by_user_id)
    elif collection_key in CHILD_COLLECTIONS:
        parent_collection, parent_key = CHILD_COLLECTIONS[collection_key]
        parent = parent_by_collection.get(parent_collection, {}).get(str(row.get(parent_key) or ""))
        if parent is not None:
            tenant_scope = tenant_scope_from_user_id(str(parent.get("createdBy") or ""), tenant_by_user_id)

    if tenant_scope is not None:
        scopes.add(tenant_scope)
    return scopes


def replace_payload_scope(
    cur,
    payload: dict[str, Any],
    *,
    scope_key: str,
    tenant_id: str,
    user_id: str | None,
    is_super_admin: bool,
    device_id: str | None,
    reason: str | None,
    prune_missing: bool = True,
) -> int:
    payload = normalize_payload(payload)
    payload_hash_value = payload_hash(payload)

    for spec in TABLE_SPECS:
        incoming_keys: set[str] = set()
        for row in rows(payload, spec.collection_key):
            row_key = upsert_row(cur, spec, row)
            if row_key is None:
                continue
            incoming_keys.add(row_key)
            for row_scope in derive_row_scopes(payload, spec.collection_key, row, scope_key):
                cur.execute(
                    """
                    insert into seleto_sync_row_scopes (collection_key, row_key, scope_key)
                    values (%s, %s, %s)
                    on conflict do nothing
                    """,
                    (spec.collection_key, row_key, row_scope),
                )

        if prune_missing:
            cur.execute(
                """
                select row_key from seleto_sync_row_scopes
                 where collection_key = %s and scope_key = %s
                """,
                (spec.collection_key, scope_key),
            )
            existing_keys = {str(row["row_key"]) for row in cur.fetchall()}
            for row_key in existing_keys - incoming_keys:
                if scope_key == "super_admin":
                    cur.execute(
                        "delete from seleto_sync_row_scopes where collection_key = %s and row_key = %s",
                        (spec.collection_key, row_key),
                    )
                    cur.execute(f"delete from {spec.table_name} where {spec.primary_sql} = %s", (row_key,))
                else:
                    cur.execute(
                        """
                        delete from seleto_sync_row_scopes
                         where collection_key = %s and row_key = %s and scope_key = %s
                        """,
                        (spec.collection_key, row_key, scope_key),
                    )
                    cur.execute(
                        """
                        select 1 from seleto_sync_row_scopes
                         where collection_key = %s and row_key = %s limit 1
                        """,
                        (spec.collection_key, row_key),
                    )
                    if cur.fetchone() is None:
                        cur.execute(f"delete from {spec.table_name} where {spec.primary_sql} = %s", (row_key,))

    stored_payload = payload_from_tables(cur, scope_key)
    return upsert_scope(
        cur,
        scope_key=scope_key,
        tenant_id=tenant_id,
        user_id=user_id,
        is_super_admin=is_super_admin,
        payload_hash_value=payload_hash(stored_payload),
        device_id=device_id,
        reason=reason,
    )


def scope_response(cur, scope_key: str, *, include_payload: bool) -> dict[str, Any]:
    row = scope_row(cur, scope_key)
    payload = payload_from_tables(cur, scope_key)
    current_hash = payload_hash(payload) if has_rows(payload) else None
    response: dict[str, Any] = {
        "exists": row is not None or has_rows(payload),
        "payloadHash": current_hash,
        "revision": 0 if row is None else row.get("revision"),
        "updatedAt": None if row is None else str(row.get("updated_at")),
        "updatedByDevice": None if row is None else row.get("updated_by_device"),
        "tenantId": None if row is None else row.get("tenant_id"),
        "userId": None if row is None else row.get("user_id"),
        "isSuperAdmin": None if row is None else row.get("is_super_admin"),
    }
    if include_payload:
        response["payload"] = payload if current_hash is not None else None
    return response


def migrate_legacy_snapshots(cur) -> None:
    cur.execute("select to_regclass('public.seleto_sync_snapshots') as table_name")
    exists = cur.fetchone()
    if not exists or not exists.get("table_name"):
        return
    cur.execute("select * from seleto_sync_snapshots order by updated_at")
    legacy_rows = cur.fetchall()
    for legacy in legacy_rows:
        payload = normalize_payload(decode_payload(legacy.get("payload")) or {})
        if not has_rows(payload):
            continue
        replace_payload_scope(
            cur,
            payload,
            scope_key=str(legacy.get("scope_key")),
            tenant_id=str(legacy.get("tenant_id") or DEFAULT_TENANT_ID),
            user_id=legacy.get("user_id"),
            is_super_admin=bool(legacy.get("is_super_admin")),
            device_id=legacy.get("updated_by_device"),
            reason="legacy_snapshot_migration",
        )
    cur.execute("drop table if exists seleto_sync_snapshots")


def pull_snapshot(body: dict[str, Any]) -> tuple[int, dict[str, Any]]:
    scope_key, _, _, _ = scope_from_body(body)
    with get_db().connect() as conn:
        with conn.cursor() as cur:
            response = scope_response(cur, scope_key, include_payload=True)
    return HTTPStatus.OK, {"status": "ok", "scopeKey": scope_key, **response}


def status_snapshot(body: dict[str, Any]) -> tuple[int, dict[str, Any]]:
    scope_key, _, _, _ = scope_from_body(body)
    with get_db().connect() as conn:
        with conn.cursor() as cur:
            response = scope_response(cur, scope_key, include_payload=False)
    return HTTPStatus.OK, {"status": "ok", "scopeKey": scope_key, **response}


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
            cur.execute("select pg_advisory_xact_lock(hashtext(%s))", (scope_key,))
            remote_payload = payload_from_tables(cur, scope_key)
            remote_hash_before = payload_hash(remote_payload) if has_rows(remote_payload) else None
            if remote_hash_before and expected_remote_hash and expected_remote_hash != remote_hash_before and not force:
                conn.rollback()
                return HTTPStatus.CONFLICT, {
                    "status": "conflict",
                    "scopeKey": scope_key,
                    "message": "Dados remotos mudaram. Baixe antes de sobrescrever.",
                    "payload": remote_payload,
                    "payloadHash": remote_hash_before,
                }
            revision = replace_payload_scope(
                cur,
                local_payload,
                scope_key=scope_key,
                tenant_id=tenant_id,
                user_id=user_id,
                is_super_admin=is_super_admin,
                device_id=device_id,
                reason=str(reason) if reason is not None else None,
            )
            stored_payload = payload_from_tables(cur, scope_key)
            stored_hash = payload_hash(stored_payload)
            audit_event(
                cur,
                scope_key=scope_key,
                device_id=device_id,
                user_id=user_id,
                status="uploaded",
                local_hash=local_hash,
                remote_hash_before=remote_hash_before,
                remote_hash_after=stored_hash,
                revision=revision,
                reason=str(reason) if reason is not None else None,
            )
        conn.commit()
    return HTTPStatus.OK, {"status": "uploaded", "scopeKey": scope_key, "payloadHash": stored_hash, "revision": revision, "serverTime": utc_now_iso()}


def sync_snapshot(body: dict[str, Any]) -> tuple[int, dict[str, Any]]:
    scope_key, tenant_id, user_id, is_super_admin = scope_from_body(body)
    device_id = str(body.get("deviceId") or body.get("device_id") or "")
    reason = body.get("reason")
    last_remote_hash = body.get("lastRemoteHash") or body.get("last_remote_hash")
    prefer_local_on_first_sync = bool(body.get("preferLocalOnFirstSync", body.get("prefer_local_on_first_sync", False)))
    local_payload = normalize_payload(body.get("payload") or body.get("localPayload"))
    local_hash = payload_hash(local_payload)

    with get_db().connect() as conn:
        with conn.cursor() as cur:
            cur.execute("select pg_advisory_xact_lock(hashtext(%s))", (scope_key,))
            remote_payload = payload_from_tables(cur, scope_key)
            remote_hash = payload_hash(remote_payload) if has_rows(remote_payload) else None

            status = "idle"
            result_payload = local_payload
            result_hash = local_hash
            revision = 0
            should_store = False

            if remote_hash is None:
                if has_rows(local_payload):
                    status = "uploaded"
                    should_store = True
                else:
                    result_payload = None
                    result_hash = None
            elif prefer_local_on_first_sync and last_remote_hash is None and has_rows(local_payload):
                status = "merged"
                result_payload = merge_payloads(local_payload, remote_payload)
                result_hash = payload_hash(result_payload)
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
                revision = replace_payload_scope(
                    cur,
                    result_payload,
                    scope_key=scope_key,
                    tenant_id=tenant_id,
                    user_id=user_id,
                    is_super_admin=is_super_admin,
                    device_id=device_id,
                    reason=str(reason) if reason is not None else None,
                    prune_missing=False,
                )
                result_payload = payload_from_tables(cur, scope_key)
                result_hash = payload_hash(result_payload)
            else:
                existing_scope = scope_row(cur, scope_key)
                revision = 0 if existing_scope is None else int(existing_scope.get("revision") or 0)

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

    return HTTPStatus.OK, {"status": status, "scopeKey": scope_key, "payload": result_payload, "payloadHash": result_hash, "revision": revision, "serverTime": utc_now_iso()}


def user_is_super_admin(cur, user: dict[str, Any]) -> bool:
    if bool(user.get("isSuperuser")):
        return True
    user_id = str(user.get("id") or "")
    if not user_id:
        return False
    cur.execute(
        "select 1 from user_permissions where user_id = %s and permission in ('*', 'system.super_admin') limit 1",
        (user_id,),
    )
    return cur.fetchone() is not None


def find_login_snapshot(body: dict[str, Any]) -> tuple[int, dict[str, Any]]:
    username = str(body.get("username") or "").strip().lower()
    device_id = str(body.get("deviceId") or body.get("device_id") or "")
    if not username:
        return HTTPStatus.BAD_REQUEST, {"status": "erro", "message": "Informe username para consulta de login."}

    with get_db().connect() as conn:
        with conn.cursor() as cur:
            cur.execute("select * from users where username = %s limit 1", (username,))
            user_row = cur.fetchone()
            if user_row is None:
                return HTTPStatus.OK, {"status": "ok", "exists": False}
            user = row_to_payload(TABLE_BY_COLLECTION["users"], user_row)
            tenant_id = str(user.get("tenantId") or DEFAULT_TENANT_ID)
            is_super_admin = user_is_super_admin(cur, user)
            scope_key = "super_admin" if is_super_admin else f"tenant_{tenant_id}"
            payload = payload_from_tables(cur, scope_key)
            payload_hash_value = payload_hash(payload) if has_rows(payload) else None
            scope = scope_row(cur, scope_key)
            audit_event(
                cur,
                scope_key=scope_key,
                device_id=device_id,
                user_id=str(user.get("id") or ""),
                status="login_snapshot",
                local_hash=None,
                remote_hash_before=payload_hash_value,
                remote_hash_after=payload_hash_value,
                revision=0 if scope is None else int(scope.get("revision") or 0),
                reason="login",
            )
        conn.commit()
    return HTTPStatus.OK, {
        "status": "ok",
        "exists": True,
        "scopeKey": scope_key,
        "tenantId": tenant_id,
        "userId": user.get("id"),
        "isSuperAdmin": is_super_admin,
        "payload": payload,
        "payloadHash": payload_hash_value,
        "revision": 0 if scope is None else scope.get("revision"),
    }


def active_presence_rows(cur, *, scope_key: str, tenant_id: str, is_super_admin: bool) -> list[dict[str, Any]]:
    cur.execute(
        """
        update seleto_user_presence
           set is_online = false, updated_at = now()
         where is_online = true
           and (last_seen_at is null or last_seen_at < now() - (%s * interval '1 second'))
        """,
        (PRESENCE_ONLINE_WINDOW_SECONDS,),
    )
    where_sql = "p.is_online = true and p.last_seen_at >= now() - (%s * interval '1 second')"
    params: list[Any] = [PRESENCE_ONLINE_WINDOW_SECONDS]
    if not is_super_admin:
        where_sql += " and p.tenant_id = %s"
        params.append(tenant_id)
    cur.execute(
        f"""
        select
          p.user_id,
          p.tenant_id,
          p.scope_key,
          p.device_id,
          p.is_super_admin,
          p.last_seen_at,
          p.updated_at,
          p.app_state,
          u.display_name,
          u.username
        from seleto_user_presence p
        left join users u on u.id = p.user_id
        where {where_sql}
        order by p.last_seen_at desc, p.user_id
        """,
        params,
    )
    return cur.fetchall()


def presence_payload(cur, *, scope_key: str, tenant_id: str, is_super_admin: bool) -> dict[str, Any]:
    active_users = []
    for row in active_presence_rows(
        cur,
        scope_key=scope_key,
        tenant_id=tenant_id,
        is_super_admin=is_super_admin,
    ):
        active_users.append(
            {
                "userId": row.get("user_id"),
                "tenantId": row.get("tenant_id"),
                "scopeKey": row.get("scope_key"),
                "deviceId": row.get("device_id"),
                "isSuperAdmin": row.get("is_super_admin"),
                "lastSeenAt": json_value(row.get("last_seen_at")),
                "updatedAt": json_value(row.get("updated_at")),
                "appState": row.get("app_state"),
                "displayName": row.get("display_name"),
                "username": row.get("username"),
            }
        )
    return {
        "onlineWindowSeconds": PRESENCE_ONLINE_WINDOW_SECONDS,
        "activeUsers": active_users,
    }


def update_presence(body: dict[str, Any]) -> tuple[int, dict[str, Any]]:
    scope_key, tenant_id, scoped_user_id, is_super_admin = scope_from_body(body)
    user_id = str(body.get("userId") or body.get("user_id") or scoped_user_id or "").strip()
    device_id = str(body.get("deviceId") or body.get("device_id") or "").strip()
    state = str(body.get("state") or "online").strip().lower()
    app_state = str(body.get("appState") or body.get("app_state") or state).strip()[:40]
    is_online = state not in {"offline", "signed_out", "logout", "logged_out"}
    if not user_id:
        return HTTPStatus.BAD_REQUEST, {"status": "erro", "message": "Informe userId para atualizar presenca."}

    with get_db().connect() as conn:
        with conn.cursor() as cur:
            cur.execute("select pg_advisory_xact_lock(hashtext(%s))", (f"presence:{user_id}",))
            if is_online:
                cur.execute(
                    """
                    insert into seleto_user_presence (
                      user_id, tenant_id, scope_key, device_id, is_super_admin,
                      is_online, last_seen_at, updated_at, app_state
                    ) values (%s, %s, %s, %s, %s, true, now(), now(), %s)
                    on conflict (user_id) do update set
                      tenant_id = excluded.tenant_id,
                      scope_key = excluded.scope_key,
                      device_id = excluded.device_id,
                      is_super_admin = excluded.is_super_admin,
                      is_online = true,
                      last_seen_at = now(),
                      updated_at = now(),
                      app_state = excluded.app_state
                    """,
                    (user_id, tenant_id, scope_key, device_id, is_super_admin, app_state),
                )
                cur.execute("update users set last_seen_at = now() where id = %s", (user_id,))
            else:
                cur.execute(
                    """
                    insert into seleto_user_presence (
                      user_id, tenant_id, scope_key, device_id, is_super_admin,
                      is_online, last_offline_at, updated_at, app_state
                    ) values (%s, %s, %s, %s, %s, false, now(), now(), %s)
                    on conflict (user_id) do update set
                      tenant_id = excluded.tenant_id,
                      scope_key = excluded.scope_key,
                      device_id = excluded.device_id,
                      is_super_admin = excluded.is_super_admin,
                      is_online = false,
                      last_offline_at = now(),
                      updated_at = now(),
                      app_state = excluded.app_state
                    """,
                    (user_id, tenant_id, scope_key, device_id, is_super_admin, app_state),
                )
            payload = presence_payload(
                cur,
                scope_key=scope_key,
                tenant_id=tenant_id,
                is_super_admin=is_super_admin,
            )
        conn.commit()

    return HTTPStatus.OK, {
        "status": "online" if is_online else "offline",
        "scopeKey": scope_key,
        "tenantId": tenant_id,
        "userId": user_id,
        "serverTime": utc_now_iso(),
        **payload,
    }


def server_health_payload() -> tuple[int, dict[str, Any]]:
    started = time.time()
    with get_db().connect() as conn:
        with conn.cursor() as cur:
            cur.execute("select 1 as ok")
            cur.fetchone()
            cur.execute("select count(*) as total from users")
            users_total = int(cur.fetchone()["total"])
            cur.execute("select count(*) as total from seleto_sync_scopes")
            scopes_total = int(cur.fetchone()["total"])
            cur.execute(
                """
                select count(*) as total
                  from seleto_user_presence
                 where is_online = true
                   and last_seen_at >= now() - (%s * interval '1 second')
                """,
                (PRESENCE_ONLINE_WINDOW_SECONDS,),
            )
            online_total = int(cur.fetchone()["total"])
    return HTTPStatus.OK, {
        "status": "ok",
        "service": "seleto-sync",
        "model": "table_by_table",
        "port": PORT,
        "database": "ok",
        "users": users_total,
        "scopes": scopes_total,
        "onlineUsers": online_total,
        "presenceOnlineWindowSeconds": PRESENCE_ONLINE_WINDOW_SECONDS,
        "uptimeSeconds": round(time.time() - STARTED_AT, 2),
        "latencyMs": round((time.time() - started) * 1000, 2),
        "serverTime": utc_now_iso(),
    }


class SyncHandler(BaseHTTPRequestHandler):
    server_version = "SeletoSync/2.0"

    def log_message(self, fmt: str, *args: Any) -> None:
        sys.stdout.write("%s %s\n" % (datetime.now().isoformat(timespec="seconds"), fmt % args))
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
            self._send_json(HTTPStatus.SERVICE_UNAVAILABLE, {"status": "erro", "message": "SELETO_SYNC_TOKEN nao configurado no servidor."})
            return False
        auth = self.headers.get("Authorization", "")
        token = self.headers.get("X-Seleto-Sync-Token", "")
        if auth.startswith("Bearer "):
            token = auth.removeprefix("Bearer ").strip()
        if token != SYNC_TOKEN:
            self._send_json(HTTPStatus.UNAUTHORIZED, {"status": "erro", "message": "Token de sincronizacao invalido."})
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
            status, payload = server_health_payload()
            payload["latencyMs"] = round((time.time() - started) * 1000, 2)
            self._send_json(status, payload)
        except Exception as exc:
            self._send_json(HTTPStatus.SERVICE_UNAVAILABLE, {"status": "erro", "database": "erro", "message": str(exc)})

    def do_POST(self) -> None:
        if not self._authorized():
            return
        parsed = urlparse(self.path)
        try:
            body = self._read_json()
            if parsed.path == "/sync/v1/health":
                status, payload = server_health_payload()
            elif parsed.path == "/sync/v1/pull":
                status, payload = pull_snapshot(body)
            elif parsed.path == "/sync/v1/status":
                status, payload = status_snapshot(body)
            elif parsed.path == "/sync/v1/push":
                status, payload = push_snapshot(body)
            elif parsed.path == "/sync/v1/sync":
                status, payload = sync_snapshot(body)
            elif parsed.path == "/sync/v1/login":
                status, payload = find_login_snapshot(body)
            elif parsed.path == "/sync/v1/presence":
                status, payload = update_presence(body)
            else:
                query = parse_qs(parsed.query)
                status, payload = HTTPStatus.NOT_FOUND, {"status": "erro", "message": "Rota nao encontrada.", "path": parsed.path, "query": query}
            self._send_json(status, payload)
        except json.JSONDecodeError:
            self._send_json(HTTPStatus.BAD_REQUEST, {"status": "erro", "message": "JSON invalido."})
        except ValueError as exc:
            self._send_json(HTTPStatus.BAD_REQUEST, {"status": "erro", "message": str(exc)})
        except Exception as exc:
            traceback.print_exc()
            self._send_json(HTTPStatus.INTERNAL_SERVER_ERROR, {"status": "erro", "message": str(exc)})


def main() -> int:
    if not SYNC_TOKEN and not ALLOW_NO_TOKEN:
        print("ERRO: defina SELETO_SYNC_TOKEN antes de iniciar o servidor publico.", file=sys.stderr)
        print("Para ambiente local isolado, use SELETO_SYNC_ALLOW_NO_TOKEN=true.", file=sys.stderr)
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
