from typing import Any, Callable, Dict, List, Optional

from PySide6.QtCore import QObject, Property, Signal, Slot

from db.database import DatabaseManager


class TemplateController(QObject):
    templatesChanged = Signal()
    selectedTemplateChanged = Signal()

    def __init__(
        self,
        db: DatabaseManager,
        parent: Optional[QObject] = None,
    ):
        super().__init__(parent)
        self.db = db
        self._templates: List[Dict[str, Any]] = []
        self._selected_template: Dict[str, Any] = {}

    @Slot()
    def refresh_templates(self):
        self._templates = self.db.get_all_templates()
        self.templatesChanged.emit()

    @Slot()
    def refresh_selected_template(self):
        template_id = self._selected_template.get("id")
        if template_id is not None:
            template = self.db.get_template_by_id(template_id)
            if template:
                self._selected_template = template
                self.selectedTemplateChanged.emit()

    @Property(list, notify=templatesChanged)
    def templates(self) -> List[Dict[str, Any]]:
        return self._templates

    @Property(dict, notify=selectedTemplateChanged)
    def selectedTemplate(self) -> Dict[str, Any]:
        return self._selected_template

    @Slot(int)
    def load_template(self, template_id: int):
        template = self.db.get_template_by_id(template_id)
        if template:
            self._selected_template = template
            self.selectedTemplateChanged.emit()

    @Slot(str, str, str, result=int)
    def add_template(self, name: str, description: str, structure: str) -> int:
        template_id = self.db.add_template(name, description, structure)
        self.refresh_templates()
        return template_id

    @Slot(int, str, str, str, result=bool)
    def update_template(self, template_id: int, name: str, description: str, structure: str) -> bool:
        result = self.db.update_template(template_id, name, description, structure)
        self.refresh_templates()
        return result

    @Slot(int, result=bool)
    def delete_template(self, template_id: int) -> bool:
        result = self.db.delete_template(template_id)
        if self._selected_template.get("id") == template_id:
            self._selected_template = {}
            self.selectedTemplateChanged.emit()
        self.refresh_templates()
        return result

    @Slot(int, result=Dict[str, Any])
    def clone_project_from_template(self, template_id: int) -> Dict[str, Any]:
        template = self.db.get_template_by_id(template_id)
        if template:
            # Create a new project from the template structure
            import json
            structure = json.loads(template.get('structure', '{}'))
            
            # Create the project with default values
            project_data = {
                'title': structure.get('title', 'Untitled Project'),
                'client_name': structure.get('client_name', ''),
                'client_email': structure.get('client_email', ''),
                'status': structure.get('status', 'active'),
                'deadline': structure.get('deadline', ''),
                'description': structure.get('description', ''),
                'price': structure.get('price', 0.0),
                'paid_amount': structure.get('paid_amount', 0.0),
                'currency': structure.get('currency', 'USD'),
                'tags': structure.get('tags', ''),
                'steps': structure.get('steps', []),
                'deliverables': structure.get('deliverables', []),
            }
            return project_data
        return {}

    @Slot(int, result=Dict[str, Any])
    def clone_project(self, project_id: int) -> Dict[str, Any]:
        project = self.db.get_project_by_id(project_id)
        if project:
            # Create a copy of the project without the ID
            import copy
            project_copy = copy.deepcopy(dict(project))
            # Remove the ID and add a suffix to the title
            if 'id' in project_copy:
                del project_copy['id']
            if 'title' in project_copy:
                project_copy['title'] = project_copy['title'] + " (Copy)"
            if 'status' in project_copy:
                project_copy['status'] = 'active'
            # Convert steps and deliverables to lists if they exist
            if 'steps' in project_copy:
                project_copy['steps'] = [dict(s) for s in project_copy['steps']]
                for step in project_copy['steps']:
                    if 'id' in step:
                        del step['id']
                    step['completed'] = 0
            if 'deliverables' in project_copy:
                project_copy['deliverables'] = [dict(d) for d in project_copy['deliverables']]
                for deliverable in project_copy['deliverables']:
                    if 'id' in deliverable:
                        del deliverable['id']
                    deliverable['completed'] = 0
            return project_copy
        return {}
