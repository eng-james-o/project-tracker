import os
import pytest
from db.database import DatabaseManager
from models.project_controller import ProjectController

@pytest.fixture
def db_file(tmp_path):
    path = os.path.join(tmp_path, "test_project_tracker.db")
    yield path
    if os.path.exists(path):
        os.remove(path)

def test_database_project_crud_and_audit(db_file):
    db = DatabaseManager(db_file)

    # Add project
    pid = db.add_project(
        title="Web App Redesign",
        client_name="Acme Corp",
        client_email="contact@acme.com",
        status="active",
        deadline="2026-10-15",
        description="Redesign client portal"
    )
    assert pid > 0

    # Verify project timestamps and initial audit log
    p = db.get_project_by_id(pid)
    assert p['created_at'] is not None
    assert p['updated_at'] is not None
    assert len(p['audit_logs']) >= 1
    assert "Created project" in p['audit_logs'][0]['details']

    # Update project
    updated = db.update_project(
        pid,
        title="Web App Redesign V2",
        client_name="Acme Corp",
        client_email="contact@acme.com",
        status="paused",
        deadline="2026-11-01",
        description="Updated scope"
    )
    assert updated is True

    p = db.get_project_by_id(pid)
    assert p['title'] == "Web App Redesign V2"
    assert p['status'] == "paused"
    assert len(p['audit_logs']) >= 2

    # Delete project
    deleted = db.delete_project(pid)
    assert deleted is True
    assert db.get_project_by_id(pid) is None

def test_steps_and_deliverables_and_audit_logging(db_file):
    db = DatabaseManager(db_file)
    pid = db.add_project("Mobile App", client_name="TechInc")

    # Add step
    sid = db.add_step(pid, "Wireframing", deadline="2026-09-01")
    assert sid > 0

    # Toggle step completion
    db.toggle_step_completion(sid, True)
    steps = db.get_steps(pid)
    assert steps[0]['completed'] == 1

    # Add deliverable
    did = db.add_deliverable(pid, "Figma Prototype", deadline="2026-09-10")
    assert did > 0

    # Add resource
    rid = db.add_resource(pid, "link", "Design Specs", "https://figma.com/design")
    assert rid > 0

    # Check audit logs
    logs = db.get_audit_logs(pid)
    assert len(logs) == 5  # project create, step create, step toggle, deliverable create, resource create
    details_str = " ".join([l['details'] for l in logs])
    assert "Wireframing" in details_str
    assert "Figma Prototype" in details_str
    assert "Design Specs" in details_str

def test_project_controller_audit_integration(db_file):
    controller = ProjectController(db_path=db_file)
    pid = controller.add_project("Branding Project", "Global Brand", "g@brand.com", "active", "2026-12-01", "Notes")

    controller.load_project_details(pid)
    assert len(controller.auditLogs) >= 1

    sid = controller.add_step(pid, "Initial Logo Concepts", "2026-08-30")
    assert len(controller.auditLogs) >= 2
