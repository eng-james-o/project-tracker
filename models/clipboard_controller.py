from PySide6.QtCore import QObject, Slot
from PySide6.QtGui import QGuiApplication


class ClipboardController(QObject):
    @Slot(result=str)
    def get_clipboard_text(self) -> str:
        return QGuiApplication.clipboard().text()

    @Slot(result=bool)
    def has_text(self) -> bool:
        return bool(QGuiApplication.clipboard().text())
