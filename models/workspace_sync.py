"""Merge Project Tracker's shared records using stable IDs and cloud versions."""

import json
import uuid
from datetime import date, datetime

FIELDS = {
    "projects": ("title", "description", "client_name", "client_email", "status", "due_date"),
    "steps": ("project_id", "title", "completed", "due_date"),
    "deliverables": ("project_id", "title", "completed", "due_date"),
    "resources": ("project_id", "title", "type", "path_or_content"),
}
KINDS = tuple(FIELDS)


class WorkspaceAccountMismatch(Exception):
    """This local workspace has already been bound to another cloud account."""


def project_date(value):
    try:
        return date.fromisoformat((value or "")[:10]).isoformat()
    except ValueError:
        return None


def portable(row):
    return row["type"] in ("note", "markdown") or (
        row["type"] == "link" and row["path_or_content"].lower().startswith(("https://", "http://"))
    )


def encode(value):
    return json.dumps(value, sort_keys=True, ensure_ascii=False, separators=(",", ":"))


class WorkspaceSync:
    def __init__(self, database):
        self.database = database

    def prepare(self, owner, snapshot):
        if set(snapshot) != set(KINDS) or any(not isinstance(snapshot[k], list) for k in KINDS):
            raise ValueError("Invalid cloud snapshot")
        with self.database.get_connection() as conn:
            conn.execute("BEGIN IMMEDIATE")
            conn.execute("""CREATE TABLE IF NOT EXISTS tracker_sync_account
                          (id INTEGER PRIMARY KEY CHECK(id=1), owner TEXT NOT NULL)""")
            conn.execute("""CREATE TABLE IF NOT EXISTS tracker_sync_records (
                kind TEXT NOT NULL, local_id INTEGER NOT NULL, remote_id TEXT NOT NULL,
                version INTEGER NOT NULL, baseline TEXT NOT NULL,
                PRIMARY KEY(kind, local_id), UNIQUE(kind, remote_id))""")
            account = conn.execute("SELECT owner FROM tracker_sync_account WHERE id=1").fetchone()
            if account and account["owner"] != owner:
                raise WorkspaceAccountMismatch()
            if not account:
                conn.execute("INSERT INTO tracker_sync_account VALUES (1, ?)", (owner,))
            self._assign_ids(conn)

            conflicts = 0
            downloaded = 0
            received = {}
            for deleted, order in ((False, KINDS), (True, reversed(KINDS))):
                for kind in order:
                    for row in snapshot[kind]:
                        if (row["deleted_at"] is not None) != deleted:
                            continue
                        data = None if deleted else self._cloud_payload(kind, row)
                        key = (kind, row["id"])
                        received[key] = (row["version"], data)
                        mapping = self._mapping(conn, *key)
                        if mapping is None:
                            if data is None:
                                continue
                            local_id = self._apply(conn, kind, None, data)
                            if local_id is None:
                                conflicts += 1
                            else:
                                conn.execute("INSERT INTO tracker_sync_records VALUES (?,?,?,?,?)",
                                             (kind, local_id, row["id"], row["version"], encode(data)))
                                downloaded += 1
                            continue
                        local = self._local(conn, kind, mapping["local_id"])
                        baseline = json.loads(mapping["baseline"])
                        if local == data:
                            self._mark(conn, kind, row["id"], row["version"], data)
                        elif data != baseline:
                            if local != baseline or self._apply(conn, kind, mapping["local_id"], data) is None:
                                conflicts += 1
                            else:
                                self._mark(conn, kind, row["id"], row["version"], data)
                                downloaded += 1

            writes = []
            for mapping in conn.execute("SELECT * FROM tracker_sync_records"):
                kind, remote_id = mapping["kind"], mapping["remote_id"]
                current = self._local(conn, kind, mapping["local_id"])
                baseline = json.loads(mapping["baseline"])
                cloud = received.get((kind, remote_id))
                if cloud is None:
                    if mapping["version"] != 0:
                        conflicts += 1
                    elif current is not None:
                        writes.append(dict(kind=kind, id=remote_id, version=0, data=current))
                elif cloud[1] == baseline and current != baseline:
                    writes.append(dict(kind=kind, id=remote_id, version=cloud[0], data=current))

            writes.sort(key=lambda row: (
                row["data"] is None, KINDS.index(row["kind"]) * (-1 if row["data"] is None else 1)
            ))
            return writes, downloaded, conflicts

    def acknowledge(self, batch, receipts):
        expected = {(row["kind"], row["id"]): row for row in batch}
        if len(receipts) != len(expected) or {(r["kind"], r["id"]) for r in receipts} != expected.keys():
            raise ValueError("Invalid sync receipts")
        with self.database.get_connection() as conn:
            for row in receipts:
                sent = expected[(row["kind"], row["id"])]
                self._mark(conn, row["kind"], row["id"], row["version"], sent["data"])

    @staticmethod
    def _mapping(conn, kind, remote_id):
        return conn.execute("SELECT * FROM tracker_sync_records WHERE kind=? AND remote_id=?",
                            (kind, remote_id)).fetchone()

    @staticmethod
    def _mark(conn, kind, remote_id, version, data):
        conn.execute("UPDATE tracker_sync_records SET version=?, baseline=? WHERE kind=? AND remote_id=?",
                     (version, encode(data), kind, remote_id))

    @staticmethod
    def _assign_ids(conn):
        for kind in KINDS:
            rows = conn.execute(f"""SELECT t.* FROM {kind} t WHERE NOT EXISTS (
                SELECT 1 FROM tracker_sync_records m WHERE m.kind=? AND m.local_id=t.id
            )""", (kind,))
            for row in rows:
                if kind == "resources" and not portable(row):
                    continue
                conn.execute("INSERT INTO tracker_sync_records VALUES (?,?,?,0,'null')",
                             (kind, row["id"], str(uuid.uuid4())))

    @staticmethod
    def _cloud_payload(kind, row):
        data = {field: row[field] for field in FIELDS[kind]}
        if kind == "projects" and data["status"] == "archived":
            data["status"] = "paused"
        return data

    def _local(self, conn, kind, local_id):
        row = conn.execute(f"SELECT * FROM {kind} WHERE id=?", (local_id,)).fetchone()
        if row is None or (kind == "resources" and not portable(row)):
            return None
        data = {}
        for field in FIELDS[kind]:
            if field == "project_id":
                project = conn.execute("SELECT remote_id FROM tracker_sync_records WHERE kind='projects' AND local_id=?",
                                       (row["project_id"],)).fetchone()
                if not project:
                    raise ValueError("Child lacks a mapped project")
                data[field] = project["remote_id"]
            elif field == "due_date":
                data[field] = project_date(row["deadline"])
            elif field == "completed":
                data[field] = bool(row[field])
            else:
                data[field] = row[field] or ""
        return data

    def _apply(self, conn, kind, local_id, data):
        if data is None:
            if kind == "projects" and not self._can_delete_project(conn, local_id):
                return None
            if kind == "steps" and conn.execute(
                "SELECT 1 FROM blockers WHERE step_id=? LIMIT 1", (local_id,)
            ).fetchone():
                return None
            if kind == "resources":
                row = conn.execute("SELECT * FROM resources WHERE id=?", (local_id,)).fetchone()
                if row and not portable(row):
                    return local_id
            conn.execute(f"DELETE FROM {kind} WHERE id=?", (local_id,))
            return local_id
        if kind == "resources" and not portable(data):
            return None
        values = dict(data)
        if "project_id" in values:
            project = self._mapping(conn, "projects", values["project_id"])
            if not project or not conn.execute("SELECT 1 FROM projects WHERE id=?", (project["local_id"],)).fetchone():
                return None
            values["project_id"] = project["local_id"]
        if "due_date" in values:
            values["deadline"] = values.pop("due_date") or ""
        values["updated_at"] = datetime.now().isoformat()
        if local_id is None:
            slots = ",".join("?" for _ in values)
            cursor = conn.execute(f"INSERT INTO {kind} ({','.join(values)}) VALUES ({slots})", tuple(values.values()))
            return cursor.lastrowid
        if kind == "resources":
            row = conn.execute("SELECT * FROM resources WHERE id=?", (local_id,)).fetchone()
            if row and not portable(row):
                return None
        assignments = ",".join(f"{field}=?" for field in values)
        cursor = conn.execute(f"UPDATE {kind} SET {assignments} WHERE id=?", (*values.values(), local_id))
        if cursor.rowcount == 0:
            columns = ",".join(values)
            slots = ",".join("?" for _ in values)
            conn.execute(f"INSERT INTO {kind} (id,{columns}) VALUES (?,{slots})", (local_id, *values.values()))
        return local_id

    @staticmethod
    def _can_delete_project(conn, local_id):
        project = conn.execute("SELECT * FROM projects WHERE id=?", (local_id,)).fetchone()
        if not project:
            return True
        if any(project[k] for k in ("price", "paid_amount", "tags", "company_id")):
            return False
        return not any(conn.execute(f"SELECT 1 FROM {kind} WHERE project_id=? LIMIT 1", (local_id,)).fetchone()
                       for kind in ("steps", "deliverables", "resources", "blockers", "payments"))
