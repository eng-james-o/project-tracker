import os
import sqlite3
from typing import Any, Dict, cast
import pytest
from db.database import DatabaseManager
from db.audit_database import AuditDatabaseManager
from models.controller_manager import ControllerManager
from models.profile_controller import ProfileController
from models.planning_controller import PlanningController

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
    controllers = ControllerManager(db_path=db_path, audit_db_path=audit_path)
    controller = controllers.project_controller
    details_controller = controllers.project_details_controller

    pid = controller.add_project("Mobile App", "TechCorp", "t@tech.com", "active", "2026-12-31", "Desc")
    controller.load_project_details(pid)

    # Add and Edit Step
    sid = details_controller.add_step(pid, "Initial Step", "2026-09-01")
    details_controller.update_step(sid, "Revised Step Title", "2026-09-15")
    step = [s for s in controller.selectedProject['steps'] if s['id'] == sid][0]
    assert step['title'] == "Revised Step Title"
    assert step['deadline'] == "2026-09-15"

    # Add and Edit Deliverable
    did = details_controller.add_deliverable(pid, "Design Spec", "2026-09-10")
    details_controller.update_deliverable(did, "Final Spec PDF", "2026-09-20")
    deliv = [d for d in controller.selectedProject['deliverables'] if d['id'] == did][0]
    assert deliv['title'] == "Final Spec PDF"

    # Add and Edit Resource
    rid = details_controller.add_resource(pid, "link", "Figma", "https://figma.com")
    details_controller.update_resource(rid, "link", "Figma V2", "https://figma.com/v2")
    res = [r for r in controller.selectedProject['resources'] if r['id'] == rid][0]
    assert res['title'] == "Figma V2"
    assert res['path_or_content'] == "https://figma.com/v2"

def test_profile_name_and_employment_history_migration(test_dbs):
    db_path, audit_path = test_dbs
    conn = sqlite3.connect(db_path)
    conn.execute("""
        CREATE TABLE user_profiles (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT DEFAULT '',
            gender TEXT DEFAULT '',
            email TEXT DEFAULT '',
            jobs TEXT DEFAULT '',
            companies TEXT DEFAULT '',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)
    conn.execute(
        "INSERT INTO user_profiles (name, jobs, companies) VALUES (?, ?, ?)",
        ("Jordan Lee", "Designer, Developer", "Studio One, Studio Two"),
    )
    conn.commit()
    conn.close()

    audit_db = AuditDatabaseManager(db_path=audit_path)
    db = DatabaseManager(db_path=db_path, audit_db_manager=audit_db)
    controller = ProfileController(db)
    controller.refresh_user_profile()
    legacy_profile = cast(Dict[str, Any], controller.userProfile)
    assert legacy_profile["first_name"] == "Jordan"
    assert legacy_profile["last_name"] == "Lee"
    assert legacy_profile["employment_history"] == [
        {"job": "Designer", "company": "Studio One"},
        {"job": "Developer", "company": "Studio Two"},
    ]

    assert controller.save_profile(
        legacy_profile["id"],
        "Jordan",
        "Lee",
        "Jordy",
        "",
        "jordan@example.com",
        '[{"job":"Designer","company":"Studio One"},{"job":"Developer","company":"Studio Two"}]',
    )
    saved_profile = db.get_user_profile_by_id(legacy_profile["id"])
    assert saved_profile is not None
    assert saved_profile["first_name"] == "Jordan"
    assert saved_profile["last_name"] == "Lee"
    assert saved_profile["nickname"] == "Jordy"
    assert saved_profile["jobs"] == "Designer, Developer"
    assert saved_profile["companies"] == "Studio One, Studio Two"

    controller.refresh_companies()
    assert controller.projectCompanyNames == [
        "Personal",
        "Studio One",
        "Studio Two",
    ]
    company_id = controller.companyIdForName("Studio One")
    assert company_id > 0
    assert controller.companyNameForId(company_id) == "Studio One"

    project_id = db.add_project(
        "Studio project", company_id=company_id, is_personal=False
    )
    project = db.get_project_by_id(project_id)
    assert project is not None
    assert project["company_id"] == company_id
    assert project["is_personal"] == 0

def test_planning_controller_normalizes_display_statuses(test_dbs):
    db_path, audit_path = test_dbs
    db = DatabaseManager(
        db_path=db_path,
        audit_db_manager=AuditDatabaseManager(db_path=audit_path),
    )
    controller = PlanningController(db)

    idea_id = controller.add_project_idea(
        "Idea", status="In Progress", priority="High"
    )
    idea = next(item for item in db.get_project_ideas() if item["id"] == idea_id)
    assert idea["status"] == "in_progress"
    assert idea["priority"] == "high"
    assert controller.update_project_idea(
        idea_id, "Idea revised", status="Completed"
    )
    updated_idea = db.get_project_idea_by_id(idea_id)
    assert updated_idea is not None
    assert updated_idea["status"] == "completed"

    goal_id = controller.add_goal(
        "Goal", goal_type="Weekly", status="In Progress", priority="High"
    )
    goal = next(item for item in db.get_goals() if item["id"] == goal_id)
    assert goal["goal_type"] == "weekly"
    assert goal["status"] == "in_progress"
    assert goal["priority"] == "high"
