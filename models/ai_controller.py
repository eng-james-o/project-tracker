"""
AI Controller for QML integration.

Exposes AI functionality to the QML frontend.
"""

from typing import Optional

from PySide6.QtCore import QObject, Property, Signal, Slot

from models.ai_service import AIService


class AIController(QObject):
    generationStarted = Signal()
    generationFinished = Signal(str)
    generationFailed = Signal(str)
    
    def __init__(self, parent: Optional[QObject] = None):
        super().__init__(parent)
        self._ai_service = AIService()
        self._ai_service.generationStarted.connect(self.generationStarted)
        self._ai_service.generationFinished.connect(self.generationFinished)
        self._ai_service.generationFailed.connect(self.generationFailed)
    
    @Property(str)
    def currentProvider(self) -> str:
        return self._ai_service.current_provider
    
    @Property(list)
    def availableProviders(self) -> list:
        return self._ai_service.available_providers
    
    @Slot(str, str)
    def setProvider(self, provider_name: str, api_key: str = ""):
        """Set the current AI provider and API key."""
        self._ai_service.set_provider(provider_name, api_key)
    
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
