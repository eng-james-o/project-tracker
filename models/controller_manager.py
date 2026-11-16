from typing import Optional

from PySide6.QtCore import QObject

from db.audit_database import AuditDatabaseManager
from db.database import DatabaseManager
from models.ai_controller import AIController
from models.clipboard_controller import ClipboardController
from models.dashboard_controller import DashboardController
from models.notification_controller import NotificationController
from models.planning_controller import PlanningController
from models.profile_controller import ProfileController
from models.project_controller import ProjectController
from models.project_details_controller import ProjectDetailsController
from models.tag_controller import TagController
from models.template_controller import TemplateController


class ControllerManager:
    def __init__(
        self,
        db_path: str = "project_tracker.db",
        audit_db_path: str = "audit_tracker.db",
        parent: Optional[QObject] = None,
    ):
        self.audit_db = AuditDatabaseManager(db_path=audit_db_path, max_rows=500)
        self.db = DatabaseManager(db_path=db_path, audit_db_manager=self.audit_db)
        self.clipboard_controller = ClipboardController(parent)
        self.project_controller = ProjectController(self.db, self.refresh_all, parent)
        self.project_details_controller = ProjectDetailsController(
            self.db, self.refresh_all, parent
        )
        self.planning_controller = PlanningController(self.db, parent)
        self.profile_controller = ProfileController(self.db, parent)
        self.dashboard_controller = DashboardController(
            self.db,
            self.audit_db,
            self.project_controller.get_projects,
            self.project_controller.get_selected_project_id,
            parent,
        )
        self.tag_controller = TagController(self.db, parent)
        self.template_controller = TemplateController(self.db, parent)
        self.notification_controller = NotificationController(self.db, parent)
        self.ai_controller = AIController(parent)
        self.project_controller.on_selection_changed = (
            self.dashboard_controller.refresh_audit_logs
        )
        self.planning_controller.on_goals_changed = (
            self.dashboard_controller.refresh_dashboard
        )
        self.refresh_all()

    def refresh_all(self):
        self.project_controller.refresh_projects()
        self.project_controller.refresh_all_tags()
        self.tag_controller._refresh_all_tags()
        self.template_controller.refresh_templates()
        self.dashboard_controller.refresh_dashboard()
        self.planning_controller.refresh_project_ideas()
        self.planning_controller.refresh_goals()
        self.profile_controller.refresh_user_profile()
        self.profile_controller.refresh_companies()
        self.project_controller.refresh_selected_project()
        self.dashboard_controller.refresh_audit_logs()
