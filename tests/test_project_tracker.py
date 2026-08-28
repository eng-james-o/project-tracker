import os
import pytest
from db.database import DatabaseManager
from db.audit_database import AuditDatabaseManager
from models.project_controller import ProjectController

@pytest.fixture
def test_dbs(tmp_path):
    db_path = os.path.join(tmp_path, "test_project_tracker.db")
    audit_path = os.path.join(tmp_path, "test_audit_tracker.db")
    yield db_path, audit_path
    if os.path.exists(db_path):
        os.remove(db_path)
    if os.path.exists(audit_path):
        os.remove(audit_path)

def test_database_and_audit_db_compression_and_cap(test_dbs):
    db_path, audit_path = test_dbs
    audit_db = AuditDatabaseManager(db_path=audit_path, max_rows=5)
    db = DatabaseManager(db_path=db_path, audit_db_manager=audit_db)

    # Add project
    pid = db.add_project("Web App Redesign", "Acme", "a@acme.com", "active", "2026-12-31", "Description")
    assert pid > 0

    # Repeat same action to test compression into single row with repeat_count
    db.update_step(1, "Updated Title", "2026-10-01")
    audit_db.log_audit(pid, "step", 1, "UPDATE", "Modified step 'Wireframing'")
    audit_db.log_audit(pid, "step", 1, "UPDATE", "Modified step 'Wireframing'")
    audit_db.log_audit(pid, "step", 1, "UPDATE", "Modified step 'Wireframing'")

    logs = audit_db.get_audit_logs(pid)
    compressed_log = [l for l in logs if l['details'] == "Modified step 'Wireframing'"][0]
    assert compressed_log['repeat_count'] == 3

    # Add 10 items to test row cap (max_rows=5)
    for i in range(10):
        audit_db.log_audit(pid, "test", i, "TEST", f"Test log entry {i}")

    all_logs = audit_db.get_audit_logs()
    assert len(all_logs) <= 5

def test_step_deliverable_resource_editing(test_dbs):
    db_path, audit_path = test_dbs
    controller = ProjectController(db_path=db_path, audit_db_path=audit_path)

    pid = controller.add_project("Mobile App", "TechCorp", "t@tech.com", "active", "2026-12-31", "Desc")
    controller.load_project_details(pid)

    # Add and Edit Step
    sid = controller.add_step(pid, "Initial Step", "2026-09-01")
    controller.update_step(sid, "Revised Step Title", "2026-09-15")
    step = [s for s in controller.selectedProject['steps'] if s['id'] == sid][0]
    assert step['title'] == "Revised Step Title"
    assert step['deadline'] == "2026-09-15"

    # Add and Edit Deliverable
    did = controller.add_deliverable(pid, "Design Spec", "2026-09-10")
    controller.update_deliverable(did, "Final Spec PDF", "2026-09-20")
    deliv = [d for d in controller.selectedProject['deliverables'] if d['id'] == did][0]
    assert deliv['title'] == "Final Spec PDF"

    # Add and Edit Resource
    rid = controller.add_resource(pid, "link", "Figma", "https://figma.com")
    controller.update_resource(rid, "link", "Figma V2", "https://figma.com/v2")
    res = [r for r in controller.selectedProject['resources'] if r['id'] == rid][0]
    assert res['title'] == "Figma V2"
    assert res['path_or_content'] == "https://figma.com/v2"
