import sys
import os
from PySide6.QtGui import QGuiApplication, QIcon
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtQuickControls2 import QQuickStyle
from models.project_controller import ProjectController

def main():
    # Use Basic style to allow custom QML background/contentItem overrides on controls
    QQuickStyle.setStyle("Basic")

    app = QGuiApplication(sys.argv)
    app.setOrganizationName("ProjectTracker")
    app.setApplicationName("ProjectTrackerDesktop")

    # Determine paths for PyInstaller (frozen) vs normal execution
    if getattr(sys, 'frozen', False):
        # When frozen, sys._MEIPASS is the temp folder with bundled files
        app_dir = sys._MEIPASS
        # Store databases next to the actual executable, not in the temporary MEIPASS folder
        base_dir = os.path.dirname(sys.executable)
    else:
        app_dir = os.path.dirname(os.path.abspath(__file__))
        base_dir = app_dir

    # Set Window Icon
    icon_path = os.path.join(app_dir, "assets", "app-icon.svg")
    if os.path.exists(icon_path):
        app.setWindowIcon(QIcon(icon_path))

    engine = QQmlApplicationEngine()

    # Create controller instance and expose to QML context
    db_path = os.path.join(base_dir, "project_tracker.db")
    audit_db_path = os.path.join(base_dir, "audit_tracker.db")
    controller = ProjectController(db_path=db_path, audit_db_path=audit_db_path)
    engine.rootContext().setContextProperty("projectController", controller)

    main_qml = os.path.join(app_dir, "qml", "main.qml")
    engine.load(main_qml)

    if not engine.rootObjects():
        sys.exit(-1)

    sys.exit(app.exec())

if __name__ == "__main__":
    main()
