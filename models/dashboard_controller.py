from typing import Any, Callable, Dict, List, Optional

from PySide6.QtCore import QObject, Property, Signal, Slot

from db.audit_database import AuditDatabaseManager
from db.database import DatabaseManager


class DashboardController(QObject):
    dashboardStatsChanged = Signal()
    upcomingDeadlinesChanged = Signal()
    auditLogsChanged = Signal()
    maxAuditRowsChanged = Signal()

    def __init__(
        self,
        db: DatabaseManager,
        audit_db: AuditDatabaseManager,
        get_projects: Callable[[], List[Dict[str, Any]]],
        get_selected_project_id: Callable[[], Optional[int]],
        parent: Optional[QObject] = None,
    ):
        super().__init__(parent)
        self.db = db
        self.audit_db = audit_db
        self._get_projects = get_projects
        self._dashboard_stats: Dict[str, Any] = {}
        self._upcoming_deadlines: List[Dict[str, Any]] = []
        self._audit_logs: List[Dict[str, Any]] = []
        self._get_selected_project_id = get_selected_project_id

    @Slot()
    def refresh_dashboard(self):
        self._dashboard_stats = self.db.get_dashboard_stats()
        self._upcoming_deadlines = self.db.get_upcoming_deadlines()
        self.dashboardStatsChanged.emit()
        self.upcomingDeadlinesChanged.emit()

    @Slot()
    def refresh_audit_logs(self):
        self._audit_logs = self.audit_db.get_audit_logs(
            project_id=self._get_selected_project_id(),
            limit=100,
        )
        self.auditLogsChanged.emit()

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

    @Slot(result=dict)
    def get_financial_stats(self) -> Dict[str, Any]:
        projects = self._get_projects()
        total_revenue = sum(project.get("price", 0) for project in projects)
        total_paid = sum(project.get("paid_amount", 0) for project in projects)
        return {
            "total_revenue": total_revenue,
            "total_paid": total_paid,
            "total_outstanding": total_revenue - total_paid,
        }
