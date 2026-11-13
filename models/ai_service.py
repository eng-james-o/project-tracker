"""
AI Service for Project Tracker Desktop

Supports multiple LLM providers:
- Groq API (free tier with high rate limits)
- Google Gemini API (free tier)
- Ollama (local, free, private)

Usage:
    ai_service = AIService()
    ai_service.set_provider("groq", api_key="your_api_key")
    response = ai_service.generate("Create a project plan for...")
"""

import json
import os
from abc import ABC, abstractmethod
from typing import Any, Dict, List, Optional

from PySide6.QtCore import QObject, Signal, Slot, QThread


class BaseAIProvider(ABC):
    """Abstract base class for AI providers."""
    
    @abstractmethod
    def generate(self, prompt: str, system_prompt: str = "", temperature: float = 0.3) -> str:
        """Generate a response from the LLM."""
        pass
    
    @abstractmethod
    def is_available(self) -> bool:
        """Check if the provider is available."""
        pass


class GroqProvider(BaseAIProvider):
    """Groq API provider."""
    
    def __init__(self, api_key: str = ""):
        self.api_key = api_key or os.getenv("GROQ_API_KEY", "")
        self.base_url = "https://api.groq.com/openai/v1/chat/completions"
        self.model = "llama-3.3-70b-versatile"
    
    def is_available(self) -> bool:
        return bool(self.api_key)
    
    def generate(self, prompt: str, system_prompt: str = "", temperature: float = 0.3) -> str:
        import httpx
        
        if not self.is_available():
            raise ValueError("Groq API key not set")
        
        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json"
        }
        
        payload = {
            "model": self.model,
            "messages": [
                {"role": "system", "content": system_prompt or "You are a helpful project manager assistant."},
                {"role": "user", "content": prompt}
            ],
            "temperature": temperature
        }
        
        try:
            response = httpx.post(self.base_url, headers=headers, json=payload, timeout=30)
            response.raise_for_status()
            result = response.json()
            return result['choices'][0]['message']['content']
        except Exception as e:
            raise Exception(f"Groq API error: {str(e)}")


class GeminiProvider(BaseAIProvider):
    """Google Gemini API provider."""
    
    def __init__(self, api_key: str = ""):
        self.api_key = api_key or os.getenv("GEMINI_API_KEY", "")
        self.base_url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent"
    
    def is_available(self) -> bool:
        return bool(self.api_key)
    
    def generate(self, prompt: str, system_prompt: str = "", temperature: float = 0.3) -> str:
        import httpx
        
        if not self.is_available():
            raise ValueError("Gemini API key not set")
        
        headers = {
            "Content-Type": "application/json"
        }
        params = {
            "key": self.api_key
        }
        
        payload = {
            "contents": [
                {
                    "parts": [
                        {"text": system_prompt + "\n\n" + prompt}
                    ]
                }
            ],
            "generationConfig": {
                "temperature": temperature
            }
        }
        
        try:
            response = httpx.post(self.base_url, headers=headers, params=params, json=payload, timeout=30)
            response.raise_for_status()
            result = response.json()
            return result['candidates'][0]['content']['parts'][0]['text']
        except Exception as e:
            raise Exception(f"Gemini API error: {str(e)}")


class OllamaProvider(BaseAIProvider):
    """Ollama local provider."""
    
    def __init__(self, base_url: str = "http://localhost:11434"):
        self.base_url = base_url
        self.model = "llama3.2"
    
    def is_available(self) -> bool:
        import httpx
        try:
            response = httpx.get(f"{self.base_url}/api/tags", timeout=5)
            return response.status_code == 200
        except:
            return False
    
    def generate(self, prompt: str, system_prompt: str = "", temperature: float = 0.3) -> str:
        import httpx
        
        if not self.is_available():
            raise ValueError("Ollama server not running or unreachable")
        
        payload = {
            "model": self.model,
            "messages": [
                {"role": "system", "content": system_prompt or "You are a helpful project manager assistant."},
                {"role": "user", "content": prompt}
            ],
            "stream": False,
            "options": {
                "temperature": temperature
            }
        }
        
        try:
            response = httpx.post(f"{self.base_url}/v1/chat/completions", json=payload, timeout=30)
            response.raise_for_status()
            result = response.json()
            return result['choices'][0]['message']['content']
        except Exception as e:
            raise Exception(f"Ollama error: {str(e)}")


class AIWorker(QThread):
    """Worker thread for non-blocking AI calls."""
    
    finished = Signal(str)
    error = Signal(str)
    
    def __init__(self, provider: BaseAIProvider, prompt: str, system_prompt: str = "", temperature: float = 0.3):
        super().__init__()
        self.provider = provider
        self.prompt = prompt
        self.system_prompt = system_prompt
        self.temperature = temperature
    
    def run(self):
        try:
            result = self.provider.generate(self.prompt, self.system_prompt, self.temperature)
            self.finished.emit(result)
        except Exception as e:
            self.error.emit(str(e))


class AIService(QObject):
    """Main AI service that manages providers and generates content."""
    
    generationStarted = Signal()
    generationFinished = Signal(str)
    generationFailed = Signal(str)
    
    def __init__(self, parent: Optional[QObject] = None):
        super().__init__(parent)
        self._provider: Optional[BaseAIProvider] = None
        self._providers: Dict[str, BaseAIProvider] = {
            "groq": GroqProvider(),
            "gemini": GeminiProvider(),
            "ollama": OllamaProvider()
        }
        self._current_provider_name = "groq"
    
    @Property(str)
    def current_provider(self) -> str:
        return self._current_provider_name
    
    @Property(list)
    def available_providers(self) -> List[str]:
        return list(self._providers.keys())
    
    @Slot(str, str)
    def set_provider(self, provider_name: str, api_key: str = ""):
        """Set the current AI provider and optional API key."""
        if provider_name in self._providers:
            self._current_provider_name = provider_name
            # Update API key for the provider
            if provider_name == "groq":
                self._providers["groq"].api_key = api_key
            elif provider_name == "gemini":
                self._providers["gemini"].api_key = api_key
        else:
            raise ValueError(f"Unknown provider: {provider_name}")
    
    @Slot(str, str, result=str)
    def generate(self, prompt: str, system_prompt: str = "") -> str:
        """Generate a response (blocking call)."""
        provider = self._providers.get(self._current_provider_name)
        if not provider:
            raise ValueError(f"Provider {self._current_provider_name} not found")
        
        if not provider.is_available():
            raise ValueError(f"Provider {self._current_provider_name} is not available")
        
        return provider.generate(prompt, system_prompt)
    
    @Slot(str, str)
    def generate_async(self, prompt: str, system_prompt: str = ""):
        """Generate a response asynchronously."""
        provider = self._providers.get(self._current_provider_name)
        if not provider:
            self.generationFailed.emit(f"Provider {self._current_provider_name} not found")
            return
        
        if not provider.is_available():
            self.generationFailed.emit(f"Provider {self._current_provider_name} is not available")
            return
        
        self.generationStarted.emit()
        worker = AIWorker(provider, prompt, system_prompt)
        worker.finished.connect(self.generationFinished)
        worker.error.connect(self.generationFailed)
        worker.start()
    
    @Slot(str, str, result=str)
    def generate_project_steps(self, project_description: str) -> str:
        """Generate project steps from a description."""
        system_prompt = """You are a project manager assistant. Given a project description, generate a structured list of steps needed to complete the project. Return the result as a JSON object with the following structure:
{
    "steps": [
        {"title": "Step 1 title", "description": "Step 1 description", "deadline": "optional deadline"},
        ...
    ],
    "deliverables": [
        {"title": "Deliverable 1 title", "description": "Deliverable 1 description", "deadline": "optional deadline"},
        ...
    ]
}
Return ONLY the JSON object, no other text."""
        
        return self.generate(
            f"Generate steps and deliverables for this project: {project_description}",
            system_prompt
        )
    
    @Slot(str, str, str, str, result=str)
    def generate_client_email(self, project_title: str, client_name: str, progress: str, upcoming: str) -> str:
        """Generate a client status update email."""
        system_prompt = """You are a professional project manager. Write a concise, professional email to the client updating them on the project status. Include:
1. Project name
2. Current progress
3. Completed items
4. Upcoming deadlines
5. Any blockers or issues
Keep the tone professional and positive."""
        
        prompt = f"""Write a client update email for project '{project_title}' for client '{client_name}'.
Current progress: {progress}
Upcoming deadlines: {upcoming}"""
        
        return self.generate(prompt, system_prompt)
    
    @Slot(str, result=str)
    def analyze_project_health(self, project_data: str) -> str:
        """Analyze project health and identify risks."""
        system_prompt = """You are a project manager assistant. Analyze the project data and identify:
1. Potential risks or bottlenecks
2. Items that are overdue or approaching deadline
3. Recommendations for mitigation
Return the analysis as a structured markdown report."""
        
        return self.generate(
            f"Analyze this project data and identify risks: {project_data}",
            system_prompt
        )
    
    @Slot(str, result=str)
    def summarize_resource(self, resource_content: str) -> str:
        """Summarize a resource (document, note, etc.)."""
        system_prompt = """You are a helpful assistant. Summarize the following content into key takeaways and action items. Return the summary as markdown with:
- **Key Points**: Bullet list of main points
- **Action Items**: Bullet list of actionable items
- **Summary**: Brief paragraph summary"""
        
        return self.generate(
            f"Summarize this content: {resource_content}",
            system_prompt
        )
    
    @Slot(str, result=str)
    def chat(self, message: str) -> str:
        """Send a chat message to the AI assistant."""
        system_prompt = """You are a helpful AI assistant for a project management application. You can help with:
- Project planning and step generation
- Client communication (email drafting)
- Risk analysis and mitigation
- Resource summarization
- General project management advice
Be concise and actionable in your responses."""
        
        return self.generate(message, system_prompt)
