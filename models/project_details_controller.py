from typing import Callable, Optional

from PySide6.QtCore import QObject, Slot

from db.database import DatabaseManager


class ProjectDetailsController(QObject):
    def __init__(
        self,
        db: DatabaseManager,
        refresh_all: Callable[[], None],
        parent: Optional[QObject] = None,
    ):
        super().__init__(parent)
        self.db = db
        self._refresh_all = refresh_all

    @Slot(int, str, result=bool)
    def add_tag_to_project(self, project_id: int, tag: str) -> bool:
        project = self.db.get_project_by_id(project_id)
        if project:
            tags = self.db._parse_tags(project.get("tags", ""))
            if tag not in tags:
                tags.append(tag)
                result = self.db.update_project(
                    project_id,
                    project["title"],
                    project["client_name"],
                    project["client_email"],
                    project["status"],
                    project["deadline"],
                    project["description"],
                    project.get("price", 0),
                    project.get("paid_amount", 0),
                    project.get("currency", "USD"),
                    ", ".join(tags),
                    project.get("company_id"),
                    project.get("is_personal", True) == 1,
                )
                self._refresh_all()
                return result
        return False

    @Slot(int, float, str, str, str, str, result=int)
    @Slot(int, float, str, str, result=int)
    def add_payment(
        self,
        project_id: int,
        amount: float,
        currency: str = "USD",
        payment_date: str = "",
        payment_method: str = "",
        description: str = "",
    ) -> int:
        payment_id = self.db.add_payment(
            project_id, amount, currency, payment_date, payment_method, description
        )
        self._refresh_all()
        return payment_id

    @Slot(int, float, str, str, str, str, result=bool)
    @Slot(int, float, str, str, result=bool)
    def update_payment(
        self,
        payment_id: int,
        amount: float,
        currency: str = "USD",
        payment_date: str = "",
        payment_method: str = "",
        description: str = "",
    ) -> bool:
        result = self.db.update_payment(
            payment_id, amount, currency, payment_date, payment_method, description
        )
        self._refresh_all()
        return result

    @Slot(int, result=bool)
    def delete_payment(self, payment_id: int) -> bool:
        result = self.db.delete_payment(payment_id)
        self._refresh_all()
        return result

    @Slot(int, int, str, str, str, str, result=int)
    @Slot(int, str, str, str, str, result=int)
    @Slot(str, str, str, str, result=int)
    def add_blocker(
        self,
        project_id: int = -1,
        step_id: int = -1,
        title: str = "",
        description: str = "",
        severity: str = "medium",
        status: str = "open",
    ) -> int:
        blocker_id = self.db.add_blocker(
            project_id if project_id > 0 else None,
            step_id if step_id > 0 else None,
            title,
            description,
            severity,
            status,
        )
        self._refresh_all()
        return blocker_id

    @Slot(int, str, str, str, str, result=bool)
    def update_blocker(
        self,
        blocker_id: int,
        title: str = "",
        description: str = "",
        severity: str = "medium",
        status: str = "open",
    ) -> bool:
        result = self.db.update_blocker(
            blocker_id, title, description, severity, status
        )
        self._refresh_all()
        return result

    @Slot(int, result=bool)
    def delete_blocker(self, blocker_id: int) -> bool:
        result = self.db.delete_blocker(blocker_id)
        self._refresh_all()
        return result

    @Slot(int, str, str, bool, result=int)
    @Slot(int, str, str, result=int)
    @Slot(int, str, result=int)
    def add_step(
        self,
        project_id: int,
        title: str,
        deadline: str = "",
        completed: bool = False,
    ) -> int:
        step_id = self.db.add_step(project_id, title, deadline, completed)
        self._refresh_all()
        return step_id

    @Slot(int, str, str, result=bool)
    def update_step(self, step_id: int, title: str, deadline: str = "") -> bool:
        result = self.db.update_step(step_id, title, deadline)
        self._refresh_all()
        return result

    @Slot(int, bool, result=bool)
    def toggle_step(self, step_id: int, completed: bool) -> bool:
        result = self.db.toggle_step_completion(step_id, completed)
        self._refresh_all()
        return result

    @Slot(int, result=bool)
    def delete_step(self, step_id: int) -> bool:
        result = self.db.delete_step(step_id)
        self._refresh_all()
        return result

    @Slot(int, str, str, bool, result=int)
    @Slot(int, str, str, result=int)
    @Slot(int, str, result=int)
    def add_deliverable(
        self,
        project_id: int,
        title: str,
        deadline: str = "",
        completed: bool = False,
    ) -> int:
        deliverable_id = self.db.add_deliverable(project_id, title, deadline, completed)
        self._refresh_all()
        return deliverable_id

    @Slot(int, str, str, result=bool)
    def update_deliverable(
        self, deliverable_id: int, title: str, deadline: str = ""
    ) -> bool:
        result = self.db.update_deliverable(deliverable_id, title, deadline)
        self._refresh_all()
        return result

    @Slot(int, bool, result=bool)
    def toggle_deliverable(self, deliverable_id: int, completed: bool) -> bool:
        result = self.db.toggle_deliverable_completion(deliverable_id, completed)
        self._refresh_all()
        return result

    @Slot(int, result=bool)
    def delete_deliverable(self, deliverable_id: int) -> bool:
        result = self.db.delete_deliverable(deliverable_id)
        self._refresh_all()
        return result

    @Slot(int, str, str, str, result=int)
    def add_resource(
        self, project_id: int, res_type: str, title: str, path_or_content: str
    ) -> int:
        resource_id = self.db.add_resource(
            project_id, res_type, title, path_or_content
        )
        self._refresh_all()
        return resource_id

    @Slot(int, str, str, str, result=bool)
    def update_resource(
        self, resource_id: int, res_type: str, title: str, path_or_content: str
    ) -> bool:
        result = self.db.update_resource(
            resource_id, res_type, title, path_or_content
        )
        self._refresh_all()
        return result

    @Slot(int, result=bool)
    def delete_resource(self, resource_id: int) -> bool:
        result = self.db.delete_resource(resource_id)
        self._refresh_all()
        return result
