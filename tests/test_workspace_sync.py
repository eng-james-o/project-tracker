from uuid import uuid4

import pytest

from db.audit_database import AuditDatabaseManager
from db.database import DatabaseManager
from models.workspace_sync import KINDS, WorkspaceAccountMismatch, WorkspaceSync


def workspace(tmp_path, name):
    audit = AuditDatabaseManager(db_path=str(tmp_path / f"{name}-audit.sqlite"))
    return DatabaseManager(str(tmp_path / f"{name}.sqlite"), audit)


def empty_snapshot():
    return {kind: [] for kind in KINDS}


def cloud_row(change, version=1):
    return dict(change["data"], id=change["id"], version=version, deleted_at=None)


def test_sync_round_trip_preserves_concurrent_edit_and_local_files(tmp_path):
    desktop = workspace(tmp_path, "desktop")
    other_device = workspace(tmp_path, "other")
    sync = WorkspaceSync(desktop)
    with desktop.get_connection() as conn:
        parent = conn.execute("INSERT INTO projects(title) VALUES ('Survey')").lastrowid
        conn.execute("INSERT INTO steps(project_id,title) VALUES (?, 'Plan')", (parent,))
        conn.execute("""INSERT INTO resources(project_id,type,title,path_or_content) VALUES
            (?, 'link', 'Docs', 'https://example.org/docs'),
            (?, 'document', 'Local PDF', 'C:/Notes/example.pdf')""", (parent, parent))

    writes, pulled, conflicts = sync.prepare("owner", empty_snapshot())
    assert (pulled, conflicts) == (0, 0)
    assert [change["kind"] for change in writes] == ["projects", "steps", "resources"]
    snapshot = empty_snapshot()
    for change in writes:
        snapshot[change["kind"]].append(cloud_row(change))
    sync.acknowledge(writes, [dict(kind=row["kind"], id=row["id"], version=1) for row in writes])

    assert WorkspaceSync(other_device).prepare("owner", snapshot) == ([], 3, 0)
    with other_device.get_connection() as conn:
        assert conn.execute("SELECT count(*) FROM resources").fetchone()[0] == 1
        assert conn.execute("SELECT title FROM steps").fetchone()[0] == "Plan"

    with desktop.get_connection() as conn:
        conn.execute("UPDATE projects SET title='Local edit' WHERE id=?", (parent,))
    snapshot["projects"][0].update(title="Cloud edit", version=2)
    assert sync.prepare("owner", snapshot) == ([], 0, 1)
    with desktop.get_connection() as conn:
        assert conn.execute("SELECT title FROM projects WHERE id=?", (parent,)).fetchone()[0] == "Local edit"

    with pytest.raises(WorkspaceAccountMismatch):
        sync.prepare("different account", empty_snapshot())


def test_cloud_project_deletion_preserves_desktop_only_values(tmp_path):
    db = workspace(tmp_path, "desktop")
    sync = WorkspaceSync(db)
    snapshot = empty_snapshot()
    row = dict(id=str(uuid4()), version=1, deleted_at=None, title="Survey", description="",
               client_name="", client_email="", status="active", due_date=None)
    snapshot["projects"].append(row)
    assert sync.prepare("owner", snapshot) == ([], 1, 0)
    with db.get_connection() as conn:
        conn.execute("UPDATE projects SET price=700")
    row.update(version=2, deleted_at="2026-11-24T00:00:00Z")
    assert sync.prepare("owner", snapshot) == ([], 0, 1)
    with db.get_connection() as conn:
        assert conn.execute("SELECT price FROM projects").fetchone()[0] == 700
        conn.execute("UPDATE projects SET price=0")
    assert sync.prepare("owner", snapshot) == ([], 1, 0)
