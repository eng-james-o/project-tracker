"""Capture the desktop app's views into docs/screenshots."""

import os
import sys
from pathlib import Path
from tempfile import TemporaryDirectory

from PySide6.QtCore import QEvent, QMetaObject, QObject, QPointF, QSettings, Qt
from PySide6.QtWidgets import QApplication
from PySide6.QtQuick import QQuickItem, QQuickWindow
from PySide6.QtQuickControls2 import QQuickStyle
from PySide6.QtTest import QTest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
from main import load_window


def capture(window: QQuickWindow, directory, name):
    QTest.qWait(400)
    image = window.grabWindow()
    if image.isNull() or not image.save(str(directory / f"{name}_view.png")):
        raise RuntimeError(f"Could not capture {name}")


def click_sidebar(window, label):
    for button in window.findChildren(QQuickItem):
        if button.property("text") == label and button.isVisible() and button.inherits("QQuickAbstractButton"):
            center = button.mapToScene(QPointF(button.width() / 2, button.height() / 2))
            QTest.mouseClick(window, Qt.LeftButton, Qt.NoModifier, center.toPoint())
            QTest.qWait(60)
            return
    raise RuntimeError(f"Sidebar button is unavailable: {label}")


def main():
    if sys.platform.startswith("linux") and not any(
        os.environ.get(key) for key in ("DISPLAY", "WAYLAND_DISPLAY")
    ):
        os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")
    os.environ.setdefault("QT_QUICK_BACKEND", "software")
    QQuickStyle.setStyle("Basic")
    app = QApplication([])
    app.setOrganizationName("ProjectTracker")
    app.setApplicationName("ScreenshotPreview")
    output = ROOT / "docs" / "screenshots"
    output.mkdir(parents=True, exist_ok=True)
    with TemporaryDirectory() as data:
        QSettings.setDefaultFormat(QSettings.IniFormat)
        QSettings.setPath(QSettings.IniFormat, QSettings.UserScope, data)
        engine, controllers = load_window(str(ROOT), data)
        window = engine.rootObjects()[0]
        stack = window.findChild(QObject, "mainStack")
        onboarding = window.findChild(QObject, "onboardingView")
        project = controllers.project_controller
        pid = project.add_project("Field survey", "Survey team", "", "active",
                                  "2027-01-15", "Prepare the site survey and mapping report.", tags="survey")
        project.load_project_details(pid)
        if not QTest.qWaitForWindowExposed(window):
            raise RuntimeError("The application window did not open")
        if not onboarding.property("visible"):
            raise RuntimeError("Onboarding did not open")
        capture(window, output, "onboarding")
        QMetaObject.invokeMethod(onboarding, "close")
        QTest.qWait(200)
        routes = [
            ("dashboard", 0, ["Dashboard"]),
            ("projects", 1, ["All Projects"]),
            ("project_detail", 2, []),
            ("project_board", 3, ["Project Board"]),
            ("goals", 4, ["Planning", "Goals"]),
            ("audit_log", 5, ["Management", "Activity & Audit"]),
            ("settings", 6, ["Settings"]),
        ]
        for name, index, buttons in routes:
            for label in buttons:
                click_sidebar(window, label)
            if name == "project_detail":
                stack.setProperty("currentIndex", index)
            if stack.property("currentIndex") != index:
                raise RuntimeError(f"Sidebar navigation failed: {name}")
            capture(window, output, name)
        click_sidebar(window, "Tools")
        click_sidebar(window, "AI Assistant")
        drawer = window.findChild(QObject, "assistantDrawer")
        assert drawer.property("visible")
        QMetaObject.invokeMethod(drawer, "close")
        QTest.qWait(400)
        button = window.findChild(QQuickItem, "openAssistant")
        center = button.mapToScene(QPointF(button.width() / 2, button.height() / 2))
        QTest.mouseClick(window, Qt.LeftButton, Qt.NoModifier, center.toPoint())
        QTest.qWait(400)
        assert drawer.property("visible")
        capture(window, output, "ai_assistant")
        window.close()
        engine.deleteLater()
        app.sendPostedEvents(engine, QEvent.DeferredDelete)


if __name__ == "__main__":
    main()
