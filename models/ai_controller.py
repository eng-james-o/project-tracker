"""
AI Controller for QML integration.

Exposes AI functionality to the QML frontend.
"""

import os
import sys
import keyring
from keyring.errors import KeyringError
from typing import Optional

from PySide6.QtCore import QCoreApplication, QObject, Property, QSettings, Signal, Slot

from models.ai_service import AIService


class AIController(QObject):
    providerChanged = Signal()
    generationStarted = Signal()
    generationFinished = Signal(str)
    generationFailed = Signal(str)
    
    def __init__(self, parent: Optional[QObject] = None):
        super().__init__(parent)
        self._ai_service = AIService()
        self._ai_service.generationStarted.connect(self.generationStarted)
        self._ai_service.generationFinished.connect(self.generationFinished)
        self._ai_service.generationFailed.connect(self.generationFailed)
    
        if sys.platform == "win32":
            from keyring.backends.Windows import WinVaultKeyring
            self._vault = WinVaultKeyring()
        else:
            self._vault = keyring.get_keyring()
        self._settings = QSettings()
        name = self._settings.value("ai/provider", "gemini")
        self._activate(name if name in self.availableProviders else "gemini")
        if QCoreApplication.instance():
            QCoreApplication.instance().aboutToQuit.connect(self._ai_service.shutdown)

    def _activate(self, name):
        key = ""
        if name != "ollama":
            try:
                key = self._vault.get_password("ProjectTrackerDesktop", name) or ""
            except (KeyringError, OSError):
                pass
            if not getattr(sys, "frozen", False):
                key = key or os.environ.get(f"{name.upper()}_API_KEY", "")
        self._ai_service.set_provider(name, key)
        self.providerChanged.emit()

    @Property(str, notify=providerChanged)
    def currentProvider(self):
        return self._ai_service.current_provider

    @Property("QStringList", constant=True)
    def availableProviders(self):
        return self._ai_service.available_providers

    @Slot(str, str, result=str)
    def setProvider(self, name, api_key=""):
        if name not in self.availableProviders:
            return "Unknown provider."
        if name != "ollama" and api_key.strip():
            try:
                self._vault.set_password("ProjectTrackerDesktop", name, api_key.strip())
            except (KeyringError, OSError):
                return "Could not save the key to your system credential store."
        self._settings.setValue("ai/provider", name)
        self._activate(name)
        return ""

    @Slot(str, str, result=str)
    def generate(self, prompt: str, system_prompt: str = "") -> str:
        """Generate a response (blocking)."""
        return self._ai_service.generate(prompt, system_prompt)
    
    @Slot(str, str)
    def generateAsync(self, prompt: str, system_prompt: str = ""):
        """Generate a response asynchronously."""
        self._ai_service.generate_async(prompt, system_prompt)
    
    @Slot(str, result=str)
    def generateProjectSteps(self, project_description: str) -> str:
        """Generate project steps from a description."""
        return self._ai_service.generate_project_steps(project_description)
    
    @Slot(str, str, str, str, result=str)
    def generateClientEmail(self, project_title: str, client_name: str, progress: str, upcoming: str) -> str:
        """Generate a client status update email."""
        return self._ai_service.generate_client_email(project_title, client_name, progress, upcoming)
    
    @Slot(str, result=str)
    def analyzeProjectHealth(self, project_data: str) -> str:
        """Analyze project health and identify risks."""
        return self._ai_service.analyze_project_health(project_data)
    
    @Slot(str, result=str)
    def summarizeResource(self, resource_content: str) -> str:
        """Summarize a resource."""
        return self._ai_service.summarize_resource(resource_content)
    
    @Slot(str)
    def chat(self, message: str):
        """Send a chat message to the AI assistant."""
        return self._ai_service.chat(message)
