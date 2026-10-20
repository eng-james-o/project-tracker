import sys
import os
from PySide6.QtGui import QGuiApplication, QIcon
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtQuickControls2 import QQuickStyle
from models.controller_manager import ControllerManager

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

    # Create controllers and expose their domain APIs to the QML context
    db_path = os.path.join(base_dir, "project_tracker.db")
    audit_db_path = os.path.join(base_dir, "audit_tracker.db")
    controllers = ControllerManager(db_path=db_path, audit_db_path=audit_db_path)
    engine.rootContext().setContextProperty(
        "clipboardController", controllers.clipboard_controller
    )
    engine.rootContext().setContextProperty(
        "projectController", controllers.project_controller
    )
    engine.rootContext().setContextProperty(
        "projectDetailsController", controllers.project_details_controller
    )
    engine.rootContext().setContextProperty(
        "dashboardController", controllers.dashboard_controller
    )
    engine.rootContext().setContextProperty(
        "planningController", controllers.planning_controller
    )
    engine.rootContext().setContextProperty(
        "profileController", controllers.profile_controller
    )

    main_qml = os.path.join(app_dir, "qml", "main.qml")
    engine.load(main_qml)

    if not engine.rootObjects():
        sys.exit(-1)

    sys.exit(app.exec())

if __name__ == "__main__":
    main()
