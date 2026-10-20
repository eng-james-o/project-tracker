from typing import Any, Callable, Dict, List, Optional

from PySide6.QtCore import QObject, Property, Signal, Slot

from db.database import DatabaseManager


class PlanningController(QObject):
    projectIdeasChanged = Signal()
    goalsChanged = Signal()

    def __init__(self, db: DatabaseManager, parent: Optional[QObject] = None):
        super().__init__(parent)
        self.db = db
        self._project_ideas: List[Dict[str, Any]] = []
        self._goals: List[Dict[str, Any]] = []
        self._project_ideas_filter = "all"
        self._project_ideas_search = ""
        self._goals_type_filter = "all"
        self._goals_status_filter = "all"
        self._goals_search = ""
        self.on_goals_changed: Optional[Callable[[], None]] = None

    @Slot()
    def refresh_project_ideas(self):
        self._project_ideas = self.db.get_project_ideas(
            status_filter=self._project_ideas_filter,
            search=self._project_ideas_search,
        )
        self.projectIdeasChanged.emit()

    @Slot()
    def refresh_goals(self):
        self._goals = self.db.get_goals(
            goal_type_filter=self._goals_type_filter,
            status_filter=self._goals_status_filter,
            search=self._goals_search,
        )
        self.goalsChanged.emit()

    @Property(list, notify=projectIdeasChanged)
    def projectIdeas(self):
        return self._project_ideas

    @Property(list, notify=goalsChanged)
    def goals(self):
        return self._goals

    @staticmethod
    def _normalize_choice(value: str) -> str:
        return "_".join(value.strip().lower().split())

    @Slot(str, str, str, str, str, float, str, result=int)
    @Slot(str, str, str, result=int)
    def add_project_idea(
        self,
        title: str,
        description: str = "",
        status: str = "idea",
        priority: str = "medium",
        tags: str = "",
        estimated_budget: float = 0.0,
        estimated_timeline: str = "",
    ) -> int:
        idea_id = self.db.add_project_idea(
            title,
            description,
            self._normalize_choice(status),
            self._normalize_choice(priority),
            tags,
            estimated_budget,
            estimated_timeline,
        )
        self.refresh_project_ideas()
        return idea_id

    @Slot(int, str, str, str, str, str, float, str, result=bool)
    @Slot(int, str, str, result=bool)
    def update_project_idea(
        self,
        idea_id: int,
        title: str,
        description: str = "",
        status: str = "idea",
        priority: str = "medium",
        tags: str = "",
        estimated_budget: float = 0.0,
        estimated_timeline: str = "",
    ) -> bool:
        result = self.db.update_project_idea(
            idea_id,
            title,
            description,
            self._normalize_choice(status),
            self._normalize_choice(priority),
            tags,
            estimated_budget,
            estimated_timeline,
        )
        self.refresh_project_ideas()
        return result

    @Slot(int, result=bool)
    def delete_project_idea(self, idea_id: int) -> bool:
        result = self.db.delete_project_idea(idea_id)
        self.refresh_project_ideas()
        return result

    @Slot(str)
    def setProjectIdeasFilter(self, status: str):
        status = self._normalize_choice(status)
        if self._project_ideas_filter != status:
            self._project_ideas_filter = status
            self.refresh_project_ideas()

    @Slot(str)
    def setProjectIdeasSearch(self, search: str):
        if self._project_ideas_search != search:
            self._project_ideas_search = search
            self.refresh_project_ideas()

    @Slot(str, str, str, str, str, str, str, bool, result=int)
    @Slot(str, str, str, result=int)
    def add_goal(
        self,
        title: str,
        description: str = "",
        goal_type: str = "daily",
        target_date: str = "",
        status: str = "pending",
        priority: str = "medium",
        tags: str = "",
        is_recurring: bool = False,
    ) -> int:
        goal_id = self.db.add_goal(
            title,
            description,
            self._normalize_choice(goal_type),
            target_date,
            self._normalize_choice(status),
            self._normalize_choice(priority),
            tags,
            is_recurring,
        )
        self.refresh_goals()
        if self.on_goals_changed is not None:
            self.on_goals_changed()
        return goal_id

    @Slot(int, str, str, str, str, str, str, str, bool, result=bool)
    @Slot(int, str, str, result=bool)
    def update_goal(
        self,
        goal_id: int,
        title: str,
        description: str = "",
        goal_type: str = "daily",
        target_date: str = "",
        status: str = "pending",
        priority: str = "medium",
        tags: str = "",
        is_recurring: bool = False,
    ) -> bool:
        result = self.db.update_goal(
            goal_id,
            title,
            description,
            self._normalize_choice(goal_type),
            target_date,
            self._normalize_choice(status),
            self._normalize_choice(priority),
            tags,
            is_recurring,
        )
        self.refresh_goals()
        if result and self.on_goals_changed is not None:
            self.on_goals_changed()
        return result

    @Slot(int, result=bool)
    def delete_goal(self, goal_id: int) -> bool:
        result = self.db.delete_goal(goal_id)
        self.refresh_goals()
        if result and self.on_goals_changed is not None:
            self.on_goals_changed()
        return result

    @Slot(str)
    def setGoalsTypeFilter(self, goal_type: str):
        goal_type = self._normalize_choice(goal_type)
        if self._goals_type_filter != goal_type:
            self._goals_type_filter = goal_type
            self.refresh_goals()

    @Slot(str)
    def setGoalsStatusFilter(self, status: str):
        status = self._normalize_choice(status)
        if self._goals_status_filter != status:
            self._goals_status_filter = status
            self.refresh_goals()

    @Slot(str)
    def setGoalsSearch(self, search: str):
        if self._goals_search != search:
            self._goals_search = search
            self.refresh_goals()
