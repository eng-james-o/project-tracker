from PySide6.QtCore import QObject, Signal, Slot, Property
from db.database import DatabaseManager
from db.audit_database import AuditDatabaseManager
from typing import List, Dict, Any, Optional

class ProjectController(QObject):
    # Signals to notify QML when data changes
    projectsChanged = Signal()
    selectedProjectChanged = Signal()
    dashboardStatsChanged = Signal()
    upcomingDeadlinesChanged = Signal()
    auditLogsChanged = Signal()
    maxAuditRowsChanged = Signal()

    def __init__(self, db_path: str = "project_tracker.db", audit_db_path: str = "audit_tracker.db", parent=None):
        super().__init__(parent)
        self.audit_db = AuditDatabaseManager(db_path=audit_db_path, max_rows=500)
        self.db = DatabaseManager(db_path=db_path, audit_db_manager=self.audit_db)

        self._projects: List[Dict[str, Any]] = []
        self._selected_project: Dict[str, Any] = {}
        self._dashboard_stats: Dict[str, Any] = {}
        self._upcoming_deadlines: List[Dict[str, Any]] = []
        self._audit_logs: List[Dict[str, Any]] = []
        self._status_filter = "all"
        self._search_text = ""

        self.refresh_all()

    @Slot()
    def refresh_all(self):
        self.refresh_projects()
        self.refresh_dashboard()
        self.refresh_audit_logs()
        if self._selected_project and 'id' in self._selected_project:
            self.load_project_details(self._selected_project['id'])

    @Slot()
    def refresh_projects(self):
        self._projects = self.db.get_projects(
            status_filter=self._status_filter,
            search=self._search_text
        )
        self.projectsChanged.emit()

    @Slot()
    def refresh_dashboard(self):
        self._dashboard_stats = self.db.get_dashboard_stats()
        self._upcoming_deadlines = self.db.get_upcoming_deadlines()
        self.dashboardStatsChanged.emit()
        self.upcomingDeadlinesChanged.emit()

    @Slot()
    def refresh_audit_logs(self):
        pid = self._selected_project.get('id') if self._selected_project else None
        self._audit_logs = self.audit_db.get_audit_logs(project_id=pid, limit=100)
        self.auditLogsChanged.emit()

    # --- Properties exposed to QML ---
    @Property(list, notify=projectsChanged)
    def projects(self):
        return self._projects

    @Property(dict, notify=selectedProjectChanged)
    def selectedProject(self):
        return self._selected_project

    @Property(dict, notify=dashboardStatsChanged)
    def dashboardStats(self):
        return self._dashboard_stats

    @Property(list, notify=upcomingDeadlinesChanged)
    def upcomingDeadlines(self):
        return self._upcoming_deadlines

    @Property(list, notify=auditLogsChanged)
    def auditLogs(self):
        return self._audit_logs

    @Property(int, notify=maxAuditRowsChanged)
    def maxAuditRows(self):
        return self.audit_db.max_rows

    @Slot(int)
    def setMaxAuditRows(self, limit: int):
        if limit > 0:
            self.audit_db.set_max_rows(limit)
            self.maxAuditRowsChanged.emit()

    @Slot()
    def clearAuditLogs(self):
        self.audit_db.clear_audit_logs()
        self.refresh_audit_logs()

    # --- Filtering and Search ---
    @Slot(str)
    def setStatusFilter(self, status: str):
        if self._status_filter != status:
            self._status_filter = status
            self.refresh_projects()

    @Slot(str)
    def setSearchText(self, search: str):
        if self._search_text != search:
            self._search_text = search
            self.refresh_projects()

    # --- Project Actions ---
    @Slot(int)
    def load_project_details(self, project_id: int):
        proj = self.db.get_project_by_id(project_id)
        if proj:
            self._selected_project = proj
            self.selectedProjectChanged.emit()
            self.refresh_audit_logs()

    @Slot(str, str, str, str, str, str, result=int)
    def add_project(self, title: str, client_name: str, client_email: str, status: str, deadline: str, description: str) -> int:
        pid = self.db.add_project(title, client_name, client_email, status, deadline, description)
        self.refresh_all()
        return pid

    @Slot(int, str, str, str, str, str, str, result=bool)
    def update_project(self, project_id: int, title: str, client_name: str, client_email: str, status: str, deadline: str, description: str) -> bool:
        res = self.db.update_project(project_id, title, client_name, client_email, status, deadline, description)
        self.refresh_all()
        return res

    @Slot(int, str, result=bool)
    def update_project_status(self, project_id: int, status: str) -> bool:
        res = self.db.update_project_status(project_id, status)
        self.refresh_all()
        return res

    @Slot(int, result=bool)
    def delete_project(self, project_id: int) -> bool:
        res = self.db.delete_project(project_id)
        if self._selected_project.get('id') == project_id:
            self._selected_project = {}
            self.selectedProjectChanged.emit()
        self.refresh_all()
        return res

    # --- Step Actions ---
    @Slot(int, str, str, bool, result=int)
    @Slot(int, str, str, result=int)
    @Slot(int, str, result=int)
    def add_step(self, project_id: int, title: str, deadline: str = "", completed: bool = False) -> int:
        sid = self.db.add_step(project_id, title, deadline, completed)
        self.refresh_all()
        return sid

    @Slot(int, str, str, result=bool)
    def update_step(self, step_id: int, title: str, deadline: str = "") -> bool:
        res = self.db.update_step(step_id, title, deadline)
        self.refresh_all()
        return res

    @Slot(int, bool, result=bool)
    def toggle_step(self, step_id: int, completed: bool) -> bool:
        res = self.db.toggle_step_completion(step_id, completed)
        self.refresh_all()
        return res

    @Slot(int, result=bool)
    def delete_step(self, step_id: int) -> bool:
        res = self.db.delete_step(step_id)
        self.refresh_all()
        return res

    # --- Deliverable Actions ---
    @Slot(int, str, str, bool, result=int)
    @Slot(int, str, str, result=int)
    @Slot(int, str, result=int)
    def add_deliverable(self, project_id: int, title: str, deadline: str = "", completed: bool = False) -> int:
        did = self.db.add_deliverable(project_id, title, deadline, completed)
        self.refresh_all()
        return did

    @Slot(int, str, str, result=bool)
    def update_deliverable(self, deliverable_id: int, title: str, deadline: str = "") -> bool:
        res = self.db.update_deliverable(deliverable_id, title, deadline)
        self.refresh_all()
        return res

    @Slot(int, bool, result=bool)
    def toggle_deliverable(self, deliverable_id: int, completed: bool) -> bool:
        res = self.db.toggle_deliverable_completion(deliverable_id, completed)
        self.refresh_all()
        return res

    @Slot(int, result=bool)
    def delete_deliverable(self, deliverable_id: int) -> bool:
        res = self.db.delete_deliverable(deliverable_id)
        self.refresh_all()
        return res

    # --- Resource Actions ---
    @Slot(int, str, str, str, result=int)
    def add_resource(self, project_id: int, res_type: str, title: str, path_or_content: str) -> int:
        rid = self.db.add_resource(project_id, res_type, title, path_or_content)
        self.refresh_all()
        return rid

    @Slot(int, str, str, str, result=bool)
    def update_resource(self, resource_id: int, res_type: str, title: str, path_or_content: str) -> bool:
        res = self.db.update_resource(resource_id, res_type, title, path_or_content)
        self.refresh_all()
        return res

    @Slot(int, result=bool)
    def delete_resource(self, resource_id: int) -> bool:
        res = self.db.delete_resource(resource_id)
        self.refresh_all()
        return res
