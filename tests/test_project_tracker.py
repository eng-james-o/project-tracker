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

def test_database_project_crud(db_file):
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

    # Get projects
    projects = db.get_projects()
    assert len(projects) == 1
    assert projects[0]['title'] == "Web App Redesign"
    assert projects[0]['client_name'] == "Acme Corp"
    assert projects[0]['status'] == "active"

    # Get project by id
    p = db.get_project_by_id(pid)
    assert p is not None
    assert p['id'] == pid
    assert p['steps'] == []
    assert p['deliverables'] == []
    assert p['resources'] == []

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

    # Delete project
    deleted = db.delete_project(pid)
    assert deleted is True
    assert db.get_project_by_id(pid) is None

def test_steps_and_deliverables_and_resources(db_file):
    db = DatabaseManager(db_file)
    pid = db.add_project("Mobile App", client_name="TechInc")

    # Add step
    sid = db.add_step(pid, "Wireframing", deadline="2026-09-01")
    assert sid > 0

    steps = db.get_steps(pid)
    assert len(steps) == 1
    assert steps[0]['completed'] == 0

    # Toggle step completion
    db.toggle_step_completion(sid, True)
    steps = db.get_steps(pid)
    assert steps[0]['completed'] == 1

    # Add deliverable
    did = db.add_deliverable(pid, "Figma Prototype", deadline="2026-09-10")
    assert did > 0
    deliverables = db.get_deliverables(pid)
    assert len(deliverables) == 1

    # Add resource
    rid = db.add_resource(pid, "link", "Design Specs", "https://figma.com/design")
    assert rid > 0
    resources = db.get_resources(pid)
    assert len(resources) == 1
    assert resources[0]['type'] == "link"

    # Dashboard upcoming deadlines
    deadlines = db.get_upcoming_deadlines()
    assert len(deadlines) == 1  # Deliverable has deadline 2026-09-10 (step is completed so excluded)
    assert deadlines[0]['item_title'] == "Figma Prototype"

def test_project_controller(db_file):
    controller = ProjectController(db_path=db_file)
    assert len(controller.projects) == 0

    pid = controller.add_project("Branding Project", "Global Brand", "g@brand.com", "active", "2026-12-01", "Notes")
    assert pid > 0
    assert len(controller.projects) == 1
    assert controller.dashboardStats['active'] == 1

    controller.load_project_details(pid)
    assert controller.selectedProject['id'] == pid

    # Add step via controller
    sid = controller.add_step(pid, "Initial Logo Concepts", "2026-08-30")
    assert sid > 0
    assert len(controller.selectedProject['steps']) == 1

    # Toggle step via controller
    controller.toggle_step(sid, True)
    assert controller.selectedProject['steps'][0]['completed'] == 1

    # Search filter
    controller.setSearchText("Nonexistent")
    assert len(controller.projects) == 0

    controller.setSearchText("Branding")
    assert len(controller.projects) == 1
