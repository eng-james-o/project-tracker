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

    @Slot(int, int, result=bool)
    def reorder_step(self, step_id: int, target_step_id: int) -> bool:
        # Get all steps for the project
        target_step = self.db.get_step_by_id(target_step_id)
        if not target_step:
            return False
        
        # Get all steps for the same project
        steps = self.db.get_steps(target_step['project_id'])
        
        # Find the dragged step
        dragged_step = None
        for step in steps:
            if step['id'] == step_id:
                dragged_step = step
                break
        
        if not dragged_step:
            return False
        
        # Find the target step and its position
        target_position = None
        for i, step in enumerate(steps):
            if step['id'] == target_step_id:
                target_position = i
                break
        
        if target_position is None:
            return False
        
        # Reorder all steps
        for i, step in enumerate(steps):
            if step['id'] == step_id:
                # This is the dragged step, give it the target position
                self.db.reorder_step(step['id'], target_position)
            elif i == target_position:
                # This is the target step, move it to where the dragged step was
                self.db.reorder_step(step['id'], steps.index(dragged_step))
            else:
                # Keep the same position
                self.db.reorder_step(step['id'], i)
        
        self._refresh_all()
        return True

    @Slot(int, int, result=bool)
    def reorder_deliverable(self, deliverable_id: int, target_deliverable_id: int) -> bool:
        # Get all deliverables for the project
        target_deliverable = self.db.get_deliverable_by_id(target_deliverable_id)
        if not target_deliverable:
            return False
        
        # Get all deliverables for the same project
        deliverables = self.db.get_deliverables(target_deliverable['project_id'])
        
        # Find the dragged deliverable
        dragged_deliverable = None
        for deliverable in deliverables:
            if deliverable['id'] == deliverable_id:
                dragged_deliverable = deliverable
                break
        
        if not dragged_deliverable:
            return False
        
        # Find the target deliverable and its position
        target_position = None
        for i, deliverable in enumerate(deliverables):
            if deliverable['id'] == target_deliverable_id:
                target_position = i
                break
        
        if target_position is None:
            return False
        
        # Reorder all deliverables
        for i, deliverable in enumerate(deliverables):
            if deliverable['id'] == deliverable_id:
                # This is the dragged deliverable, give it the target position
                self.db.reorder_deliverable(deliverable['id'], target_position)
            elif i == target_position:
                # This is the target deliverable, move it to where the dragged deliverable was
                self.db.reorder_deliverable(deliverable['id'], deliverables.index(dragged_deliverable))
            else:
                # Keep the same position
                self.db.reorder_deliverable(deliverable['id'], i)
        
        self._refresh_all()
        return True

    @Slot(int, result=Dict)
    def get_step_by_id(self, step_id: int) -> Optional[Dict]:
        return self.db.get_step_by_id(step_id)

    @Slot(int, result=Dict)
    def get_deliverable_by_id(self, deliverable_id: int) -> Optional[Dict]:
        return self.db.get_deliverable_by_id(deliverable_id)
