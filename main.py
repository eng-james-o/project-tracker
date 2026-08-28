import sys
import os
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtQuickControls2 import QQuickStyle
from models.project_controller import ProjectController

def main():
    # Use Basic style to allow custom QML background/contentItem overrides on controls
    QQuickStyle.setStyle("Basic")

    app = QGuiApplication(sys.argv)
    app.setOrganizationName("ProjectTracker")
    app.setApplicationName("ProjectTrackerDesktop")

    engine = QQmlApplicationEngine()

    # Create controller instance and expose to QML context
    db_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "project_tracker.db")
    controller = ProjectController(db_path=db_path)
    engine.rootContext().setContextProperty("projectController", controller)

    main_qml = os.path.join(os.path.dirname(os.path.abspath(__file__)), "qml", "main.qml")
    engine.load(main_qml)

    if not engine.rootObjects():
        sys.exit(-1)

    sys.exit(app.exec())

if __name__ == "__main__":
    main()
