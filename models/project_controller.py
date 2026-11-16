from typing import Any, Callable, Dict, List, Optional

from PySide6.QtCore import QObject, Property, Signal, Slot

from db.database import DatabaseManager


class ProjectController(QObject):
    projectsChanged = Signal()
    selectedProjectChanged = Signal()
    allTagsChanged = Signal()
    tagFilterChanged = Signal()

    def __init__(
        self,
        db: DatabaseManager,
        refresh_all: Callable[[], None],
        parent: Optional[QObject] = None,
    ):
        super().__init__(parent)
        self.db = db
        self._refresh_all = refresh_all
        self.on_selection_changed: Optional[Callable[[], None]] = None
        self._projects: List[Dict[str, Any]] = []
        self._selected_project: Dict[str, Any] = {}
        self._all_tags: List[str] = []
        self._status_filter = "all"
        self._search_text = ""
        self._tag_filter: List[str] = []

    @Slot()
    def refresh_projects(self):
        if self._tag_filter:
            # Filter by tags
            projects_by_tags = self.db.get_projects_by_tags(self._tag_filter)
            all_projects = self.db.get_projects(
                status_filter=self._status_filter,
                search=self._search_text,
            )
            # Intersect the two lists
            self._projects = [
                p for p in all_projects
                if any(p['id'] == tp['id'] for tp in projects_by_tags)
            ]
        else:
            self._projects = self.db.get_projects(
                status_filter=self._status_filter,
                search=self._search_text,
            )
        self.projectsChanged.emit()

    @Slot()
    def refresh_all_tags(self):
        self._all_tags = self.db.get_all_tags()
        self.allTagsChanged.emit()

    @Slot()
    def refresh_selected_project(self):
        project_id = self._selected_project.get("id")
        if project_id is not None:
            project = self.db.get_project_by_id(project_id)
            if project:
                self._selected_project = project
                self.selectedProjectChanged.emit()

    def get_projects(self) -> List[Dict[str, Any]]:
        return self._projects

    def get_selected_project_id(self) -> Optional[int]:
        project_id = self._selected_project.get("id")
        return project_id if isinstance(project_id, int) else None

    @Property(list, notify=projectsChanged)
    def projects(self):
        return self._projects

    @Property(dict, notify=selectedProjectChanged)
    def selectedProject(self):
        return self._selected_project

    @Property(list, notify=allTagsChanged)
    def allTags(self):
        return self._all_tags

    @Property(list, notify=tagFilterChanged)
    def tagFilter(self) -> List[str]:
        return self._tag_filter

    @Slot(int)
    def load_project_details(self, project_id: int):
        project = self.db.get_project_by_id(project_id)
        if project:
            self._selected_project = project
            self.selectedProjectChanged.emit()
            if self.on_selection_changed:
                self.on_selection_changed()

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

    @Slot(list)
    def setTagFilter(self, tags: List[str]):
        if self._tag_filter != tags:
            self._tag_filter = tags
            self.tagFilterChanged.emit()
            self.refresh_projects()

    @Slot(str)
    def addTagFilter(self, tag: str):
        if tag not in self._tag_filter:
            self._tag_filter.append(tag)
            self.tagFilterChanged.emit()
            self.refresh_projects()

    @Slot(str)
    def removeTagFilter(self, tag: str):
        if tag in self._tag_filter:
            self._tag_filter.remove(tag)
            self.tagFilterChanged.emit()
            self.refresh_projects()

    @Slot()
    def clearTagFilter(self):
        self._tag_filter = []
        self.tagFilterChanged.emit()
        self.refresh_projects()

    @Slot(str, str, str, str, str, str, float, float, str, str, int, bool, result=int)
    @Slot(str, str, str, str, str, str, result=int)
    def add_project(
        self,
        title: str,
        client_name: str,
        client_email: str,
        status: str,
        deadline: str,
        description: str,
        price: float = 0.0,
        paid_amount: float = 0.0,
        currency: str = "USD",
        tags: str = "",
        company_id: int = -1,
        is_personal: bool = True,
    ) -> int:
        project_id = self.db.add_project(
            title,
            client_name,
            client_email,
            status,
            deadline,
            description,
            price,
            paid_amount,
            currency,
            tags,
            company_id if company_id > 0 else None,
            is_personal,
        )
        self._refresh_all()
        return project_id

    @Slot(int, str, str, str, str, str, str, float, float, str, str, int, bool, result=bool)
    @Slot(int, str, str, str, str, str, str, result=bool)
    def update_project(
        self,
        project_id: int,
        title: str,
        client_name: str,
        client_email: str,
        status: str,
        deadline: str,
        description: str,
        price: float = 0.0,
        paid_amount: float = 0.0,
        currency: str = "USD",
        tags: str = "",
        company_id: int = -1,
        is_personal: bool = True,
    ) -> bool:
        result = self.db.update_project(
            project_id,
            title,
            client_name,
            client_email,
            status,
            deadline,
            description,
            price,
            paid_amount,
            currency,
            tags,
            company_id if company_id > 0 else None,
            is_personal,
        )
        self._refresh_all()
        return result

    @Slot(int, str, result=bool)
    def update_project_status(self, project_id: int, status: str) -> bool:
        result = self.db.update_project_status(project_id, status)
        self._refresh_all()
        return result

    @Slot(int, result=bool)
    def delete_project(self, project_id: int) -> bool:
        result = self.db.delete_project(project_id)
        if self._selected_project.get("id") == project_id:
            self._selected_project = {}
            self.selectedProjectChanged.emit()
        self._refresh_all()
        return result
