"""Capture the desktop app's eight views into docs/screenshots."""

import os
import sys
from pathlib import Path
from tempfile import TemporaryDirectory

from PySide6.QtCore import QMetaObject, QObject, QSettings
from PySide6.QtWidgets import QApplication
from PySide6.QtQuick import QQuickWindow
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
                                  "2027-01-15", "Prepare the site survey and mapping report.")
        project.load_project_details(pid)
        if not QTest.qWaitForWindowExposed(window):
            raise RuntimeError("The application window did not open")
        if not onboarding.property("visible"):
            raise RuntimeError("Onboarding did not open")
        capture(window, output, "onboarding")
        QMetaObject.invokeMethod(onboarding, "close")
        for index, name in enumerate(("dashboard", "projects", "project_detail",
                                      "project_board", "goals", "audit_log", "settings")):
            if not stack.setProperty("currentIndex", index):
                raise RuntimeError(f"Could not navigate to {name}")
            capture(window, output, name)
        window.close()
        del engine, controllers


if __name__ == "__main__":
    main()
