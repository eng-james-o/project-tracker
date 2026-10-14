# Feature Proposals, Workflow Enhancements, and Free AI Integration Guide

This document outlines strategic recommendations for expanding **Project Tracker Desktop**, improving user efficiency and workflow, and integrating Artificial Intelligence (AI) capabilities using free Large Language Model (LLM) APIs and local models.

---

## Table of Contents

1. [New Features to Improve Utility](#1-new-features-to-improve-utility)
   - [1.1 Advanced Time Tracking & Budget Management](#11-advanced-time-tracking--budget-management)
   - [1.2 Interactive Kanban & Gantt Chart Views](#12-interactive-kanban--gantt-chart-views)
   - [1.3 Project Tagging & Category Management](#13-project-tagging--category-management)
   - [1.4 Exporting & Report Generation (PDF / CSV)](#14-exporting--report-generation-pdf--csv)
   - [1.5 Automated Data Backup & Multi-Device Sync](#15-automated-data-backup--multi-device-sync)
2. [Workflow Improvements](#2-workflow-improvements)
   - [2.1 Project Templates & Quick Cloning](#21-project-templates--quick-cloning)
   - [2.2 Global Command Palette (`Ctrl+K`)](#22-global-command-palette-ctrlk)
   - [2.3 Keyboard Shortcuts & Fast Navigation](#23-keyboard-shortcuts--fast-navigation)
   - [2.4 Batch Operations & Drag-and-Drop Reordering](#24-batch-operations--drag-and-drop-reordering)
   - [2.5 Rich Markdown Notes & Live Preview](#25-rich-markdown-notes--live-preview)
   - [2.6 Contextual Notification System & Desktop Alerts](#26-contextual-notification-system--desktop-alerts)
3. [AI Integration via Free LLMs](#3-ai-integration-via-free-llms)
   - [3.1 Recommended Free LLM Providers](#31-recommended-free-llm-providers)
   - [3.2 Concrete AI-Powered Features](#32-concrete-ai-powered-features)
   - [3.3 Architectural & Technical Implementation Plan](#33-architectural--technical-implementation-plan)
   - [3.4 Example Code Architecture](#34-example-code-architecture)

---

## 1. New Features to Improve Utility

### 1.1 Advanced Time Tracking & Budget Management
* **Stopwatch / Timer Widget**: Allow users to start/stop a timer directly on steps or deliverables to record actual hours spent versus estimated hours.
* **Hourly Rate & Expense Tracking**: Track hourly rates per project or fixed project budgets, generating real-time calculations of project profitability and cost-to-completion.

### 1.2 Interactive Kanban & Gantt Chart Views
* **Kanban Board**: Introduce a visual Kanban view (e.g. columns for `To Do`, `In Progress`, `Review`, `Done`) for project steps across active projects.
* **Gantt Timeline**: Provide a timeline visualization displaying overlapping deadlines for steps, deliverables, and projects, making schedule bottlenecks immediately obvious.

### 1.3 Project Tagging & Category Management
* **Custom Tags & Color Coding**: Enable users to add custom labels/tags (e.g., `#design`, `#urgent`, `#client-A`, `#q3-goal`) with custom color badges.
* **Filter by Tag**: Add multi-tag filtering in the Projects View and Dashboard to group related work across different clients.

### 1.4 Exporting & Report Generation (PDF / CSV)
* **Client Status Reports**: Generate one-click PDF/HTML executive summaries detailing progress, completed deliverables, upcoming deadlines, and project notes.
* **CSV/JSON Data Export**: Export project lists, time logs, and deliverable status for external auditing or spreadsheet analysis.

### 1.5 Automated Data Backup & Multi-Device Sync
* **Local Database Backups**: Automatic rolling database snapshots (e.g., daily backups stored in `backups/project_tracker_YYYYMMDD.db`).
* **Cloud Sync Support**: Support syncing SQLite database files or importing/exporting JSON archives to cloud storage (Google Drive, Dropbox, OneDrive).

---

## 2. Workflow Improvements

### 2.1 Project Templates & Quick Cloning
* **Reusable Templates**: Create predefined project structures (e.g., "Web Development", "Client Onboarding", "Graphic Design Package") pre-populated with standard steps, deliverables, and resource checklists.
* **Project Cloning**: One-click "Duplicate Project" action to replicate an existing project structure without copying completion states.

### 2.2 Global Command Palette (`Ctrl+K`)
* **Unified Quick Action Menu**: Implement a global modal overlay triggered by `Ctrl+K` or `Cmd+K`.
* **Instant Actions**: Search across all projects, steps, deliverables, and resources in real time, or execute quick commands like "New Project", "Filter Active", or "Export Database".

### 2.3 Keyboard Shortcuts & Fast Navigation
* **Global Hotkeys**:
  - `Ctrl + N`: New project dialog.
  - `Ctrl + F`: Focus quick search input.
  - `Ctrl + 1 / 2 / 3`: Switch views (Dashboard, Projects, Detail).
  - `Space`: Toggle step/deliverable completion when focused.
  - `Esc`: Close open dialogs/drawers.

### 2.4 Batch Operations & Drag-and-Drop Reordering
* **Bulk Editing**: Select multiple steps or deliverables to mark completed, reassign deadlines, or delete in bulk.
* **Drag-and-Drop Reordering**: Allow manual reordering of steps and deliverables within the UI to prioritize task execution visually.

### 2.5 Rich Markdown Notes & Live Preview
* **Markdown Support**: Upgrade project descriptions and resource notes from plain text to Markdown with live rendering (headers, bullet points, checklists, code blocks).

### 2.6 Contextual Notification System & Desktop Alerts
* **Desktop Notifications**: Integrate native OS desktop notifications (via `QSystemTrayIcon`) for approaching or overdue deadlines.
* **In-App Warning Badges**: Highlight urgent items due within 24–48 hours directly on card headers and top bar indicators.

---

## 3. AI Integration via Free LLMs

Integrating AI into **Project Tracker Desktop** elevates it from a passive tracking tool into an active assistant that saves users time in planning, writing, and decision-making.

### 3.1 Recommended Free LLM Providers

| Provider | Model Options | Free Tier Details | Best Use Case |
| :--- | :--- | :--- | :--- |
| **Groq API** | `llama-3.3-70b-versatile`, `mixtral-8x7b-32768` | Free tier with high rate limits (~30 RPM, 14.4k RPD) and ultra-fast speed (~300+ tokens/sec). | Real-time generation, interactive chat, instant step breakdowns. |
| **Google Gemini API** | `gemini-1.5-flash`, `gemini-1.5-pro` | Free tier (15 RPM / 1M TPM / 1,500 RPD). Large context window (1M tokens). | Analyzing large project notes, resource document summaries, and complex planning. |
| **OpenRouter** | Free open-source models (`meta-llama/llama-3.2-3b-instruct:free`, `google/gemma-2-9b-it:free`) | Aggregated free models via a single OpenAI-compatible REST API endpoint. | Multi-model fallback option. |
| **Ollama (Local)** | `llama3.2`, `mistral`, `phi3` | 100% free, fully offline, private local execution via REST endpoint (`http://localhost:11434/v1`). | Privacy-conscious users, offline access without API keys. |

---

### 3.2 Concrete AI-Powered Features

#### A. Automated Work Breakdown Structure (WBS) & Step Generator
* **Concept**: When creating or editing a project, the user enters a high-level description (e.g. *"Build a responsive Shopify store for a clothing brand with custom checkout and product import"*).
* **AI Action**: Click "Generate Steps & Deliverables with AI". The LLM returns a structured JSON list of recommended steps and key deliverables with suggested timeframes.
* **Value**: Reduces project setup time from 15–20 minutes down to 5 seconds.

#### B. Client Status Email Draft Generator
* **Concept**: One-click "Draft Client Update Email" button on the Project Detail view.
* **AI Action**: The LLM reads completed steps/deliverables, remaining items, client name, and upcoming deadlines, generating a professional status update email.
* **Value**: Eliminates tedious client communication writing while maintaining consistent updates.

#### C. Smart Project Risk & Bottleneck Analyzer
* **Concept**: An "Analyze Health & Risks" button on the Dashboard or Project View.
* **AI Action**: Scans active projects for overdue steps, tight deliverable timelines, and incomplete dependencies, outputting actionable risk warnings and mitigation advice.
* **Value**: Provides proactive project manager insight.

#### D. Resource & Meeting Notes Summarizer
* **Concept**: Attached resource notes or external links can be summarized automatically into concise key takeaways and action items.

#### E. Embedded AI Project Assistant (Chatbot Drawer)
* **Concept**: A slide-out panel on the Project Detail view where users can ask questions regarding project scope, draft proposal language, or ask technical advice relevant to the project deliverables.

---

### 3.3 Architectural & Technical Implementation Plan

To keep the application responsive and robust, AI calls must be implemented cleanly into the existing PySide6 + QML architecture:

1. **Non-Blocking Asynchronous Execution**:
   - Web API calls or local Ollama invocations must run off the main GUI thread using PySide6's `QThread` or `QRunnable` worker patterns.
   - Emit PySide6 signals (`aiGenerationStarted`, `aiGenerationFinished(QString response)`, `aiGenerationFailed(QString error)`) to safely update QML components without freezing the UI.

2. **Provider Abstraction Layer (`AIProvider` interface)**:
   - Create a clean `models/ai_service.py` module with an abstract base class `BaseAIProvider`.
   - Implement concrete providers: `GroqProvider`, `GeminiProvider`, `OllamaProvider`.
   - Support OpenAI-compatible API schemas (which Groq, OpenRouter, and Ollama all support natively via standard `requests` or `httpx`).

3. **Secure API Key Configuration**:
   - Store API keys safely in user configuration using PySide6's `QSettings` or environment variables (`GROQ_API_KEY`, `GEMINI_API_KEY`).
   - Allow users to select their preferred AI provider and enter API keys via an in-app "Settings" dialog in QML.

---

### 3.4 Example Code Architecture

#### Backend Interface (`models/ai_service.py`)
```python
import json
import urllib.request
import urllib.parse
from PySide6.QtCore import QObject, Signal, Slot, QThread

class AIWorker(QThread):
    finished = Signal(str)
    error = Signal(str)

    def __init__(self, provider: str, api_key: str, prompt: str, system_prompt: str = ""):
        super().__init__()
        self.provider = provider
        self.api_key = api_key
        self.prompt = prompt
        self.system_prompt = system_prompt

    def run(self):
        try:
            if self.provider == "groq":
                url = "https://api.groq.com/openai/v1/chat/completions"
                headers = {
                    "Authorization": f"Bearer {self.api_key}",
                    "Content-Type": "application/json"
                }
                payload = {
                    "model": "llama-3.3-70b-versatile",
                    "messages": [
                        {"role": "system", "content": self.system_prompt or "You are a helpful project manager assistant."},
                        {"role": "user", "content": self.prompt}
                    ],
                    "temperature": 0.3
                }
            elif self.provider == "ollama":
                url = "http://localhost:11434/v1/chat/completions"
                headers = {"Content-Type": "application/json"}
                payload = {
                    "model": "llama3.2",
                    "messages": [
                        {"role": "system", "content": self.system_prompt or "You are a helpful project manager assistant."},
                        {"role": "user", "content": self.prompt}
                    ]
                }
            else:
                raise ValueError(f"Unsupported provider: {self.provider}")

            req = urllib.request.Request(
                url,
                data=json.dumps(payload).encode('utf-8'),
                headers=headers,
                method='POST'
            )
            with urllib.request.urlopen(req, timeout=30) as response:
                result = json.loads(response.read().decode('utf-8'))
                content = result['choices'][0]['message']['content']
                self.finished.emit(content)
        except Exception as e:
            self.error.emit(str(e))
```

#### QML Frontend Component Integration (`qml/components/AIAssistantDrawer.qml`)
```qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Drawer {
    id: aiDrawer
    width: 380
    edge: Qt.RightEdge

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        Text {
            text: "AI Work Breakdown Generator"
            font.pixelSize: 18
            font.bold: true
        }

        TextArea {
            id: promptInput
            Layout.fillWidth: true
            placeholderText: "Describe your project goals or tasks to generate steps..."
        }

        Button {
            text: "Generate Steps"
            onClicked: {
                projectController.generateStepsWithAI(promptInput.text)
            }
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            TextArea {
                id: aiOutputArea
                readOnly: true
                wrapMode: Text.Wrap
            }
        }
    }
}
```

---

## Conclusion

Implementing these utility features, workflow optimizations, and free AI capabilities will transform Project Tracker Desktop into an exceptionally efficient, modern, and intelligent tool for managing software projects, freelance client work, and personal task execution.
