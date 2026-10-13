from PySide6.QtCore import QObject, Signal, Slot, Property, QVariant
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
    userProfileChanged = Signal()
    projectIdeasChanged = Signal()
    goalsChanged = Signal()
    allTagsChanged = Signal()
    companiesChanged = Signal()

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
        self._user_profile: Dict[str, Any] = {}
        self._project_ideas: List[Dict[str, Any]] = []
        self._goals: List[Dict[str, Any]] = []
        self._all_tags: List[str] = []
        self._companies: List[Dict[str, Any]] = []
        self._project_ideas_filter = "all"
        self._project_ideas_search = ""
        self._goals_type_filter = "all"
        self._goals_status_filter = "all"
        self._goals_search = ""

        self.refresh_all()

    @Slot()
    def refresh_all(self):
        self.refresh_projects()
        self.refresh_dashboard()
        self.refresh_audit_logs()
        self.refresh_user_profile()
        self.refresh_project_ideas()
        self.refresh_goals()
        self.refresh_all_tags()
        self.refresh_companies()
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
    def refresh_user_profile(self):
        profiles = self.db.get_user_profiles()
        self._user_profile = profiles[0] if profiles else {}
        self.userProfileChanged.emit()

    @Slot()
    def refresh_project_ideas(self):
        self._project_ideas = self.db.get_project_ideas(
            status_filter=self._project_ideas_filter,
            search=self._project_ideas_search
        )
        self.projectIdeasChanged.emit()

    @Slot()
    def refresh_goals(self):
        self._goals = self.db.get_goals(
            goal_type_filter=self._goals_type_filter,
            status_filter=self._goals_status_filter,
            search=self._goals_search
        )
        self.goalsChanged.emit()

    @Slot()
    def refresh_all_tags(self):
        self._all_tags = self.db.get_all_tags()
        self.allTagsChanged.emit()

    @Slot()
    def refresh_companies(self):
        self._companies = self.db.get_companies()
        self.companiesChanged.emit()

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

    @Property(dict, notify=userProfileChanged)
    def userProfile(self):
        return self._user_profile

    @Property(list, notify=projectIdeasChanged)
    def projectIdeas(self):
        return self._project_ideas

    @Property(list, notify=goalsChanged)
    def goals(self):
        return self._goals

    @Property(list, notify=allTagsChanged)
    def allTags(self):
        return self._all_tags

    @Property(list, notify=companiesChanged)
    def companies(self):
        return self._companies

    @Slot(int)
    def setMaxAuditRows(self, limit: int):
        if limit > 0:
            self.audit_db.set_max_rows(limit)
            self.maxAuditRowsChanged.emit()

    @Slot()
    def clearAuditLogs(self):
        self.audit_db.clear_audit_logs()
        self.refresh_audit_logs()

    # --- User Profile Actions ---
    @Slot(str, str, str, str, str, result=int)
    def add_user_profile(self, name: str, gender: str, email: str, jobs: str, companies: str) -> int:
        pid = self.db.add_user_profile(name, gender, email, jobs, companies)
        self.refresh_user_profile()
        return pid

    @Slot(int, str, str, str, str, str, result=bool)
    def update_user_profile(self, profile_id: int, name: str, gender: str, email: str, jobs: str, companies: str) -> bool:
        res = self.db.update_user_profile(profile_id, name, gender, email, jobs, companies)
        self.refresh_user_profile()
        return res

    # --- Company Actions ---
    @Slot(str, str, result=int)
    def add_company(self, name: str, description: str = "") -> int:
        cid = self.db.add_company(name, description)
        self.refresh_companies()
        return cid

    # --- Project Actions with new fields ---
    @Slot(int)
    def load_project_details(self, project_id: int):
        proj = self.db.get_project_by_id(project_id)
        if proj:
            self._selected_project = proj
            self.selectedProjectChanged.emit()
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
    @Slot(str, str, str, str, str, str, float, float, str, str, int, bool, result=int)
    @Slot(str, str, str, str, str, str, result=int)
    def add_project(self, title: str, client_name: str, client_email: str, status: str, deadline: str, description: str,
                    price: float = 0.0, paid_amount: float = 0.0, currency: str = "USD", tags: str = "",
                    company_id: int = -1, is_personal: bool = True) -> int:
        pid = self.db.add_project(title, client_name, client_email, status, deadline, description,
                                   price, paid_amount, currency, tags, company_id if company_id > 0 else None, is_personal)
        self.refresh_all()
        return pid

    @Slot(int, str, str, str, str, str, str, float, float, str, str, int, bool, result=bool)
    @Slot(int, str, str, str, str, str, str, result=bool)
    def update_project(self, project_id: int, title: str, client_name: str, client_email: str, status: str, deadline: str, description: str,
                       price: float = 0.0, paid_amount: float = 0.0, currency: str = "USD", tags: str = "",
                       company_id: int = -1, is_personal: bool = True) -> bool:
        res = self.db.update_project(project_id, title, client_name, client_email, status, deadline, description,
                                      price, paid_amount, currency, tags, company_id if company_id > 0 else None, is_personal)
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

    # --- Payment Actions ---
    @Slot(int, float, str, str, str, str, result=int)
    @Slot(int, float, str, str, result=int)
    def add_payment(self, project_id: int, amount: float, currency: str = "USD", payment_date: str = "",
                    payment_method: str = "", description: str = "") -> int:
        pid = self.db.add_payment(project_id, amount, currency, payment_date, payment_method, description)
        self.refresh_all()
        return pid

    @Slot(int, float, str, str, str, str, result=bool)
    @Slot(int, float, str, str, result=bool)
    def update_payment(self, payment_id: int, amount: float, currency: str = "USD", payment_date: str = "",
                       payment_method: str = "", description: str = "") -> bool:
        res = self.db.update_payment(payment_id, amount, currency, payment_date, payment_method, description)
        self.refresh_all()
        return res

    @Slot(int, result=bool)
    def delete_payment(self, payment_id: int) -> bool:
        res = self.db.delete_payment(payment_id)
        self.refresh_all()
        return res

    # --- Blocker Actions ---
    @Slot(int, int, str, str, str, str, result=int)
    @Slot(int, str, str, str, str, result=int)
    @Slot(str, str, str, str, result=int)
    def add_blocker(self, project_id: int = -1, step_id: int = -1, title: str = "", description: str = "",
                    severity: str = "medium", status: str = "open") -> int:
        bid = self.db.add_blocker(
            project_id if project_id > 0 else None,
            step_id if step_id > 0 else None,
            title, description, severity, status
        )
        self.refresh_all()
        return bid

    @Slot(int, str, str, str, str, result=bool)
    def update_blocker(self, blocker_id: int, title: str = "", description: str = "",
                       severity: str = "medium", status: str = "open") -> bool:
        res = self.db.update_blocker(blocker_id, title, description, severity, status)
        self.refresh_all()
        return res

    @Slot(int, result=bool)
    def delete_blocker(self, blocker_id: int) -> bool:
        res = self.db.delete_blocker(blocker_id)
        self.refresh_all()
        return res

    # --- Project Idea Actions ---
    @Slot(str, str, str, str, str, float, str, result=int)
    @Slot(str, str, str, result=int)
    def add_project_idea(self, title: str, description: str = "", status: str = "idea",
                         priority: str = "medium", tags: str = "", estimated_budget: float = 0.0,
                         estimated_timeline: str = "") -> int:
        iid = self.db.add_project_idea(title, description, status, priority, tags, estimated_budget, estimated_timeline)
        self.refresh_project_ideas()
        return iid

    @Slot(int, str, str, str, str, str, float, str, result=bool)
    @Slot(int, str, str, result=bool)
    def update_project_idea(self, idea_id: int, title: str, description: str = "", status: str = "idea",
                            priority: str = "medium", tags: str = "", estimated_budget: float = 0.0,
                            estimated_timeline: str = "") -> bool:
        res = self.db.update_project_idea(idea_id, title, description, status, priority, tags, estimated_budget, estimated_timeline)
        self.refresh_project_ideas()
        return res

    @Slot(int, result=bool)
    def delete_project_idea(self, idea_id: int) -> bool:
        res = self.db.delete_project_idea(idea_id)
        self.refresh_project_ideas()
        return res

    @Slot(str)
    def setProjectIdeasFilter(self, status: str):
        if self._project_ideas_filter != status:
            self._project_ideas_filter = status
            self.refresh_project_ideas()

    @Slot(str)
    def setProjectIdeasSearch(self, search: str):
        if self._project_ideas_search != search:
            self._project_ideas_search = search
            self.refresh_project_ideas()

    # --- Goal Actions ---
    @Slot(str, str, str, str, str, str, str, bool, result=int)
    @Slot(str, str, str, result=int)
    def add_goal(self, title: str, description: str = "", goal_type: str = "daily",
                 target_date: str = "", status: str = "pending", priority: str = "medium",
                 tags: str = "", is_recurring: bool = False) -> int:
        gid = self.db.add_goal(title, description, goal_type, target_date, status, priority, tags, is_recurring)
        self.refresh_goals()
        return gid

    @Slot(int, str, str, str, str, str, str, str, bool, result=bool)
    @Slot(int, str, str, result=bool)
    def update_goal(self, goal_id: int, title: str, description: str = "", goal_type: str = "daily",
                    target_date: str = "", status: str = "pending", priority: str = "medium",
                    tags: str = "", is_recurring: bool = False) -> bool:
        res = self.db.update_goal(goal_id, title, description, goal_type, target_date, status, priority, tags, is_recurring)
        self.refresh_goals()
        return res

    @Slot(int, result=bool)
    def delete_goal(self, goal_id: int) -> bool:
        res = self.db.delete_goal(goal_id)
        self.refresh_goals()
        return res

    @Slot(str)
    def setGoalsTypeFilter(self, goal_type: str):
        if self._goals_type_filter != goal_type:
            self._goals_type_filter = goal_type
            self.refresh_goals()

    @Slot(str)
    def setGoalsStatusFilter(self, status: str):
        if self._goals_status_filter != status:
            self._goals_status_filter = status
            self.refresh_goals()

    @Slot(str)
    def setGoalsSearch(self, search: str):
        if self._goals_search != search:
            self._goals_search = search
            self.refresh_goals()

    # --- Tag Actions ---
    @Slot(str, result=bool)
    def add_tag_to_project(self, project_id: int, tag: str) -> bool:
        proj = self.db.get_project_by_id(project_id)
        if proj:
            tags_list = self.db._parse_tags(proj.get('tags', ''))
            if tag not in tags_list:
                tags_list.append(tag)
                tags_str = ', '.join(tags_list)
                res = self.db.update_project(project_id, proj['title'], proj['client_name'],
                                              proj['client_email'], proj['status'], proj['deadline'],
                                              proj['description'], proj.get('price', 0), proj.get('paid_amount', 0),
                                              proj.get('currency', 'USD'), tags_str, proj.get('company_id'),
                                              proj.get('is_personal', True) == 1)
                self.refresh_all()
                return res
        return False

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

    # --- Dashboard stats with new metrics ---
    @Slot(result=dict)
    def get_financial_stats(self) -> Dict[str, Any]:
        total_revenue = sum(p.get('price', 0) for p in self._projects)
        total_paid = sum(p.get('paid_amount', 0) for p in self._projects)
        total_outstanding = total_revenue - total_paid
        return {
            'total_revenue': total_revenue,
            'total_paid': total_paid,
            'total_outstanding': total_outstanding
        }
