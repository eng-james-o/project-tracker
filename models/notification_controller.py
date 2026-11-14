from typing import Any, Dict, List, Optional
from datetime import datetime, timedelta

from PySide6.QtCore import QObject, Property, Signal, Slot, QTimer, QDateTime
from PySide6.QtGui import QSystemTrayIcon, QIcon

from db.database import DatabaseManager


class NotificationController(QObject):
    notificationsChanged = Signal()
    newNotification = Signal(str, str)

    def __init__(
        self,
        db: DatabaseManager,
        parent: Optional[QObject] = None,
    ):
        super().__init__(parent)
        self.db = db
        self._notifications: List[Dict[str, Any]] = []
        self._tray_icon = None
        self._check_timer = QTimer()
        self._check_timer.timeout.connect(self.check_upcoming_deadlines)
        self._check_timer.start(60000)  # Check every minute
        
        # Initialize tray icon
        self._init_tray_icon()

    def _init_tray_icon(self):
        self._tray_icon = QSystemTrayIcon(QIcon("assets/app-icon.svg"), parent=None)
        self._tray_icon.setToolTip("Project Tracker")
        self._tray_icon.show()

    @Slot()
    def check_upcoming_deadlines(self):
        now = datetime.now()
        
        # Check projects with deadlines in the next 24 hours
        projects = self.db.get_projects()
        for project in projects:
            if project.get('deadline'):
                deadline = datetime.strptime(project['deadline'], '%Y-%m-%d')
                time_diff = deadline - now
                
                if timedelta(0) < time_diff <= timedelta(hours=24):
                    self._show_notification(
                        f"Project Deadline: {project['title']}",
                        f"Project '{project['title']}' is due in {time_diff.total_seconds() / 3600:.1f} hours"
                    )
        
        # Check steps with deadlines in the next 24 hours
        for project in projects:
            steps = self.db.get_steps(project['id'])
            for step in steps:
                if step.get('deadline') and not step.get('completed'):
                    deadline = datetime.strptime(step['deadline'], '%Y-%m-%d')
                    time_diff = deadline - now
                    
                    if timedelta(0) < time_diff <= timedelta(hours=24):
                        self._show_notification(
                            f"Step Deadline: {step['title']}",
                            f"Step '{step['title']}' in project '{project['title']}' is due in {time_diff.total_seconds() / 3600:.1f} hours"
                        )
        
        # Check deliverables with deadlines in the next 24 hours
        for project in projects:
            deliverables = self.db.get_deliverables(project['id'])
            for deliverable in deliverables:
                if deliverable.get('deadline') and not deliverable.get('completed'):
                    deadline = datetime.strptime(deliverable['deadline'], '%Y-%m-%d')
                    time_diff = deadline - now
                    
                    if timedelta(0) < time_diff <= timedelta(hours=24):
                        self._show_notification(
                            f"Deliverable Deadline: {deliverable['title']}",
                            f"Deliverable '{deliverable['title']}' in project '{project['title']}' is due in {time_diff.total_seconds() / 3600:.1f} hours"
                        )

    def _show_notification(self, title: str, message: str):
        # Add to notifications list
        notification = {
            'title': title,
            'message': message,
            'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
            'read': False
        }
        self._notifications.insert(0, notification)
        self.notificationsChanged.emit()
        
        # Show desktop notification
        if self._tray_icon:
            self._tray_icon.showMessage(title, message)
        
        # Emit signal for QML
        self.newNotification.emit(title, message)

    @Property(list, notify=notificationsChanged)
    def notifications(self) -> List[Dict[str, Any]]:
        return self._notifications

    @Slot()
    def mark_all_as_read(self):
        for notification in self._notifications:
            notification['read'] = True
        self.notificationsChanged.emit()

    @Slot(int)
    def mark_as_read(self, index: int):
        if 0 <= index < len(self._notifications):
            self._notifications[index]['read'] = True
            self.notificationsChanged.emit()

    @Slot()
    def clear_notifications(self):
        self._notifications = []
        self.notificationsChanged.emit()

    @Slot(str, str)
    def show_custom_notification(self, title: str, message: str):
        self._show_notification(title, message)
